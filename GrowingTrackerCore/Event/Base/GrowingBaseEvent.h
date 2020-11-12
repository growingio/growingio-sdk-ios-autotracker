//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>
//
//typedef NS_ENUM(NSUInteger, GrowingEventSendPolicy) {
//    GrowingEventSendPolicyNormal, GrowingEventSendPolicyInstant
//};
typedef NS_ENUM(NSUInteger, GrowingAppState) {
    GrowingAppStateForeground, GrowingAppStateBackground
};

@interface GrowingBaseEvent : NSObject
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceId;
@property(nonatomic, copy, readonly) NSString *_Nullable userId;
@property(nonatomic, copy, readonly) NSString *_Nullable sessionId;
@property(nonatomic, copy, readonly) NSString *_Nonnull eventType;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull timestamp;
@property(nonatomic, copy, readonly) NSString *_Nonnull domain;
@property(nonatomic, copy, readonly) NSString *_Nonnull urlScheme;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull appState;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull globalSequenceId;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull eventSequenceId;
@property(nonatomic, strong, readonly) NSDictionary *_Nonnull extraParams;

- (NSDictionary *_Nonnull)toDictionary;
@end