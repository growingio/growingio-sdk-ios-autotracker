//
// GrowingModuleProtocol.h
// Pods
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
#import "GrowingAnnotationCore.h"
@class GrowingContext;


#define GROW_EXPORT_MODULE(isAsync) \
+ (void)load { [[GrowingModuleManager sharedInstance] registerDynamicModule:[self class]]; } \
-(BOOL)async { return [[NSString stringWithUTF8String:#isAsync] boolValue];}

@protocol GrowingModuleProtocol <NSObject>


@optional

+ (BOOL)singleton;
//越大越优先
- (NSInteger)modulePriority;

- (BOOL)async;

//如果不去设置Level默认是Normal
//basicModuleLevel不去实现默认Normal
- (void)basicModuleLevel;

- (void)growingModSetUp:(GrowingContext *)context;

- (void)growingModInit:(GrowingContext *)context;

- (void)growingModSplash:(GrowingContext *)context;

- (void)growingModQuickAction:(GrowingContext *)context;

- (void)growingModTearDown:(GrowingContext *)context;

- (void)growingModWillResignActive:(GrowingContext *)context;

- (void)growingModDidEnterBackground:(GrowingContext *)context;

- (void)growingModWillEnterForeground:(GrowingContext *)context;

- (void)growingModDidBecomeActive:(GrowingContext *)context;

- (void)growingModWillTerminate:(GrowingContext *)context;

- (void)growingModUnmount:(GrowingContext *)context;

- (void)growingModOpenURL:(GrowingContext *)context;

- (void)growingModDidReceiveMemoryWaring:(GrowingContext *)context;

- (void)growingModDidFailToRegisterForRemoteNotifications:(GrowingContext *)context;

- (void)growingModDidRegisterForRemoteNotifications:(GrowingContext *)context;

- (void)growingModDidReceiveRemoteNotification:(GrowingContext *)context;

- (void)growingModDidReceiveLocalNotification:(GrowingContext *)context;

- (void)growingModWillPresentNotification:(GrowingContext *)context;

- (void)growingModDidReceiveNotificationResponse:(GrowingContext *)context;

- (void)growingModWillContinueUserActivity:(GrowingContext *)context;

- (void)growingModContinueUserActivity:(GrowingContext *)context;

- (void)growingModDidFailToContinueUserActivity:(GrowingContext *)context;

- (void)growingModDidUpdateContinueUserActivity:(GrowingContext *)context;

- (void)growingModHandleWatchKitExtensionRequest:(GrowingContext *)context;

- (void)growingModDidCustomEvent:(GrowingContext *)context;

@end
