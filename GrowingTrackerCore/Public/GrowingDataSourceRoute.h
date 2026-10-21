//
//  GrowingDataSourceRoute.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2026/10/20.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 一个数据源的上报目标：所属项目、数据源和采集地址。
/// dataSourceId 全局唯一，SDK 按事件的 dataSourceId 查找其所属项目和采集地址
NS_SWIFT_NAME(DataSourceRoute)
@interface GrowingDataSourceRoute : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *accountId;
@property (nonatomic, copy, readonly) NSString *dataSourceId;
/// 须为带 host 的 http(s) 地址，不能包含用户信息、query 或 fragment
@property (nonatomic, copy, readonly) NSString *dataCollectionServerHost;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithAccountId:(NSString *)accountId
                     dataSourceId:(NSString *)dataSourceId
         dataCollectionServerHost:(NSString *)dataCollectionServerHost NS_DESIGNATED_INITIALIZER;

+ (instancetype)routeWithAccountId:(NSString *)accountId
                      dataSourceId:(NSString *)dataSourceId
          dataCollectionServerHost:(NSString *)dataCollectionServerHost;

@end

NS_ASSUME_NONNULL_END
