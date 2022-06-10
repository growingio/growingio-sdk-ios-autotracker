//
//  GrowingGA3TrackerInfo.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/31.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

@class GrowingBaseEvent, GrowingGA3TrackerInfo;

typedef void(^GrowingGA3TrackerTransformEventBlock)(GrowingBaseEvent *event, GrowingGA3TrackerInfo *info);

@interface GrowingGA3TrackerInfo : NSObject 

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *dataSourceId;
@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic, copy) NSString *lastUserId;
@property (nonatomic, strong) NSMutableDictionary *extraParams;

- (instancetype)initWithDataSourceId:(NSString *)dataSourceId
                           sessionId:(NSString *)sessionId
                 transformEventBlock:(GrowingGA3TrackerTransformEventBlock)transformEventBlock;

- (instancetype)init NS_UNAVAILABLE;

- (void)addParameter:(NSString *)key value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
