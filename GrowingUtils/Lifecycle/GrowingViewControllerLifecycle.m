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

#import "GrowingViewControllerLifecycle.h"
#import "GrowingTimeUtil.h"
#import "GrowingSwizzle.h"
#import <objc/runtime.h>

@interface UIViewController (GrowingUtils)

@property (nonatomic, assign) double growing_loadViewTime;
@property (nonatomic, assign) double growing_viewDidLoadTime;
@property (nonatomic, assign) double growing_viewWillAppearTime;
@property (nonatomic, assign) double growing_viewDidAppearTime;

@end

@interface GrowingViewControllerLifecycle ()

@property (strong, nonatomic, readonly) NSPointerArray *lifecycleDelegates;
@property (strong, nonatomic, readonly) NSLock *delegateLock;

- (void)dispatchViewControllerLoadView:(UIViewController *)controller;
- (void)dispatchViewControllerDidLoad:(UIViewController *)controller;
- (void)dispatchViewControllerWillAppear:(UIViewController *)controller;
- (void)dispatchViewControllerDidAppear:(UIViewController *)controller;
- (void)dispatchViewControllerWillDisappear:(UIViewController *)controller;
- (void)dispatchViewControllerDidDisappear:(UIViewController *)controller;

@end

@implementation UIViewController (GrowingUtils)

- (void)growing_loadView {
    [self growing_loadView];
    self.growing_loadViewTime = [GrowingTimeUtil currentSystemTimeMillis];
    [[GrowingViewControllerLifecycle sharedInstance] dispatchViewControllerLoadView:self];
}

- (void)growing_viewDidLoad {
    [self growing_viewDidLoad];
    self.growing_viewDidLoadTime = [GrowingTimeUtil currentSystemTimeMillis];
    [[GrowingViewControllerLifecycle sharedInstance] dispatchViewControllerDidLoad:self];
}

- (void)growing_viewWillAppear:(BOOL)animated {
    [self growing_viewWillAppear:animated];
    self.growing_viewWillAppearTime = [GrowingTimeUtil currentSystemTimeMillis];
    [[GrowingViewControllerLifecycle sharedInstance] dispatchViewControllerWillAppear:self];
}

- (void)growing_viewDidAppear:(BOOL)animated {
    [self growing_viewDidAppear:animated];
    self.growing_DidAppear = YES;
    self.growing_viewDidAppearTime = [GrowingTimeUtil currentSystemTimeMillis];
    [[GrowingViewControllerLifecycle sharedInstance] dispatchViewControllerDidAppear:self];
}

- (void)growing_viewWillDisappear:(BOOL)animated {
    [self growing_viewWillDisappear:animated];
    [GrowingViewControllerLifecycle.sharedInstance dispatchViewControllerWillDisappear:self];
}

- (void)growing_viewDidDisappear:(BOOL)animated {
    [self growing_viewDidDisappear:animated];
    [GrowingViewControllerLifecycle.sharedInstance dispatchViewControllerDidDisappear:self];
}

- (double)growing_loadViewTime {
    return ((NSNumber *)objc_getAssociatedObject(self, _cmd)).doubleValue;
}

