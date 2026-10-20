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
    /// 初始映射缺失、类型错误，或其中的采集地址格式不合法
    GrowingRoutingErrorInvalidServerHostMapping = 1,
    /// 数据源为空，或切换到未注册的数据源时没有提供采集地址
    GrowingRoutingErrorInvalidDataSource,
    /// 数据源已注册了不同的采集地址
    GrowingRoutingErrorConflictingServerHost,
    /// 运行时注册的采集地址格式不合法
    GrowingRoutingErrorInvalidServerHost,
};

@interface GrowingTrackConfiguration (GrowingRouting)

/// 在同一把锁内同时更新 dataSourceId、serverHostMapping 和 dataCollectionServerHost，
/// 保证其他线程读取时不会看到只更新了一部分的状态。dataCollectionServerHost 取自 serverHostMapping[dataSourceId]。
- (void)growing_updateDataSourceId:(NSString *)dataSourceId
                 serverHostMapping:(NSDictionary<NSString *, NSString *> *)serverHostMapping;

@end

@interface GrowingConfigurationManager : NSObject

@property (nonatomic, strong) GrowingTrackConfiguration *trackConfiguration;

+ (instancetype)sharedInstance;

+ (NSDictionary<NSString *, NSString *> *_Nullable)
    validatedServerHostMappingForConfiguration:(GrowingTrackConfiguration *)configuration
                                         error:(NSError *_Nullable *_Nullable)error;
- (NSString *_Nullable)serverHostForDataSourceId:(NSString *)dataSourceId;

/// 仅在事件线程调用。返回是否更新了当前数据源；校验失败时通过 error 返回原因，原配置保持不变。
- (BOOL)switchToDataSourceId:(NSString *)dataSourceId
    dataCollectionServerHost:(NSString *_Nullable)serverHost
                       error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
