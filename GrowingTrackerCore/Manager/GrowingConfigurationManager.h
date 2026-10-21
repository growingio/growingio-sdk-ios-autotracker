//
//  GrowingConfigurationManager.h
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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
#import "GrowingTrackConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const GrowingRoutingErrorDomain;

/// 路由错误码
typedef NS_ENUM(NSInteger, GrowingRoutingError) {
    GrowingRoutingInvalidRoutesError = 500,  /// 初始路由不合法
    GrowingRoutingUnregisteredRouteError,    /// 路由未注册，且未提供采集地址
    GrowingRoutingConflictingRouteError,     /// 与已注册的路由冲突
    GrowingRoutingInvalidRouteError,         /// 路由不合法
};

@interface GrowingConfigurationManager : NSObject

@property (nonatomic, strong) GrowingTrackConfiguration *trackConfiguration;

+ (instancetype)sharedInstance;

/// 校验并整理初始路由，校验失败返回 nil
+ (NSArray<GrowingDataSourceRoute *> *_Nullable)validatedRoutesForConfiguration:
                                                    (GrowingTrackConfiguration *)configuration
                                                                          error:(NSError *_Nullable *_Nullable)error;

- (nullable GrowingDataSourceRoute *)routeForDataSourceId:(NSString *)dataSourceId;

/// 仅在事件线程调用。serverHost 为 nil 时切换到已注册的路由，否则注册路由并切换。
/// 返回是否切换了当前的项目和数据源；校验失败时通过 error 返回原因，原配置保持不变。
- (BOOL)switchToAccountId:(NSString *)accountId
                dataSourceId:(NSString *)dataSourceId
    dataCollectionServerHost:(NSString *_Nullable)serverHost
                       error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
