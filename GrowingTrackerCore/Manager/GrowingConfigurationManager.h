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

typedef NS_ENUM(NSInteger, GrowingRoutingError) {
    /// 初始路由缺失、类型错误、互相冲突、不包含当前数据源，或其中有不合法的路由
    GrowingRoutingErrorInvalidRoutes = 1,
    /// 数据源为空，或切换到未注册的数据源
    GrowingRoutingErrorInvalidDataSource,
    /// 数据源已注册了不同的项目或采集地址
    GrowingRoutingErrorConflictingRoute,
    /// 运行时注册的路由不合法：accountId 为空，或采集地址格式不合法
    GrowingRoutingErrorInvalidRoute,
};

@interface GrowingTrackConfiguration (GrowingRouting)

/// 按数据源查找已注册的路由
- (nullable GrowingDataSourceRoute *)growing_routeForDataSourceId:(NSString *)dataSourceId;

/// 在同一把锁内更新路由表，并把 accountId、dataSourceId、dataCollectionServerHost 切换为 route 中的值，
/// 保证其他线程读取时不会看到只更新了一部分的状态
- (void)growing_activateRoute:(GrowingDataSourceRoute *)route withRoutes:(NSArray<GrowingDataSourceRoute *> *)routes;

@end

@interface GrowingConfigurationManager : NSObject

@property (nonatomic, strong) GrowingTrackConfiguration *trackConfiguration;

+ (instancetype)sharedInstance;

/// 校验并整理初始路由，校验失败返回 nil
+ (NSArray<GrowingDataSourceRoute *> *_Nullable)validatedRoutesForConfiguration:
                                                    (GrowingTrackConfiguration *)configuration
                                                                          error:(NSError *_Nullable *_Nullable)error;

- (nullable GrowingDataSourceRoute *)routeForDataSourceId:(NSString *)dataSourceId;

/// 仅在事件线程调用。accountId 和 serverHost 都为 nil 时切换到已注册的数据源，否则注册并切换。
/// 返回是否更新了当前数据源；校验失败时通过 error 返回原因，原配置保持不变。
- (BOOL)switchToAccountId:(NSString *_Nullable)accountId
                dataSourceId:(NSString *)dataSourceId
    dataCollectionServerHost:(NSString *_Nullable)serverHost
                       error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
