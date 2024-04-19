//
// GrowingBaseEvent.h
// GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
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

NS_ASSUME_NONNULL_BEGIN

@class GrowingBaseBuilder;

typedef NS_ENUM(NSUInteger, GrowingAppState) { GrowingAppStateForeground, GrowingAppStateBackground };

typedef NS_OPTIONS(NSUInteger, GrowingEventSendPolicy) {
    GrowingEventSendPolicyInstant = 1 << 0,     /// 实时发送（目前仅VISIT事件为实时发送策略）
    GrowingEventSendPolicyMobileData = 1 << 1,  /// 移动网络流量发送
    GrowingEventSendPolicyWiFi = 1 << 2,        /// 仅WiFi可发送（特殊事件数据，如大文件等）
};

typedef NS_ENUM(NSUInteger, GrowingEventScene) {
    GrowingEventSceneNative = 0,
    GrowingEventSceneHybrid,
    GrowingEventSceneFlutter
};

@interface GrowingBaseEvent : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *dataSourceId;
@property (nonatomic, copy, readonly) NSString *deviceId;
@property (nonatomic, copy, readonly, nullable) NSString *userId;
@property (nonatomic, copy, readonly, nullable) NSString *sessionId;
@property (nonatomic, copy, readonly) NSString *eventType;
@property (nonatomic, assign, readonly) long long timestamp;
@property (nonatomic, copy, readonly) NSString *domain;
@property (nonatomic, copy, readonly) NSString *urlScheme;
@property (nonatomic, assign, readonly) int appState;
@property (nonatomic, assign, readonly) long long eventSequenceId;
@property (nonatomic, copy, readonly) NSString *platform;
@property (nonatomic, copy, readonly) NSString *platformVersion;
@property (nonatomic, strong, readonly) NSDictionary *extraParams;
@property (nonatomic, copy, readonly, nullable) NSString *networkState;
@property (nonatomic, copy, readonly, nullable) NSString *appChannel;
@property (nonatomic, assign, readonly) NSInteger screenHeight;
@property (nonatomic, assign, readonly) NSInteger screenWidth;
@property (nonatomic, copy, readonly, nullable) NSString *deviceBrand;
@property (nonatomic, copy, readonly, nullable) NSString *deviceModel;
@property (nonatomic, copy, readonly, nullable) NSString *deviceType;
@property (nonatomic, copy, readonly) NSString *appName;
@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *language;
@property (nonatomic, assign, readonly) double latitude;
@property (nonatomic, assign, readonly) double longitude;
@property (nonatomic, copy, readonly) NSString *sdkVersion;
@property (nonatomic, copy, readonly, nullable) NSString *userKey;
@property (nonatomic, copy, readonly) NSString *timezoneOffset;
@property (nonatomic, assign, readonly) GrowingEventScene scene;
@property (nonatomic, assign) GrowingEventSendPolicy sendPolicy;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *attributes;

- (NSDictionary *_Nonnull)toDictionary;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithBuilder:(GrowingBaseBuilder *_Nonnull)builder;
// subclass overload this method,change return type
+ (GrowingBaseBuilder *_Nonnull)builder;

@end

/// builder
@interface GrowingBaseBuilder : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *dataSourceId;
@property (nonatomic, copy, readonly) NSString *deviceId;
@property (nonatomic, copy, readonly, nullable) NSString *userId;
@property (nonatomic, copy, readonly, nullable) NSString *sessionId;
@property (nonatomic, copy, readonly) NSString *eventType;
@property (nonatomic, assign, readonly) long long timestamp;
@property (nonatomic, copy, readonly) NSString *domain;
@property (nonatomic, copy, readonly) NSString *urlScheme;
@property (nonatomic, assign, readonly) int appState;
@property (nonatomic, assign, readonly) long long eventSequenceId;
@property (nonatomic, copy, readonly) NSString *platform;
@property (nonatomic, copy, readonly) NSString *platformVersion;
@property (nonatomic, strong, readonly) NSDictionary *extraParams;
@property (nonatomic, copy, readonly, nullable) NSString *networkState;
@property (nonatomic, copy, readonly, nullable) NSString *appChannel;
@property (nonatomic, assign, readonly) NSInteger screenHeight;
@property (nonatomic, assign, readonly) NSInteger screenWidth;
@property (nonatomic, copy, readonly, nullable) NSString *deviceBrand;
@property (nonatomic, copy, readonly, nullable) NSString *deviceModel;
@property (nonatomic, copy, readonly, nullable) NSString *deviceType;
@property (nonatomic, copy, readonly) NSString *appName;
@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *language;
@property (nonatomic, assign, readonly) double latitude;
@property (nonatomic, assign, readonly) double longitude;
@property (nonatomic, copy, readonly) NSString *sdkVersion;
@property (nonatomic, copy, readonly, nullable) NSString *userKey;
@property (nonatomic, copy, readonly) NSString *timezoneOffset;
@property (nonatomic, assign, readonly) GrowingEventScene scene;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *attributes;

- (void)readPropertyInTrackThread;

- (GrowingBaseBuilder * (^)(NSString *value))setDataSourceId;
- (GrowingBaseBuilder * (^)(NSString *value))setDeviceId;
- (GrowingBaseBuilder * (^)(NSString *value))setUserId;
- (GrowingBaseBuilder * (^)(NSString *value))setSessionId;
- (GrowingBaseBuilder * (^)(long long value))setTimestamp;
- (GrowingBaseBuilder * (^)(NSString *value))setDomain;
- (GrowingBaseBuilder * (^)(NSString *value))setUrlScheme;
- (GrowingBaseBuilder * (^)(int value))setAppState;
- (GrowingBaseBuilder * (^)(long long value))setEventSequenceId;
- (GrowingBaseBuilder * (^)(NSString *value))setPlatform;
- (GrowingBaseBuilder * (^)(NSString *value))setPlatformVersion;
- (GrowingBaseBuilder * (^)(NSDictionary *value))setExtraParams;
- (GrowingBaseBuilder * (^)(NSString *value))setNetworkState;
- (GrowingBaseBuilder * (^)(NSInteger value))setScreenHeight;
- (GrowingBaseBuilder * (^)(NSInteger value))setScreenWidth;
- (GrowingBaseBuilder * (^)(NSString *value))setDeviceBrand;
- (GrowingBaseBuilder * (^)(NSString *value))setDeviceModel;
- (GrowingBaseBuilder * (^)(NSString *value))setDeviceType;
- (GrowingBaseBuilder * (^)(NSString *value))setAppName;
- (GrowingBaseBuilder * (^)(NSString *value))setAppVersion;
- (GrowingBaseBuilder * (^)(NSString *value))setLanguage;
- (GrowingBaseBuilder * (^)(double value))setLatitude;
- (GrowingBaseBuilder * (^)(double value))setLongitude;
- (GrowingBaseBuilder * (^)(NSString *value))setSdkVersion;
- (GrowingBaseBuilder * (^)(NSString *value))setUserKey;
- (GrowingBaseBuilder * (^)(NSString *value))setEventType;
- (GrowingBaseBuilder * (^)(NSString *value))setTimezoneOffset;
- (GrowingBaseBuilder * (^)(GrowingEventScene value))setScene;
- (GrowingBaseBuilder * (^)(NSDictionary<NSString *, id> *value))setAttributes;
- (GrowingBaseEvent *)build;

@end

NS_ASSUME_NONNULL_END
