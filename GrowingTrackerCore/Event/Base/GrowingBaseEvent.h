//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>
#import "GrowingTrackEventType.h"


@class GrowingBaseBuilder;

typedef NS_ENUM(NSUInteger, GrowingAppState) {
    GrowingAppStateForeground, GrowingAppStateBackground
};

typedef NS_OPTIONS(NSUInteger, GrowingEventSendPolicy) {
    GrowingEventSendPolicyInstant = 1 << 0,    /// 实时发送（目前仅VISIT事件为实时发送策略）
    GrowingEventSendPolicyMobileData = 1 << 1, /// 移动网络流量发送
    GrowingEventSendPolicyWiFi = 1 << 2,       /// 仅WiFi可发送（特殊事件数据，如大文件等）
};


@interface GrowingBaseEvent : NSObject
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceId;
@property(nonatomic, copy, readonly) NSString *_Nullable userId;
@property(nonatomic, copy, readonly) NSString *_Nullable sessionId;
@property(nonatomic, copy, readonly) NSString *_Nonnull eventType;
@property(nonatomic, assign, readonly) long long timestamp;
@property(nonatomic, copy, readonly) NSString *_Nonnull domain;
@property(nonatomic, copy, readonly) NSString *_Nonnull urlScheme;
@property(nonatomic, assign, readonly) int appState;
@property(nonatomic, assign, readonly) long long globalSequenceId;
@property(nonatomic, assign, readonly) long long eventSequenceId;
@property(nonatomic, copy, readonly) NSString *_Nonnull platform;
@property(nonatomic, copy, readonly) NSString *_Nonnull platformVersion;
@property(nonatomic, strong, readonly) NSDictionary *_Nonnull extraParams;
@property(nonatomic, copy, readonly) NSString *_Nullable networkState;
@property(nonatomic, copy, readonly) NSString *_Nullable appChannel;
@property(nonatomic, assign, readonly) NSInteger screenHeight;
@property(nonatomic, assign, readonly) NSInteger screenWidth;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceBrand;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceModel;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceType;
@property(nonatomic, copy, readonly) NSString *_Nonnull appName;
@property(nonatomic, copy, readonly) NSString *_Nonnull appVersion;
@property(nonatomic, copy, readonly) NSString *_Nonnull language;
@property(nonatomic, assign, readonly) double latitude;
@property(nonatomic, assign, readonly) double longitude;
@property(nonatomic, copy, readonly) NSString *_Nonnull sdkVersion;
@property(nonatomic, copy, readonly) NSString *_Nullable userKey;

@property (nonatomic, assign) GrowingEventSendPolicy sendPolicy;

- (NSDictionary *_Nonnull)toDictionary;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithBuilder:(GrowingBaseBuilder*_Nonnull)builder;
//subclass overload this method,change return type
+ (GrowingBaseBuilder *_Nonnull)builder;

@end

///builder
@interface GrowingBaseBuilder : NSObject

@property(nonatomic, copy, readonly) NSString *_Nonnull deviceId;
@property(nonatomic, copy, readonly) NSString *_Nullable userId;
@property(nonatomic, copy, readonly) NSString *_Nullable sessionId;
@property(nonatomic, copy, readonly) NSString *_Nonnull eventType;
@property(nonatomic, assign, readonly) long long timestamp;
@property(nonatomic, copy, readonly) NSString *_Nonnull domain;
@property(nonatomic, copy, readonly) NSString *_Nonnull urlScheme;
@property(nonatomic, assign, readonly) int appState;
@property(nonatomic, assign, readonly) long long globalSequenceId;
@property(nonatomic, assign, readonly) long long eventSequenceId;
@property(nonatomic, copy, readonly) NSString *_Nonnull platform;
@property(nonatomic, copy, readonly) NSString *_Nonnull platformVersion;
@property(nonatomic, strong, readonly) NSDictionary *_Nonnull extraParams;
@property(nonatomic, copy, readonly) NSString *_Nullable networkState;
@property(nonatomic, copy, readonly) NSString *_Nullable appChannel;
@property(nonatomic, assign, readonly) NSInteger screenHeight;
@property(nonatomic, assign, readonly) NSInteger screenWidth;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceBrand;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceModel;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceType;
@property(nonatomic, copy, readonly) NSString *_Nonnull appName;
@property(nonatomic, copy, readonly) NSString *_Nonnull appVersion;
@property(nonatomic, copy, readonly) NSString *_Nonnull language;
@property(nonatomic, assign, readonly) double latitude;
@property(nonatomic, assign, readonly) double longitude;
@property(nonatomic, copy, readonly) NSString *_Nonnull sdkVersion;
@property(nonatomic, copy, readonly) NSString *_Nullable userKey;

NS_ASSUME_NONNULL_BEGIN

//赋值属性，eg:deviceId,userId,sessionId,globalSequenceId,eventSequenceId
- (void)readPropertyInTrackThread;

- (GrowingBaseBuilder *(^)(NSString *value))setDeviceId;
- (GrowingBaseBuilder *(^)(NSString *value))setUserId;
- (GrowingBaseBuilder *(^)(NSString *value))setSessionId;
- (GrowingBaseBuilder *(^)(long long value))setTimestamp;
- (GrowingBaseBuilder *(^)(NSString *value))setDomain;
- (GrowingBaseBuilder *(^)(NSString *value))setUrlScheme;
- (GrowingBaseBuilder *(^)(int value))setAppState;
- (GrowingBaseBuilder *(^)(long long value))setGlobalSequenceId;
- (GrowingBaseBuilder *(^)(long long value))setEventSequenceId;
- (GrowingBaseBuilder *(^)(NSString *value))setPlatform;
- (GrowingBaseBuilder *(^)(NSString *value))setPlatformVersion;
- (GrowingBaseBuilder *(^)(NSDictionary *value))setExtraParams;
- (GrowingBaseBuilder *(^)(NSString *value))setNetworkState;
- (GrowingBaseBuilder *(^)(NSInteger value))setScreenHeight;
- (GrowingBaseBuilder *(^)(NSInteger value))setScreenWidth;
- (GrowingBaseBuilder *(^)(NSString *value))setDeviceBrand;
- (GrowingBaseBuilder *(^)(NSString *value))setDeviceModel;
- (GrowingBaseBuilder *(^)(NSString *value))setDeviceType;
- (GrowingBaseBuilder *(^)(NSString *value))setAppName;
- (GrowingBaseBuilder *(^)(NSString *value))setAppVersion;
- (GrowingBaseBuilder *(^)(NSString *value))setLanguage;
- (GrowingBaseBuilder *(^)(double value))setLatitude;
- (GrowingBaseBuilder *(^)(double value))setLongitude;
- (GrowingBaseBuilder *(^)(NSString *value))setSdkVersion;
- (GrowingBaseBuilder *(^)(NSString *value))setUserKey;

- (GrowingBaseBuilder *(^)(NSString *value))setEventType;
- (GrowingBaseEvent *)build;

NS_ASSUME_NONNULL_END
@end