- (void)setGrowing_loadViewTime:(double)time {
    objc_setAssociatedObject(self, @selector(growing_loadViewTime), @(time), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (double)growing_viewDidLoadTime {
    return ((NSNumber *)objc_getAssociatedObject(self, _cmd)).doubleValue;
}

- (void)setGrowing_viewDidLoadTime:(double)time {
    objc_setAssociatedObject(self, @selector(growing_viewDidLoadTime), @(time), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (double)growing_viewWillAppearTime {
    return ((NSNumber *)objc_getAssociatedObject(self, _cmd)).doubleValue;
}

- (void)setGrowing_viewWillAppearTime:(double)time {
    objc_setAssociatedObject(self, @selector(growing_viewWillAppearTime), @(time), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (double)growing_viewDidAppearTime {
    return ((NSNumber *)objc_getAssociatedObject(self, _cmd)).doubleValue;
}

- (void)setGrowing_viewDidAppearTime:(double)time {
    objc_setAssociatedObject(self, @selector(growing_viewDidAppearTime), @(time), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)growing_DidAppear {
    return ((NSNumber *)objc_getAssociatedObject(self, _cmd)).boolValue;
}

- (void)setGrowing_DidAppear:(BOOL)growing_DidAppear {
    objc_setAssociatedObject(self, @selector(growing_DidAppear), @(growing_DidAppear), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation GrowingViewControllerLifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _lifecycleDelegates = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        _delegateLock = [[NSLock alloc] init];
    }

    return self;
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

+ (void)setup {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self sharedInstance] setupPageStateNotification];
    });
}

- (void)setupPageStateNotification {
    [UIViewController growing_swizzleMethod:@selector(loadView)
                                 withMethod:@selector(growing_loadView)
                                      error:nil];

    [UIViewController growing_swizzleMethod:@selector(viewDidLoad)
                                 withMethod:@selector(growing_viewDidLoad)
                                      error:nil];
    
    [UIViewController growing_swizzleMethod:@selector(viewWillAppear:)
                                 withMethod:@selector(growing_viewWillAppear:)
                                      error:nil];
    
    [UIViewController growing_swizzleMethod:@selector(viewDidAppear:)
                                 withMethod:@selector(growing_viewDidAppear:)
                                      error:nil];
    
    [UIViewController growing_swizzleMethod:@selector(viewWillDisappear:)
                                 withMethod:@selector(growing_viewWillDisappear:)
                                      error:nil];
    
    [UIViewController growing_swizzleMethod:@selector(viewDidDisappear:)
                                 withMethod:@selector(growing_viewDidDisappear:)
                                      error:nil];
}

- (void)addViewControllerLifecycleDelegate:(id <GrowingViewControllerLifecycleDelegate>)delegate {
    [self.delegateLock lock];
    if (![self.lifecycleDelegates.allObjects containsObject:delegate]) {
        [self.lifecycleDelegates addPointer:(__bridge void *)delegate];
    }
    [self.delegateLock unlock];
}

- (void)removeViewControllerLifecycleDelegate:(id <GrowingViewControllerLifecycleDelegate>)delegate {
    [self.delegateLock lock];
    [self.lifecycleDelegates.allObjects enumerateObjectsWithOptions:NSEnumerationReverse
                                                            usingBlock:^(NSObject *obj,
                                                                         NSUInteger idx,
                                                                         BOOL *_Nonnull stop) {
        if (delegate == obj) {
            [self.lifecycleDelegates removePointerAtIndex:idx];
            *stop = YES;
        }
    }];
    [self.delegateLock unlock];
}

- (void)dispatchViewControllerLoadView:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }
    [self.delegateLock lock];
    for (id delegate in self.lifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerLoadView:)]) {
            [delegate viewControllerLoadView:controller];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchViewControllerDidLoad:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }
    [self.delegateLock lock];
    for (id delegate in self.lifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerDidLoad:)]) {
            [delegate viewControllerDidLoad:controller];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchViewControllerWillAppear:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }
    [self.delegateLock lock];
    for (id delegate in self.lifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerWillAppear:)]) {
            [delegate viewControllerWillAppear:controller];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchViewControllerDidAppear:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }
    [self.delegateLock lock];
    for (id delegate in self.lifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerDidAppear:)]) {
            [delegate viewControllerDidAppear:controller];
        }
        
        if ([delegate respondsToSelector:@selector(pageLoadCompletedWithViewController:
                                                   loadViewTime:
                                                   viewDidLoadTime:
                                                   viewWillAppearTime:
                                                   viewDidAppearTime:)]) {
            [delegate pageLoadCompletedWithViewController:controller
                                             loadViewTime:controller.growing_loadViewTime
                                          viewDidLoadTime:controller.growing_viewDidLoadTime
                                       viewWillAppearTime:controller.growing_viewWillAppearTime
                                        viewDidAppearTime:controller.growing_viewDidAppearTime];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchViewControllerWillDisappear:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }

    [self.delegateLock lock];
    for (id delegate in self.lifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerWillDisappear:)]) {
            [delegate viewControllerWillDisappear:controller];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchViewControllerDidDisappear:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }

    [self.delegateLock lock];
    for (id delegate in self.lifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(viewControllerDidDisappear:)]) {
            [delegate viewControllerDidDisappear:controller];
        }
    }
    [self.delegateLock unlock];
}

@end
