//
//  GrowingAsaFetcher.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
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

typedef NS_ENUM(NSUInteger, GrowingAsaFetcherStatus) {
    GrowingAsaFetcherStatusDenied = 1,   // ASAEnabled == NO或未集成framework
    GrowingAsaFetcherStatusFailure,      // 获取归因数据失败
    GrowingAsaFetcherStatusFetching,     // 正在获取归因数据
    GrowingAsaFetcherStatusSuccess,      // 获取归因数据成功
    GrowingAsaFetcherStatusCompleted     // activate 事件发送完毕
};

extern CGFloat const GrowingAsaFetcherDefaultTimeOut;

@interface GrowingAsaFetcher : NSObject

@property (class, nonatomic, assign) GrowingAsaFetcherStatus status;
@property (class, nonatomic, copy) NSDictionary *asaData;

+ (void)startFetchWithTimeOut:(CGFloat)timeOut;
+ (void)retry;

@end

NS_ASSUME_NONNULL_END
