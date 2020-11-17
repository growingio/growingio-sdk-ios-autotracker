//
// Created by xiangyang on 2020/11/10.
//

#import <Foundation/Foundation.h>


@protocol GrowingUserIdChangedDelegate <NSObject>
@required
- (void)userIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId;
@end

@interface GrowingSession : NSObject
@property(nonatomic, copy, readonly) NSString *sessionId;
@property(nonatomic, copy, readwrite) NSString *loginUserId;
@property(nonatomic, assign, readonly) BOOL createdSession;

+ (void)startSession;

+ (instancetype)currentSession;

- (void)addUserIdChangedDelegate:(id <GrowingUserIdChangedDelegate>)delegate;

- (void)removeUserIdChangedDelegate:(id <GrowingUserIdChangedDelegate>)delegate;

- (void)forceReissueVisit;

/// 设置经纬度坐标
/// @param latitude 纬度
/// @param longitude 经度
- (void)setLocation:(double)latitude longitude:(double)longitude;
/// 清除地理位置
- (void)cleanLocation;

@end
