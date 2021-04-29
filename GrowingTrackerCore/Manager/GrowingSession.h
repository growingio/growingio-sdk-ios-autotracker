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

-(double)getLatitude;

-(double)getLongitude;

@end
