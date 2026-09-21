//
//  GrowingViewImpression.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "Modules/ViewImpression/Public/GrowingViewImpression.h"
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingULAppLifecycle.h"
#import "GrowingULApplication.h"
#import "Modules/ViewImpression/GrowingViewImpression+Private.h"
#import "Modules/ViewImpression/UIView+GrowingViewImpressionInternal.h"

GrowingMod(GrowingViewImpression)

@interface GrowingViewImpression () <GrowingULAppLifecycleDelegate>

@property (nonatomic, strong) NSHashTable<UIView *> *sourceTable;
@property (nonatomic, assign) NSTimeInterval checkInterval;
@property (nonatomic, assign) CFTimeInterval lastCheckTime;
@property (nonatomic, assign) BOOL trailingCheckScheduled;
@property (nonatomic, assign) BOOL inactive;
@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *trackedIdentifiers;
@property (nonatomic, assign) BOOL trackedIdentifiersOverflowWarned;
@property (nonatomic, strong) NSHashTable<id<GrowingViewImpressionDelegate>> *delegates;

@end

static BOOL viewImpressionDisabled = NO;

/// 复检时点比停留时长多留一点余量，避免浮点误差导致刚好差一丁点而空跑一轮
static const NSTimeInterval kRecheckSlack = 0.01;

static const NSUInteger kTrackedIdentifiersCapacity = 10000;

@implementation GrowingViewImpression

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)growingModInit:(GrowingContext *)context {
    if ([GrowingULApplication isAppExtension]) {
        return;
    }

    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!configuration.viewImpressionEnabled) {
        viewImpressionDisabled = YES;
        [self.sourceTable removeAllObjects];
        return;
    }

    self.checkInterval = configuration.viewImpressionCheckInterval;
    [GrowingULAppLifecycle.sharedInstance addAppLifecycleDelegate:self];
    [self registerMainRunloopObserver];
}

- (instancetype)init {
    if (self = [super init]) {
        _sourceTable = [[NSHashTable alloc]
            initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality
                   capacity:100];
        _trackedIdentifiers = [NSMutableOrderedSet orderedSet];
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

#pragma mark - Public Method

- (void)addImpressionDelegate:(id<GrowingViewImpressionDelegate>)delegate {
    if (!delegate) {
        return;
    }
    [GrowingDispatchManager dispatchInMainThread:^{
        [self.delegates addObject:delegate];
    }];
}

- (void)removeImpressionDelegate:(id<GrowingViewImpressionDelegate>)delegate {
    if (!delegate) {
        return;
    }
    [GrowingDispatchManager dispatchInMainThread:^{
        [self.delegates removeObject:delegate];
    }];
}

#pragma mark - Private Method

- (void)addImpressionView:(UIView *)view {
    if (viewImpressionDisabled) {
        return;
    }
    [self.sourceTable addObject:view];
}

- (void)removeImpressionView:(UIView *)view {
    [self.sourceTable removeObject:view];
}

- (void)registerMainRunloopObserver {
    [GrowingDispatchManager dispatchInMainThread:^{
        static CFRunLoopObserverRef observer;
        if (observer) {
            return;
        }

        CFOptionFlags activities = (kCFRunLoopBeforeWaiting | kCFRunLoopExit);
        observer =
            CFRunLoopObserverCreateWithHandler(NULL,
                                               activities,
                                               YES,
                                               INT_MAX - 1,  // 排在 CA transaction 提交之后、autoreleasepool 之前
                                               ^(CFRunLoopObserverRef obs, CFRunLoopActivity activity) {
                                                   [self scheduleImpressionCheck];
                                               });

        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    }];
}

- (void)scheduleImpressionCheck {
    if (self.checkInterval <= 0.0) {
        [self checkImpression];
        return;
    }

    CFTimeInterval remaining = self.checkInterval - (CACurrentMediaTime() - self.lastCheckTime);
    if (remaining <= 0.0) {
        [self checkImpression];
        return;
    }

    // 界面静止后 runloop 不再产生 tick，补一次尾随检测，
    // 否则滚动停下瞬间进入可视区的元素会一直等不到下一次判定
    if (self.trailingCheckScheduled) {
        return;
    }
    self.trailingCheckScheduled = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remaining * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.trailingCheckScheduled = NO;
        [self checkImpression];
    });
}

- (void)checkImpression {
    self.lastCheckTime = CACurrentMediaTime();

    if (self.inactive || self.sourceTable.count == 0) {
        return;
    }

    for (UIView *view in self.sourceTable.allObjects) {
        [self checkImpressionForView:view];
    }
}

- (void)checkImpressionForView:(UIView *)view {
    NSDictionary<NSString *, GrowingViewImpressionNode *> *nodes = view.growingViewImpNodes;
    for (GrowingViewImpressionNode *node in nodes.allValues) {
        [self checkNode:node inView:view];
    }
}

- (void)checkNode:(GrowingViewImpressionNode *)node inView:(UIView *)view {
    if (![view growingViewImpNodeIsVisibleWithScale:node.config.viewImpressionScale]) {
        if (node.visibleSince != 0) {
            node.visibleSince = 0;
            node.recheckToken += 1;
        }
        node.tracked = NO;
        return;
    }

    if (node.tracked) {
        return;
    }

    NSTimeInterval stayDuration = node.config.stayDuration;
    if (node.visibleSince == 0) {
        node.visibleSince = CACurrentMediaTime();
        if (stayDuration > 0) {
            [self scheduleRecheckForNode:node inView:view after:stayDuration];
        }
    }

    if (CACurrentMediaTime() - node.visibleSince >= stayDuration) {
        [self trackNode:node inView:view];
    }
}

