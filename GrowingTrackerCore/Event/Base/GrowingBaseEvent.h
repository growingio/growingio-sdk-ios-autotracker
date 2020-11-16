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
@property(nonatomic, strong, readonly) NSNumber *_Nonnull appState;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull globalSequenceId;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull eventSequenceId;
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
@property(nonatomic, assign, readonly) long long timestamp;
@property(nonatomic, copy, readonly) NSString *_Nonnull domain;
@property(nonatomic, copy, readonly) NSString *_Nonnull urlScheme;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull appState;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull globalSequenceId;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull eventSequenceId;
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
- (GrowingBaseBuilder *(^)(NSNumber *value))setAppState;
- (GrowingBaseBuilder *(^)(NSNumber *value))setGlobalSequenceId;
- (GrowingBaseBuilder *(^)(NSNumber *value))setEventSequenceId;
- (GrowingBaseBuilder *(^)(NSDictionary *value))setExtraParams;

- (GrowingBaseEvent *)build;

NS_ASSUME_NONNULL_END
@end
