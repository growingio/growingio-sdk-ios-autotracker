//
//  GrowingAppLifecycleManager.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/2/25.
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


#import "GrowingAppLifecycle.h"
#import "GrowingDeviceInfo.h"
#import "GrowingInstance.h"
#import "GrowingEvent.h"
#import "GrowingCustomField.h"
#import "GrowingEventManager.h"
#import "UIApplication+GrowingNode.h"
#import "GrowingMediator.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingCloseEvent.h"
#import "GrowingPageEvent.h"
#import "GrowingBroadcaster.h"

@implementation GrowingAppActivationTime

static BOOL _didStart = YES;

+ (BOOL)didStartFromScratch {
    return _didStart;
}

+ (BOOL)didActivateInShortTime {
    if (_resignActiveDate != nil) {
        NSTimeInterval interval = -[_resignActiveDate timeIntervalSinceNow];
        if (interval > 0 && interval <= [GrowingInstance sharedInstance].configuration.sessionInterval) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)didActivateInLongTime {
    if (_resignActiveDate != nil) {
        NSTimeInterval interval = -[_resignActiveDate timeIntervalSinceNow];
        if (interval > [GrowingInstance sharedInstance].configuration.sessionInterval) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)didActivateInLongTime:(NSDate *)date {
    _resignActiveDate = date;
    return [self didActivateInLongTime];
}

+ (BOOL)isNormal {
    if (_resignActiveDate != nil) {
        NSTimeInterval interval = -[_resignActiveDate timeIntervalSinceNow];
        if (interval <= 0) {
            return YES;
        }
    }
    return NO;
}

+ (void)reset {
    _resignActiveDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*365];
}

@end

@implementation GrowingAppLifecycle

- (void)setupAppStateNotification {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // UIApplication: Process Lifecycle
    for (NSString *name in @[ UIApplicationDidFinishLaunchingNotification,
                              UIApplicationWillTerminateNotification ]) {
        [nc addObserver:self selector:@selector(handleProcessLifecycleNotification:) name:name object:[UIApplication sharedApplication]];
    }
    
    NSDictionary *sceneManifestDict = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIApplicationSceneManifest"];
    
    // UIApplication: UI Lifecycle
    if (!sceneManifestDict) {
        for (NSString *name in @[ UIApplicationDidBecomeActiveNotification,
                                  UIApplicationWillEnterForegroundNotification,
                                  UIApplicationWillResignActiveNotification,
                                  UIApplicationDidEnterBackgroundNotification ]) {
            [nc addObserver:self selector:@selector(handleUILifecycleNotification:) name:name object:[UIApplication sharedApplication]];
        }
    } else {
        // UIScene
        [self addSceneNotification];
    }
}

- (void)handleProcessLifecycleNotification:(NSNotification *)notification {
    
    NSString *name = notification.name;
    
    if ([name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self growingDidFinishLaunchingWithOptions:notification.userInfo];
    } else if ([name isEqualToString:UIApplicationWillTerminateNotification]) {
        [self growingWillTerminate];
    }
}

- (void)handleUILifecycleNotification:(NSNotification *)notification {
    
    NSString *name = notification.name;
    
    if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self growingDidBecomeActive];
    } else if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self growingWillEnterForeground];
    } else if ([name isEqualToString:UIApplicationWillResignActiveNotification]) {
        [self growingWillResignActive];
    } else if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self growingDidEnterBackground];
    }
}

- (void)addSceneNotification {
    
// Usage For Source Code instead static framework!!!
// #if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
// #endif  // defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    
    if (@available(iOS 13, *)) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        // notification name use NSString rather than UISceneWillDeactivateNotification. Xcode 9 package error for no iOS 13 SDK
        // (use of undeclared identifier 'UISceneDidEnterBackgroundNotification'; did you mean 'UIApplicationDidEnterBackgroundNotification'?)
        [nc addObserver:self
               selector:@selector(growingWillResignActive)
                   name:@"UISceneWillDeactivateNotification"
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(growingDidBecomeActive)
                   name:@"UISceneDidActivateNotification"
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(growingWillEnterForeground)
                   name:@"UISceneWillEnterForegroundNotification"
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(growingDidEnterBackground)
                   name:@"UISceneDidEnterBackgroundNotification"
                 object:nil];
    }

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)growingDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    GIOLogDebug(@"applicationDidFinishLaunching");
    [self applicationStateDidChangeWithUserInfo:launchOptions lifecycle:GrowingApplicationDidFinishLaunching];
}

