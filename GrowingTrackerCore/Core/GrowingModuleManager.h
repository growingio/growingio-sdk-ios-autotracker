//
// GrowingModuleManager.h
// GrowingAnalytics
//
//  Created by sheng on 2021/6/17.
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


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GrowingModuleLevel)
{
    GrowingModuleBasic  = 0,
    GrowingModuleNormal = 1
};

typedef NS_ENUM(NSInteger, GrowingModuleEventType)
{
    GrowingMSetupEvent = 0,
    GrowingMInitEvent,
    GrowingMTearDownEvent,
    GrowingMSplashEvent,
    GrowingMQuickActionEvent,
    GrowingMWillResignActiveEvent,
    GrowingMDidEnterBackgroundEvent,
    GrowingMWillEnterForegroundEvent,
    GrowingMDidBecomeActiveEvent,
    GrowingMWillTerminateEvent,
    GrowingMUnmountEvent,
    GrowingMOpenURLEvent,
    GrowingMDidReceiveMemoryWarningEvent,
    GrowingMDidFailToRegisterForRemoteNotificationsEvent,
    GrowingMDidRegisterForRemoteNotificationsEvent,
    GrowingMDidReceiveRemoteNotificationEvent,
    GrowingMDidReceiveLocalNotificationEvent,
    GrowingMWillPresentNotificationEvent,
    GrowingMDidReceiveNotificationResponseEvent,
    GrowingMWillContinueUserActivityEvent,
    GrowingMContinueUserActivityEvent,
    GrowingMDidFailToContinueUserActivityEvent,
    GrowingMDidUpdateUserActivityEvent,
    GrowingMHandleWatchKitExtensionRequestEvent,
    GrowingMDidCustomEvent = 1000
    
};

NS_ASSUME_NONNULL_BEGIN

@interface GrowingModuleManager : NSObject

+ (instancetype)sharedInstance;

// If you do not comply with set Level protocol, the default Normal
- (void)registerDynamicModule:(Class)moduleClass;

- (void)unRegisterDynamicModule:(Class)moduleClass;

//- (void)loadLocalModules;

- (void)registedAllModules;

- (void)registerCustomEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr;

- (void)triggerEvent:(NSInteger)eventType;

- (void)triggerEvent:(NSInteger)eventType
     withCustomParam:(NSDictionary *)customParam;

@end

NS_ASSUME_NONNULL_END
