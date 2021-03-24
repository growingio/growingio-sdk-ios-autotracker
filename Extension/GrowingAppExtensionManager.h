//
// GrowingAppExtensionManager.h
// GrowingAnalytics
//
//  Created by sheng on 2020/9/27.
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

NS_ASSUME_NONNULL_BEGIN

static NSString *kGrowingExtensionCustomEvent = @"CustomEvent";
static NSString *kGrowingExtensionConversionVariables = @"ConversionVariables";
static NSString *kGrowingExtensionLoginUserAttributes = @"LoginUserAttributes";

static NSString *kGrowingExtension_event = @"event";
static NSString *kGrowingExtension_timestamp = @"timestamp";
static NSString *kGrowingExtension_attributes = @"attributes";

@interface GrowingAppExtensionManager : NSObject

+ (instancetype)sharedInstance;

/// 返回对应 Extension 的数据缓存路径
/// @param groupIdentifier 关联的Group ID
- (NSString *)filePathForGroupIdentifier:(NSString *)groupIdentifier;

/// 写入Custom事件和属性
/// @param eventName 事件名称
/// @param attributes 事件属性
/// @param groupIdentifier 关联的Group ID
- (BOOL)writeCustomEvent:(NSString *)eventName attributes:(NSDictionary *)attributes groupIdentifier:(NSString *)groupIdentifier;

/// 写入转化变量
/// @param variables 转化变量
/// @param groupIdentifier 关联的Group ID
- (BOOL)writeConversionVariables:(NSDictionary *)variables groupIdentifier:(NSString *)groupIdentifier;

/// 写入登录用户属性
/// @param attributes 登录用户属性
/// @param groupIdentifier 关联的Group ID
- (BOOL)writeLoginUserAttributes:(NSDictionary *)attributes groupIdentifier:(NSString *)groupIdentifier;

/// 读取groupIdentifier的所有缓存事件
/// @param groupIdentifier 关联的Group ID
- (NSDictionary *)readAllEventsWithGroupIdentifier:(NSString *)groupIdentifier;

/// 删除所有缓存事件
/// @param groupIdentifier 关联的Group ID
- (BOOL)deleteEventsWithGroupIdentifier:(NSString *)groupIdentifier;

@end

NS_ASSUME_NONNULL_END