- (void)growingDidBecomeActive {
    GIOLogDebug(@"applicationDidBecomeActive");

    [GrowingEventManager shareInstance].shouldCacheEvent = NO;
    
    //下拉通知栏再拉回来回到主界面,需要判断是否超过30秒(这种情况下不会走applicationWillEnterForeground方法)
    if ([GrowingAppActivationTime didActivateInLongTime]) {
        [[GrowingDeviceInfo currentDeviceInfo] resetSessionID];
        [GrowingVisitEvent send];
        
        //重置session, 发 Visitor 事件
        if ([[GrowingCustomField shareInstance] growingVistorVar]) {
            [[GrowingCustomField shareInstance] sendVisitorEvent:[[GrowingCustomField shareInstance] growingVistorVar]];
        }
    }
    [GrowingAppActivationTime reset];
    
    if ([GrowingAppActivationTime didStartFromScratch]) {
        _didStart = NO;
        //冷启动发送visit
        [GrowingVisitEvent send];
    }
    
    [self applicationStateDidChangeWithUserInfo:nil lifecycle:GrowingApplicationDidBecomeActive];
}

- (void)growingWillEnterForeground {
    GIOLogDebug(@"applicationWillEnterForeground");

    //从后台进入前台超过30s 重置sessionID发visit
    if ([GrowingAppActivationTime didActivateInLongTime]) {
        [[GrowingDeviceInfo currentDeviceInfo] resetSessionID];
        [GrowingVisitEvent send];
        
        //重置session, 发 Visitor 事件
        if ([[GrowingCustomField shareInstance] growingVistorVar]) {
            [[GrowingCustomField shareInstance] sendVisitorEvent:[[GrowingCustomField shareInstance] growingVistorVar]];
        }
    }
    
    [GrowingAppActivationTime reset];
    
    [self applicationStateDidChangeWithUserInfo:nil lifecycle:GrowingApplicationWillEnterForeground];

}

- (void)growingWillResignActive {
    GIOLogDebug(@"applicationWillResignActive");

    [self applicationStateDidChangeWithUserInfo:nil lifecycle:GrowingApplicationWillResignActive];

    _resignActiveDate = [NSDate date];
    
    [[GrowingEventManager shareInstance] sendAllChannelEvents];
    GrowingPageEvent *lastPageEvent= [GrowingEventManager shareInstance].lastPageEvent;
    if(!lastPageEvent) { return; }
    
    [GrowingCloseEvent sendWithLastPage:lastPageEvent.pageName];
}

- (void)growingDidEnterBackground {
    GIOLogDebug(@"applicationDidEnterBackground");

    [self applicationStateDidChangeWithUserInfo:nil lifecycle:GrowingApplicationDidEnterBackground];
}

- (void)growingWillTerminate {

    GIOLogDebug(@"applicationWillTerminateNotification");

    [self applicationStateDidChangeWithUserInfo:nil lifecycle:GrowingApplicationWillTerminate];

    GrowingPageEvent *lastPageEvent= [GrowingEventManager shareInstance].lastPageEvent;
    
    if (!lastPageEvent) { return; }
    
    [GrowingCloseEvent sendWithLastPage:lastPageEvent.pageName];
}

- (void)applicationStateDidChangeWithUserInfo:(NSDictionary *)userInfo lifecycle:(GrowingApplicationLifecycle)lifecycle {
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingApplicationMessage)
                                          usingBlock:^(id<GrowingApplicationMessage>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(applicationStateDidChangedWithUserInfo:lifecycle:)]) {
            [obj applicationStateDidChangedWithUserInfo:userInfo lifecycle:lifecycle];
        }
    }];
}

@end
