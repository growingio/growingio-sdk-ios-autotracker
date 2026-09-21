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

@end

static BOOL viewImpressionDisabled = NO;

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
    }
    return self;
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
        if ([view growingViewImpNodeIsVisibleWithScale:node.config.viewImpressionScale]) {
            if (!node.tracked) {
                [self trackNode:node];
            }
        } else {
            node.tracked = NO;
        }
    }
}

- (void)trackNode:(GrowingViewImpressionNode *)node {
    node.tracked = YES;
    [GrowingEventGenerator generateCustomEvent:node.eventName attributes:node.attributes];
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
}

@end
