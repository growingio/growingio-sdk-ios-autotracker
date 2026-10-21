//
//  GrowingTrackConfiguration+Private.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2026/10/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTrackConfiguration (Private)

/// 按数据源查找已注册的路由
/// @param dataSourceId 数据源ID
- (nullable GrowingDataSourceRoute *)routeForDataSourceId:(NSString *)dataSourceId;

/// 在同一把锁内更新路由表，并把 accountId、dataSourceId、dataCollectionServerHost 切换为 route 中的值，
/// 保证其他线程读取时不会看到只更新了一部分的状态
/// @param route 切换到的路由
/// @param routes 更新后的路由表
- (void)activateRoute:(GrowingDataSourceRoute *)route withRoutes:(NSArray<GrowingDataSourceRoute *> *)routes;

@end

NS_ASSUME_NONNULL_END