- (void)scheduleRecheckForNode:(GrowingViewImpressionNode *)node inView:(UIView *)view after:(NSTimeInterval)delay {
    node.recheckToken += 1;
    NSUInteger token = node.recheckToken;
    __weak UIView *weakView = view;

    // 界面静止时 runloop 会休眠、不再产生 tick，停留时长只能靠这一次定时复检收口
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay + kRecheckSlack) * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       UIView *strongView = weakView;
                       if (!strongView || self.inactive || node.recheckToken != token) {
                           return;
                       }
                       [self checkNode:node inView:strongView];
                   });
}

- (void)trackNode:(GrowingViewImpressionNode *)node inView:(UIView *)view {
    node.tracked = YES;

    // 不可重复曝光以 identifier 为准记在全局：cell 复用后视图相同而元素不同，
    // 同一元素滚回来又可能落在另一个 cell 实例上，挂在视图上判不准
    if (!node.config.repeatable && [self.trackedIdentifiers containsObject:node.identifier]) {
        return;
    }

    if (![self shouldTrackNode:node inView:view]) {
        return;
    }

    if (!node.config.repeatable) {
        [self rememberTrackedIdentifier:node.identifier];
    }

    [GrowingEventGenerator generateCustomEvent:node.eventName attributes:[self attributesForNode:node inView:view]];
    [self notifyDidTrackNode:node inView:view];
}

- (BOOL)shouldTrackNode:(GrowingViewImpressionNode *)node inView:(UIView *)view {
    for (id<GrowingViewImpressionDelegate> delegate in self.delegates.allObjects) {
        if (![delegate respondsToSelector:@selector(growingImpressionShouldTrack:eventName:identifier:)]) {
            continue;
        }
        if (![delegate growingImpressionShouldTrack:view eventName:node.eventName identifier:node.identifier]) {
            return NO;
        }
    }
    return YES;
}

- (NSDictionary<NSString *, id> *)attributesForNode:(GrowingViewImpressionNode *)node inView:(UIView *)view {
    NSMutableDictionary<NSString *, id> *merged = nil;
    for (id<GrowingViewImpressionDelegate> delegate in self.delegates.allObjects) {
        if (![delegate respondsToSelector:@selector(growingImpressionDynamicAttributes:eventName:identifier:)]) {
            continue;
        }
        NSDictionary<NSString *, id> *dynamic = [delegate growingImpressionDynamicAttributes:view
                                                                                   eventName:node.eventName
                                                                                  identifier:node.identifier];
        if (dynamic.count == 0) {
            continue;
        }
        if (!merged) {
            merged = node.attributes ? node.attributes.mutableCopy : [NSMutableDictionary dictionary];
        }
        [merged addEntriesFromDictionary:dynamic];
    }
    return merged ?: node.attributes;
}

- (void)notifyDidTrackNode:(GrowingViewImpressionNode *)node inView:(UIView *)view {
    for (id<GrowingViewImpressionDelegate> delegate in self.delegates.allObjects) {
        if ([delegate respondsToSelector:@selector(growingImpressionDidTrack:eventName:identifier:)]) {
            [delegate growingImpressionDidTrack:view eventName:node.eventName identifier:node.identifier];
        }
    }
}

- (void)rememberTrackedIdentifier:(NSString *)identifier {
    [self.trackedIdentifiers addObject:identifier];
    if (self.trackedIdentifiers.count <= kTrackedIdentifiersCapacity) {
        return;
    }

    if (!self.trackedIdentifiersOverflowWarned) {
        self.trackedIdentifiersOverflowWarned = YES;
        GIOLogWarn(
            @"[GrowingViewImpression] 不可重复曝光的元素标识已超过 %lu 个，最早的记录将被淘汰，"
            @"请在合适的时机调用 resetAllImpressionState 主动清理",
            (unsigned long)kTrackedIdentifiersCapacity);
    }
    [self.trackedIdentifiers removeObjectAtIndex:0];
}

+ (GrowingViewImpressionConfig *)effectiveConfig:(GrowingViewImpressionConfig *)config {
    if (config) {
        return [config copy];
    }

    GrowingViewImpressionConfig *global =
        GrowingConfigurationManager.sharedInstance.trackConfiguration.viewImpressionConfig;
    return global ? [global copy] : [[GrowingViewImpressionConfig alloc] init];
}

#pragma mark - GrowingULAppLifecycleDelegate

- (void)applicationDidBecomeActive {
    self.inactive = NO;
}

- (void)applicationWillResignActive {
    self.inactive = YES;

    for (UIView *view in self.sourceTable.allObjects) {
        for (GrowingViewImpressionNode *node in view.growingViewImpNodes.allValues) {
            node.visibleSince = 0;
            node.recheckToken += 1;
        }
    }
}

@end

@implementation GrowingViewImpression (State)

+ (void)resetImpressionStateWithIdentifier:(NSString *)identifier {
    if (identifier.length == 0) {
        return;
    }

    [GrowingDispatchManager dispatchInMainThread:^{
        [[self sharedInstance].trackedIdentifiers removeObject:identifier];
    }];
}

+ (void)resetAllImpressionState {
    [GrowingDispatchManager dispatchInMainThread:^{
        [[self sharedInstance].trackedIdentifiers removeAllObjects];
    }];
}

@end
