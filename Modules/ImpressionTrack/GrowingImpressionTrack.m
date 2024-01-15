//
//  GrowingImpressionTrack.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/7/13.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/ImpressionTrack/GrowingImpressionTrack.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingULApplication.h"
#import "GrowingULAppLifecycle.h"
#import "GrowingULSwizzle.h"
#import "GrowingULViewControllerLifecycle.h"
#import "Modules/ImpressionTrack/UIView+GrowingImpressionInternal.h"

GrowingMod(GrowingImpressionTrack)

@interface GrowingImpressionTrack () <GrowingULAppLifecycleDelegate, GrowingULViewControllerLifecycleDelegate>

@property (nonatomic, strong) NSHashTable *sourceTable;
@property (nonatomic, strong) NSHashTable *bgSourceTable;

@end

static BOOL isInResignSate;

@implementation GrowingImpressionTrack

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {
    if ([GrowingULApplication isAppExtension]) {
        return;
    }
    [self track];
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.sourceTable = [[NSHashTable alloc]
            initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality
                   capacity:100];
        self.bgSourceTable = [[NSHashTable alloc]
            initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality
                   capacity:100];
        self.IMPInterval = 0.0;
    }
    return self;
}

- (void)track {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIView growingul_swizzleMethod:@selector(didMoveToSuperview)
                             withMethod:@selector(growing_didMoveToSuperview)
                                  error:nil];
    });

    [GrowingULAppLifecycle.sharedInstance addAppLifecycleDelegate:self];
    [GrowingULViewControllerLifecycle.sharedInstance addViewControllerLifecycleDelegate:self];
}

- (void)markInvisibleNodes {
    if (self.sourceTable.count == 0) {
        return;
    }
    [self.sourceTable.allObjects enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        UIView<GrowingNode> *node = obj;
        if (![node growingImpNodeIsVisible]) {
            node.growingIMPTracked = NO;
        }
    }];
}

- (void)markInvisibleNode:(UIView *)node inSubView:(BOOL)flag;
{
    if (node.growingIMPTrackEventName > 0) {
        node.growingIMPTracked = NO;
    }

    if (flag) {
        [self enumerateSubViewsWithNode:node
                                  block:^(UIView *view) {
                                      if (view.growingIMPTrackEventName > 0) {
                                          view.growingIMPTracked = NO;
                                      }
                                  }];
    }
}

- (void)addWindowNodes {
    [self.sourceTable removeAllObjects];

    UIWindow *window = [[GrowingULApplication sharedApplication] growingul_keyWindow];
    if (window) {
        [self enumerateSubViewsWithNode:window
                                  block:^(UIView *view) {
                                      [self addNode:view];
                                  }];
    }
}

- (void)enumerateSubViewsWithNode:(UIView *)node block:(void (^)(UIView *view))block {
    if (!self.impTrackActive) {
        return;
    }

    NSArray *array = node.subviews;
    for (UIView *subView in array) {
        block(subView);
        [self enumerateSubViewsWithNode:subView block:block];
    }
}

static BOOL impTrackIsRegistered = NO;

- (void)setImpTrackActive:(BOOL)impTrackActive {
    _impTrackActive = impTrackActive;
    if (impTrackActive && !impTrackIsRegistered) {
        impTrackIsRegistered = YES;
        [self registerMainRunloopObserver];
    }
}

- (void)registerMainRunloopObserver {
    // ensure call in main thread
    [GrowingDispatchManager dispatchInMainThread:^{
        static CFRunLoopObserverRef observer;

        if (observer) {
            return;
        }

        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        // before the run loop starts sleeping
        // before exiting a runloop run
        CFOptionFlags activities = (kCFRunLoopBeforeWaiting | kCFRunLoopExit);

        observer = CFRunLoopObserverCreateWithHandler(
            NULL,         // allocator
            activities,   // activities
            YES,          // repeats
            INT_MAX - 1,  // order after CA transaction commits and before autoreleasepool
            ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                if (self.IMPInterval == 0.0) {
                    [self impTrack];
                } else {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(impTrack) object:nil];
                    [self performSelector:@selector(impTrack)
                               withObject:nil
                               afterDelay:self.IMPInterval
                                  inModes:@[NSRunLoopCommonModes]];
                }
            });

        CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    }];
}

- (void)impTrack {
    if (isInResignSate) {
        return;
    }

    if (self.sourceTable.count == 0) {
        return;
    }

    [self.sourceTable.allObjects enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        UIView<GrowingNode> *node = obj;
        if ([node growingImpNodeIsVisible]) {
            if (node.growingIMPTracked == NO) {
                if (node.growingIMPTrackEventName.length > 0) {
                    [self sendCstm:node];
                }
            }
        } else {
            node.growingIMPTracked = NO;
        }
    }];
}

- (void)sendCstm:(UIView<GrowingNode> *)node {
    node.growingIMPTracked = YES;

    NSMutableDictionary *impTrackVariable;
    if (node.growingIMPTrackVariable.count > 0) {
        impTrackVariable = node.growingIMPTrackVariable.mutableCopy;
    } else {
        impTrackVariable = [[NSMutableDictionary alloc] init];
    }
    node.growingIMPTrackVariable = impTrackVariable;

    if (node.growingIMPTrackEventName.length > 0 && node.growingIMPTrackVariable.count > 0) {
        [GrowingEventGenerator generateCustomEvent:node.growingIMPTrackEventName
                                        attributes:node.growingIMPTrackVariable];
    } else if (node.growingIMPTrackEventName.length > 0) {
        [GrowingEventGenerator generateCustomEvent:node.growingIMPTrackEventName attributes:nil];
    }
}

- (void)addNode:(UIView *)node inSubView:(BOOL)flag;
{
    // 如果不可见或者忽略，则不可track
    if ([node growingNodeDonotTrack]) {
        GIOLogVerbose(@"imp track view %@ is donotTrack", node);
        return;
    }
    if (node.growingIMPTrackEventName.length > 0) {
        [self.sourceTable addObject:node];
    }

    if (!flag) {
        return;
    }

    [self enumerateSubViewsWithNode:node
                              block:^(UIView *view) {
                                  if (view.growingIMPTrackEventName.length > 0) {
                                      [self.sourceTable addObject:view];
                                  }
                              }];
}

- (void)addNode:(UIView *)node {
    // 如果不可见或者忽略，则不可track
    if ([node growingNodeDonotTrack]) {
        GIOLogVerbose(@"imp track view %@ is donotTrack", node);
        return;
    }
    if (node.growingIMPTrackEventName.length > 0) {
        [self.sourceTable addObject:node];
    }
}

- (void)clearNode:(UIView *)node {
    node.growingIMPTrackEventName = nil;
    node.growingIMPTrackVariable = nil;
    node.growingIMPTracked = NO;
    [self.sourceTable removeObject:node];
}

#pragma mark - GrowingULAppLifecycleDelegate

- (void)applicationDidBecomeActive {
    if (isInResignSate) {
        [self.bgSourceTable.allObjects
            enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                ((UIView *)obj).growingIMPTracked = NO;
            }];
        isInResignSate = NO;
    }
    [self.bgSourceTable removeAllObjects];
}

- (void)applicationWillResignActive {
    isInResignSate = YES;

    [self.sourceTable.allObjects enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.bgSourceTable addObject:obj];
    }];
}

#pragma mark - GrowingULViewControllerLifecycleDelegate

- (void)viewControllerDidAppear:(UIViewController *)controller {
    [self markInvisibleNodes];
    [self addWindowNodes];
}

@end
