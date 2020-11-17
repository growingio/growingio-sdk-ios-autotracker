//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>
#import "GrowingTrackEventType.h"


@class GrowingBaseBuilder;
typedef NS_ENUM(NSUInteger, GrowingAppState) {
    GrowingAppStateForeground, GrowingAppStateBackground
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

NS_ASSUME_NONNULL_BEGIN

//赋值属性，eg:deviceId,userId,sessionId,globalSequenceId,eventSequenceId
- (void)readPropertyInMainThread;

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

- (GrowingBaseBuilder *(^)(NSString *value))setEventType;
- (GrowingBaseEvent *)build;

NS_ASSUME_NONNULL_END
@end
