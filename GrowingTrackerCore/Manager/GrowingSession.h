//
//  GrowingSession.h
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/11/10.
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

@protocol GrowingUserIdChangedDelegate <NSObject>

@required
- (void)userIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId;

@end

typedef NS_ENUM(NSInteger, GrowingSessionState) {
    GrowingSessionStateActive,
    GrowingSessionStateInactive,
    GrowingSessionStateBackground
};

@interface GrowingSession : NSObject

@property (nonatomic, assign, readonly, getter=isSentVisitAfterRefreshSessionId) BOOL sentVisitAfterRefreshSessionId;
@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, copy, readonly) NSString *loginUserId;
@property (nonatomic, copy, readonly) NSString *loginUserKey;
@property (nonatomic, copy, readonly) NSString *latestNonNullUserId;
@property (nonatomic, assign, readonly) double latitude;
@property (nonatomic, assign, readonly) double longitude;
@property (nonatomic, assign, readonly) GrowingSessionState state;
@property (nonatomic, assign, readonly) BOOL firstSession;

+ (void)startSession;

+ (instancetype)currentSession;

- (void)refreshSessionId;

- (void)generateVisit;

- (void)addUserIdChangedDelegate:(id<GrowingUserIdChangedDelegate>)delegate;

- (void)removeUserIdChangedDelegate:(id<GrowingUserIdChangedDelegate>)delegate;

- (void)setLoginUserId:(NSString *)loginUserId;

- (void)setLoginUserId:(NSString *)loginUserId userKey:(NSString *)userKey;

- (void)setLocation:(double)latitude longitude:(double)longitude;

- (void)cleanLocation;

@end
