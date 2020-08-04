//
//  GrowingIMPTrack.m
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2019/5/9.
//  Copyright (C) 2019 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingIMPTrack.h"
#import "GrowingDispatchManager.h"
#import "UIView+GrowingNode.h"
#import "UIApplication+GrowingNode.h"
#import "GrowingBroadcaster.h"

@GrowingBroadcasterRegister(GrowingViewControlerLifecycleMessage, GrowingIMPTrack)
@GrowingBroadcasterRegister(GrowingApplicationMessage, GrowingIMPTrack)
@interface GrowingIMPTrack() <GrowingApplicationMessage, GrowingViewControlerLifecycleMessage>

@property (nonatomic, strong) NSHashTable *sourceTable;
@property (nonatomic, strong) NSHashTable *bgSourceTable;

@end

static BOOL isInResignSate;

@implementation GrowingIMPTrack


#pragma mark - GrowingApplicationMessage

+ (void)applicationStateDidChangedWithUserInfo:(NSDictionary * _Nullable)userInfo lifecycle:(GrowingApplicationLifecycle)lifecycle {
    switch (lifecycle) {
        case GrowingApplicationWillResignActive:
            [[GrowingIMPTrack shareInstance] resignActive];
            break;
        case GrowingApplicationDidBecomeActive:
            [[GrowingIMPTrack shareInstance] becomeActive];
            break;
        default:
            break;
    }
}

#pragma mark - GrowingViewControlerLifecycleMessage


- (void)viewControllerLifecycleDidChanged:(GrowingVCLifecycle)lifecycle {
    switch (lifecycle) {
        case GrowingVCLifecycleDidAppear:{
            [[GrowingIMPTrack shareInstance] markInvisibleNodes];
            [[GrowingIMPTrack shareInstance] addWindowNodes];
        } break;

        default:
            break;
    }
}

- (void)becomeActive {
    if (isInResignSate) {
        [self.bgSourceTable.allObjects
            enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                         BOOL *_Nonnull stop) {
                ((UIView *)obj).growingIMPTracked = NO;
            }];
        isInResignSate = NO;
    }
    [self.bgSourceTable removeAllObjects];
}

- (void)resignActive {
    isInResignSate = YES;

    [self.sourceTable.allObjects
        enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                     BOOL *_Nonnull stop) {
            [self.bgSourceTable addObject:obj];
        }];
}

- (void)markInvisibleNodes {
    if (self.sourceTable.count == 0) {
        return;
    }
    [self.sourceTable.allObjects
        enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                     BOOL *_Nonnull stop) {
            UIView<GrowingNode> *node = obj;
            if (![node growingImpNodeIsVisible]) {
                node.growingIMPTracked = NO;
            }
        }];
}

- (void)markInvisibleNode:(UIView *)node inSubView:(BOOL)flag;
{
    if (node.growingIMPTrackEventId > 0) {
        node.growingIMPTracked = NO;
    }

    if (flag) {
        [self enumerateSubViewsWithNode:node
                                  block:^(UIView *view) {
                                      if (view.growingIMPTrackEventId > 0) {
                                          view.growingIMPTracked = NO;
                                      }
                                  }];
    }
}

- (void)addWindowNodes {
    [self.sourceTable removeAllObjects];

    UIWindow *window = [[UIApplication sharedApplication] growingMainWindow];

    if (window) {
        [self enumerateSubViewsWithNode:window
                                  block:^(UIView *view) {
                                      [self addNode:view];
                                  }];
    }
}

- (void)enumerateSubViewsWithNode:(UIView *)node
                            block:(void (^)(UIView *view))block {
    if (!self.impTrackActive) {
        return;
    }

    NSArray *array = node.subviews;
    for (UIView *subView in array) {
        block(subView);
        [self enumerateSubViewsWithNode:subView block:block];
    }
}

static GrowingIMPTrack *impTrack = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        impTrack = [[GrowingIMPTrack alloc] init];
        impTrack.IMPInterval = 0.0;
    });
    return impTrack;
}

- (instancetype)init {

    if (impTrack != nil) { return nil; }
    
    if (self =[super init]) {
        self.sourceTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory |
                            NSPointerFunctionsObjectPointerPersonality
                   capacity:100];
    }
    return self;
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
        CFOptionFlags activities =
            (kCFRunLoopBeforeWaiting |  // before the run loop starts sleeping
             kCFRunLoopExit);           // before exiting a runloop run

        observer = CFRunLoopObserverCreateWithHandler(
            NULL,         // allocator
            activities,   // activities
            YES,          // repeats
            INT_MAX - 1,  // order after CA transaction commits
            ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                if (self.IMPInterval == 0.0) {
                    [self impTrack];
                } else {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                             selector:@selector
                                                             (impTrack)
                                                               object:nil];
                    [self performSelector:@selector(impTrack)
                               withObject:nil
                               afterDelay:self.IMPInterval
                                  inModes:@[ NSRunLoopCommonModes ]];
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

    [self.sourceTable.allObjects
        enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                     BOOL *_Nonnull stop) {
            UIView<GrowingNode> *node = obj;
            if ([node growingImpNodeIsVisible]) {
                if (node.growingIMPTracked == NO) {
                    if (node.growingIMPTrackEventId.length > 0) {
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

    NSString *v = [node growingNodeContent];

    if (v.length > 0 && v.length <= 50) {
        NSMutableDictionary *impTrackVariable;
        if (node.growingIMPTrackVariable.count > 0) {
            impTrackVariable = node.growingIMPTrackVariable.mutableCopy;
        } else {
            impTrackVariable = [[NSMutableDictionary alloc] init];
        }
        impTrackVariable[@"gio_v"] = v;
        node.growingIMPTrackVariable = impTrackVariable;
    }

    if (node.growingIMPTrackEventId.length > 0 && node.growingIMPTrackNumber &&
        node.growingIMPTrackVariable.count > 0) {
        [Growing trackCustomEvent:node.growingIMPTrackEventId
                   withAttributes:node.growingIMPTrackVariable];
    } else if (node.growingIMPTrackEventId.length > 0 &&
               node.growingIMPTrackNumber) {
        [Growing trackCustomEvent:node.growingIMPTrackEventId];
    } else if (node.growingIMPTrackEventId.length > 0 &&
               node.growingIMPTrackVariable.count > 0) {
        [Growing trackCustomEvent:node.growingIMPTrackEventId
                   withAttributes:node.growingIMPTrackVariable];
    } else if (node.growingIMPTrackEventId.length > 0) {
        [Growing trackCustomEvent:node.growingIMPTrackEventId];
    }
}

- (void)addNode:(UIView *)node inSubView:(BOOL)flag;
{
    if (node.growingIMPTrackEventId.length > 0) {
        [self.sourceTable addObject:node];
    }

    if (flag) {
        [self enumerateSubViewsWithNode:node
                                  block:^(UIView *view) {
                                      if (view.growingIMPTrackEventId.length >
                                          0) {
                                          [self.sourceTable addObject:view];
                                      }
                                  }];
    }
}

- (void)addNode:(UIView *)node {
    if (node.growingIMPTrackEventId.length > 0) {
        [self.sourceTable addObject:node];
    }
}

- (void)clearNode:(UIView *)node {
    node.growingIMPTrackEventId = nil;
    node.growingIMPTrackNumber = nil;
    node.growingIMPTrackVariable = nil;
    node.growingIMPTracked = NO;
    [self.sourceTable removeObject:node];
}

@end
