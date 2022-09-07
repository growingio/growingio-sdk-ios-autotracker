//
//  GrowingTracker.h
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/11/6.
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

#import "GrowingDynamicProxy.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingAttributesBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTracker : GrowingDynamicProxy

/// 初始化方法
/// @param configuration 配置信息
/// @param launchOptions 启动参数
+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

/// 单例获取
+ (instancetype)sharedInstance;

/// 发送一个自定义事件
/// @param eventName 自定义事件名称
- (void)trackCustomEvent:(NSString *)eventName;

/// 发送一个自定义事件
/// @param eventName 自定义事件名称
/// @param attributes 事件发生时所伴随的维度信息
- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary <NSString *, NSString *> *)attributes;

/// 初始化事件计时器
/// @param eventName 自定义事件名称
/// @return 计时器唯一标识
- (nullable NSString *)trackTimerStart:(NSString *)eventName;

/// 暂停事件计时器
/// @param timerId 计时器唯一标识
- (void)trackTimerPause:(NSString *)timerId;

/// 恢复事件计时器
/// @param timerId 计时器唯一标识
- (void)trackTimerResume:(NSString *)timerId;

/// 停止事件计时器，并发送一个自定义事件
/// @param timerId 计时器唯一标识
- (void)trackTimerEnd:(NSString *)timerId;

/// 停止事件计时器，并发送一个自定义事件
/// @param timerId 计时器唯一标识
/// @param attributes 事件发生时所伴随的维度信息
- (void)trackTimerEnd:(NSString *)timerId withAttributes:(NSDictionary <NSString *, NSString *> *)attributes;

/// 删除事件计时器
/// @param timerId 计时器唯一标识
- (void)removeTimer:(NSString *)timerId;

/// 清除所有事件计时器
- (void)clearTrackTimer;

/// 以登录用户的身份定义用户属性变量，用于用户信息相关分析。
/// @param attributes 用户属性信息
- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

/// 以访客的身份定义用户属性变量，也可用于A/B测试上传标签。
/// @param attributes 用户属性信息
- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

/// 发送一个转化信息用于高级归因分析，在添加代码之前必须在打点管理界面上声明转化变量。
/// @param variables 转化变量信息
- (void)setConversionVariables:(NSDictionary <NSString *, NSString *> *)variables;

/// 支持设置userId的类型, 存储方式与userId保持一致, userKey默认为null
/// @param userId 用户ID
/// @param userKey 用户ID对应的类型key值
- (void)setLoginUserId:(NSString *)userId userKey:(NSString *)userKey;

/// 当用户登录之后调用setLoginUserId API，设置登录用户ID。
/// @param userId 用户ID
- (void)setLoginUserId:(NSString *)userId;

/// 当用户登出之后调用cleanLoginUserId，清除已经设置的登录用户ID。
- (void)cleanLoginUserId;

/// 打开或关闭数据采集
/// @param enabled 打开或者关闭
- (void)setDataCollectionEnabled:(BOOL)enabled;

/// 同步获取设备id，又称为匿名用户id，SDK 自动生成用来定义唯一设备。
- (NSString *)getDeviceId;


/// 设置经纬度坐标
/// @param latitude 纬度
/// @param longitude 经度
- (void)setLocation:(double)latitude longitude:(double)longitude;

/// 清除地理位置
- (void)cleanLocation;

@end

@interface GrowingTracker (Deprecated)

/// 发送一个自定义事件
/// @param eventName 自定义事件名称
/// @param attributesBuilder 事件发生时所伴随的维度信息构造器
/// @warning Deprecated: Please use `-[GrowingTracker trackCustomEvent:withAttributes:]` with attributesBuilder.build instead.
- (void)trackCustomEvent:(NSString *)eventName withAttributesBuilder:(GrowingAttributesBuilder *)attributesBuilder DEPRECATED_MSG_ATTRIBUTE("Use trackCustomEvent:withAttributes: instead.");

/// 以登录用户的身份定义用户属性变量，用于用户信息相关分析。
/// @param attributesBuilder 用户属性信息构造器
/// @warning Deprecated: Please use `-[GrowingTracker setLoginUserAttributes:]` with attributesBuilder.build instead.
- (void)setLoginUserAttributesWithAttributesBuilder:(GrowingAttributesBuilder *)attributesBuilder DEPRECATED_MSG_ATTRIBUTE("Use setLoginUserAttributes: instead.");

/// 以访客的身份定义用户属性变量，也可用于A/B测试上传标签。
/// @param attributesBuilder 用户属性信息构造器
/// @warning Deprecated: Please use `-[GrowingTracker setVisitorAttributes:]` with attributesBuilder.build instead.
- (void)setVisitorAttributesWithAttributesBuilder:(GrowingAttributesBuilder *)attributesBuilder DEPRECATED_MSG_ATTRIBUTE("Use setVisitorAttributes: instead.");

/// 发送一个转化信息用于高级归因分析，在添加代码之前必须在打点管理界面上声明转化变量。
/// @param attributesBuilder 转化变量信息构造器
/// @warning Deprecated: Please use `-[GrowingTracker setConversionVariables:]` with attributesBuilder.build instead.
- (void)setConversionVariablesWithAttributesBuilder:(GrowingAttributesBuilder *)attributesBuilder DEPRECATED_MSG_ATTRIBUTE("Use setConversionVariables: instead.");

@end

NS_ASSUME_NONNULL_END
