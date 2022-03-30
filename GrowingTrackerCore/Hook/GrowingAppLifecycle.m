//
//  GrowingAppLifecycle.m
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import <UIKit/UIKit.h>
#import "GrowingTrackerCore/Hook/GrowingAppLifecycle.h"

@interface GrowingAppLifecycle ()
@property(strong, nonatomic, readonly) NSPointerArray *appLifecycleDelegates;
@property(strong, nonatomic, readonly) NSLock *delegateLock;
@end

@implementation GrowingAppLifecycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _appLifecycleDelegates = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
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

- (void)setupAppStateNotification {

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    // UIApplication: Process Lifecycle
    for (NSString *name in @[UIApplicationDidFinishLaunchingNotification,
            UIApplicationWillTerminateNotification]) {
        [nc addObserver:self selector:@selector(handleProcessLifecycleNotification:) name:name object:[UIApplication sharedApplication]];
    }

    NSDictionary *sceneManifestDict = [[NSBundle mainBundle] infoDictionary][@"UIApplicationSceneManifest"];

    if (sceneManifestDict && UIDevice.currentDevice.systemVersion.doubleValue >= 13.0) {
        [self addSceneNotification];
    } else {
        for (NSString *name in @[UIApplicationDidBecomeActiveNotification,
                UIApplicationWillEnterForegroundNotification,
                UIApplicationWillResignActiveNotification,
                UIApplicationDidEnterBackgroundNotification]) {
            [nc addObserver:self selector:@selector(handleUILifecycleNotification:) name:name object:[UIApplication sharedApplication]];
        }
    }
}

- (void)addSceneNotification {
    if (@available(iOS 13, *)) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        // notification name use NSString rather than UISceneWillDeactivateNotification. Xcode 9 package error for no iOS 13 SDK
        // (use of undeclared identifier 'UISceneDidEnterBackgroundNotification'; did you mean 'UIApplicationDidEnterBackgroundNotification'?)
        [nc addObserver:self
               selector:@selector(dispatchApplicationWillResignActive)
                   name:@"UISceneWillDeactivateNotification"
                 object:nil];

        [nc addObserver:self
               selector:@selector(dispatchApplicationDidBecomeActive)
                   name:@"UISceneDidActivateNotification"
                 object:nil];

        [nc addObserver:self
               selector:@selector(dispatchApplicationWillEnterForeground)
                   name:@"UISceneWillEnterForegroundNotification"
                 object:nil];

        [nc addObserver:self
               selector:@selector(dispatchApplicationDidEnterBackground)
                   name:@"UISceneDidEnterBackgroundNotification"
                 object:nil];
    }

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleProcessLifecycleNotification:(NSNotification *)notification {

    NSString *name = notification.name;

    if ([name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self dispatchApplicationDidFinishLaunching:notification.userInfo];
    } else if ([name isEqualToString:UIApplicationWillTerminateNotification]) {
        [self dispatchApplicationWillTerminate];
    }
}

- (void)handleUILifecycleNotification:(NSNotification *)notification {

    NSString *name = notification.name;

    if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self dispatchApplicationDidBecomeActive];
    } else if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self dispatchApplicationWillEnterForeground];
    } else if ([name isEqualToString:UIApplicationWillResignActiveNotification]) {
        [self dispatchApplicationWillResignActive];
    } else if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self dispatchApplicationDidEnterBackground];
    }
}

- (void)addAppLifecycleDelegate:(id)delegate {
    [self.delegateLock lock];
    if (![self.appLifecycleDelegates.allObjects containsObject:delegate]) {
        [self.appLifecycleDelegates addPointer:(__bridge void *)delegate];
    }
    [self.delegateLock unlock];
}

- (void)removeAppLifecycleDelegate:(id)delegate {
    [self.delegateLock lock];
    [self.appLifecycleDelegates.allObjects
            enumerateObjectsWithOptions:NSEnumerationReverse
                             usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                 if (delegate == obj) {
                                     [self.appLifecycleDelegates removePointerAtIndex:idx];
                                     *stop = YES;
                                 }
                             }];
    [self.delegateLock unlock];
}

- (void)dispatchApplicationDidFinishLaunching:(NSDictionary *)userInfo {
    [self.delegateLock lock];
    for (id delegate in self.appLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(applicationDidFinishLaunching:)]) {
            [delegate applicationDidFinishLaunching:userInfo];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchApplicationWillTerminate {
    [self.delegateLock lock];
    for (id delegate in self.appLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(applicationWillTerminate)]) {
            [delegate applicationWillTerminate];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchApplicationDidEnterBackground {
    [self.delegateLock lock];
    for (id delegate in self.appLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(applicationDidEnterBackground)]) {
            [delegate applicationDidEnterBackground];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchApplicationDidBecomeActive {
    [self.delegateLock lock];
    for (id delegate in self.appLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(applicationDidBecomeActive)]) {
            [delegate applicationDidBecomeActive];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchApplicationWillResignActive {
    [self.delegateLock lock];
    for (id delegate in self.appLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(applicationWillResignActive)]) {
            [delegate applicationWillResignActive];
        }
    }
    [self.delegateLock unlock];
}

- (void)dispatchApplicationWillEnterForeground {
    [self.delegateLock lock];
    for (id delegate in self.appLifecycleDelegates) {
        if ([delegate respondsToSelector:@selector(applicationWillEnterForeground)]) {
            [delegate applicationWillEnterForeground];
        }
    }
    [self.delegateLock unlock];
}

@end
