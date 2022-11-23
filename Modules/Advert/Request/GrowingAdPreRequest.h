//
//  GrowingAdPreRequest.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/11/21.
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
#import "GrowingRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 发送 reengage 之前需要发送一个前置请求请求数据
@interface GrowingAdPreRequest : NSObject <GrowingRequestProtocol>

@property (nonatomic, copy) NSString *trackId;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, strong) NSDictionary *query;
@property (nonatomic, assign) BOOL isManual;

@end

NS_ASSUME_NONNULL_END
