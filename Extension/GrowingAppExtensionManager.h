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
static NSString *kGrowingExtensionCustomEvent_event = @"event";
static NSString *kGrowingExtensionCustomEvent_attributes = @"attributes";
static NSString *kGrowingExtensionConversionVariables = @"ConversionVariables";
static NSString *kGrowingExtensionConversionVariables_variables = @"variables";
static NSString *kGrowingExtensionLoginUserAttributes = @"LoginUserAttributes";
static NSString *kGrowingExtensionLoginUserAttributes_attributes = @"attributes";

@interface GrowingAppExtensionManager : NSObject

@property (nonatomic, strong) NSArray *groupIdentifierArray;

+ (instancetype)sharedInstance;

/**
 * @abstract
 * 根据传入的 groupIdentifier 返回对应 Extension 的数据缓存路径
 *
 * @param groupIdentifier App组标识 eg:group.cn.com.growingio.Example
 * @return 在 group 中的数据缓存文件路径
 */
- (NSString *)filePathForGroupIdentifier:(NSString *)groupIdentifier;


/**
 * @abstract
 * 给一个groupIdentifier写入Custom事件和属性
 * @param eventName 事件名称(！须符合变量的命名规范)
 * @param attributes 事件属性
 * @param groupIdentifier ApplicationGroupIdentifier
 * @return 是否（YES/NO）写入成功
 */
- (BOOL)writeCustomEvent:(NSString *)eventName attributes:(NSDictionary *)attributes groupIdentifier:(NSString *)groupIdentifier;

/**
 * @abstract
 * 给一个groupIdentifier写入转化变量
 * @param variables 转化变量
 * @param groupIdentifier ApplicationGroupIdentifier
 * @return 是否（YES/NO）写入成功
 */
- (BOOL)writeConversionVariables:(NSDictionary *)variables groupIdentifier:(NSString *)groupIdentifier;

/**
 * @abstract
 * 给一个groupIdentifier写入登录用户属性
 * @param attributes 登录用户属性
 * @param groupIdentifier ApplicationGroupIdentifier
 * @return 是否（YES/NO）写入成功
 */
- (BOOL)writeLoginUserAttributes:(NSDictionary *)attributes groupIdentifier:(NSString *)groupIdentifier;
/**
 * @abstract
 * 读取groupIdentifier的所有缓存事件
 * @param groupIdentifier ApplicationGroupIdentifier
 * @return 当前groupIdentifier缓存的所有事件
 */
- (NSDictionary *)readAllEventsWithGroupIdentifier:(NSString *)groupIdentifier;

/**
 * @abstract
 * 删除groupIdentifier的所有缓存事件
 * @param groupIdentifier ApplicationGroupIdentifier
 * @return 是否（YES/NO）删除成功
 */
- (BOOL)deleteEventsWithGroupIdentifier:(NSString *)groupIdentifier;

@end

NS_ASSUME_NONNULL_END
