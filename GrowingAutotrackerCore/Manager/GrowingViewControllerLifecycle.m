//
//  GrowingViewControllerLifecycle.m
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/23.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingAutotrackerCore/Manager/GrowingViewControllerLifecycle.h"

@interface GrowingViewControllerLifecycle ()
@property (strong, nonatomic, readonly) NSPointerArray *viewControllerLifecycleDelegates;
@property (strong, nonatomic, readonly) NSLock *delegateLock;
@end

@implementation GrowingViewControllerLifecycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _viewControllerLifecycleDelegates = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        _delegateLock = [[NSLock alloc] init];
    }

    return self;
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });

    return _sharedInstance;
}
// for safe sharedInstance
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

- (void)addViewControllerLifecycleDelegate:(id)delegate {
    [self.delegateLock lock];
    if (![self.viewControllerLifecycleDelegates.allObjects containsObject:delegate]) {
        [self.viewControllerLifecycleDelegates addPointer:(__bridge void *)delegate];
    }
    [self.delegateLock unlock];
}

- (void)removeViewControllerLifecycleDelegate:(id)delegate {
    [self.delegateLock lock];
    [self.viewControllerLifecycleDelegates.allObjects
        enumerateObjectsWithOptions:NSEnumerationReverse
                         usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                             if (delegate == obj) {
                                 [self.viewControllerLifecycleDelegates removePointerAtIndex:idx];
                                 *stop = YES;
                             }
                         }];

    [self.delegateLock unlock];
}

- (void)dispatchViewControllerDidAppear:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }
    [self.delegateLock lock];
    for (id delegate in self.viewControllerLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerDidAppear:)]) {
            [delegate viewControllerDidAppear:controller];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchViewControllerDidDisappear:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }

    [self.delegateLock lock];
    for (id delegate in self.viewControllerLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerDidDisappear:)]) {
            [delegate viewControllerDidDisappear:controller];
        }
    }
    [self.delegateLock unlock];
}
@end
