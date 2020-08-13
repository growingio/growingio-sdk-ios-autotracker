//
//  GrowingEventProtocol.h
//  GrowingTracker
//
//  Created by GrowingIO on 2020/7/6.
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


#import <Foundation/Foundation.h>
@class GrowingConfiguration;

typedef NS_ENUM(NSUInteger, GrowingApplicationLifecycle) {
    GrowingApplicationDidFinishLaunching,
    GrowingApplicationWillTerminate,
    GrowingApplicationDidEnterBackground,
    GrowingApplicationDidBecomeActive,
    GrowingApplicationWillResignActive,
    GrowingApplicationWillEnterForeground,
    GrowingApplicationDidReceiveRemoteNotification,
};

typedef NS_ENUM(NSInteger, GrowingManualTrackEventType) {
    GrowingManualTrackEvarEventType,
    GrowingManualTrackCustomEventType,
    GrowingManualTrackPeopleVarEventType,
    GrowingManualTrackVisitorEventType
};

typedef NS_ENUM(NSUInteger, GrowingVCLifecycle) {
    GrowingVCLifecycleWillAppear,
    GrowingVCLifecycleDidAppear,
    GrowingVCLifecycleWillDisappear,
    GrowingVCLifecycleDidDisappear,
};

typedef NS_ENUM (NSUInteger, GrowingMonitorState) {
    GrowingMonitorStateUploadExceptionDefault,
    GrowingMonitorStateUploadExceptionEnable,
    GrowingMonitorStateUploadExceptionDisable,
};

NS_ASSUME_NONNULL_BEGIN

/// 通过的消息接口
@protocol GrowingMessageProtocol <NSObject>

@end

/// Application 生命周期相关的消息
@protocol GrowingApplicationMessage <NSObject, GrowingMessageProtocol>

@optional
+ (void)applicationStateDidChangedWithUserInfo:(NSDictionary * _Nullable)userInfo lifecycle:(GrowingApplicationLifecycle)lifecycle;

@end

/// VC 生命周期相关的消息
@protocol GrowingViewControlerLifecycleMessage <NSObject, GrowingMessageProtocol>

@optional
- (void)viewControllerLifecycleDidChanged:(GrowingVCLifecycle)lifecycle;

@end

/// 埋点库初始化完毕
@protocol GrowingTrackerConfigurationMessage <NSObject, GrowingMessageProtocol>

@optional
+ (void)growingTrackerConfigurationDidChanged:(GrowingConfiguration *)configuration;

@end

/// 手动track某个事件相关的消息（包括 vstr, cstm, evar, pvar）
@protocol GrowingManualTrackMessage <NSObject, GrowingMessageProtocol>

- (void)manualEventDidTrackWithUserInfo:(NSDictionary * _Nullable)userInfo manualTrackEventType:(GrowingManualTrackEventType)eventType;

@end

/// 用户userId 发送改变时发送的消息
@protocol GrowingUserIdChangedMeessage <NSObject, GrowingMessageProtocol>

- (void)userIdDidChangedFrom:(NSString *)oldValue to:(NSString *)newValue;

@end

/// Monitor 开启状态消息
@protocol GrowingMonitorMeessage <NSObject, GrowingMessageProtocol>

+ (void)monitorStateDidSettingWithState:(GrowingMonitorState)monitorState userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
