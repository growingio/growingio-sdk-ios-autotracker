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

#import "GrowingAttributesBuilder.h"
#import "GrowingDynamicProxy.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingPropertyPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTracker : GrowingDynamicProxy

///-------------------------------
#pragma mark Initialization
///-------------------------------

/// 初始化方法
/// @param configuration 配置信息
/// @param launchOptions 启动参数
+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

/// 是否成功初始化
+ (BOOL)isInitializedSuccessfully;

/// 单例获取
+ (instancetype)sharedInstance;

///-------------------------------
#pragma mark Configuration
///-------------------------------

/// 打开或关闭数据采集
/// @param enabled 打开或者关闭
- (void)setDataCollectionEnabled:(BOOL)enabled;

/// 当用户登录之后调用setLoginUserId API，设置登录用户ID。
/// @param userId 用户ID
- (void)setLoginUserId:(NSString *)userId;

/// 支持设置userId的类型, 存储方式与userId保持一致, userKey默认为null
/// @param userId 用户ID
/// @param userKey 用户ID对应的类型key值
- (void)setLoginUserId:(NSString *)userId userKey:(NSString *)userKey;

/// 当用户登出之后调用cleanLoginUserId，清除已经设置的登录用户ID。
- (void)cleanLoginUserId;

/// 设置经纬度坐标
/// @param latitude 纬度
/// @param longitude 经度
- (void)setLocation:(double)latitude longitude:(double)longitude;

/// 清除地理位置
- (void)cleanLocation;

/// 以登录用户的身份定义用户属性变量，用于用户信息相关分析。
/// @param attributes 用户属性信息
- (void)setLoginUserAttributes:(NSDictionary<NSString *, id> *)attributes;

/// 同步获取设备id，又称为匿名用户id，SDK 自动生成用来定义唯一设备。
- (NSString *)getDeviceId;

///-------------------------------
#pragma mark Track Event
///-------------------------------

/// 发送一个自定义事件
/// @param eventName 自定义事件名称
- (void)trackCustomEvent:(NSString *)eventName;

/// 发送一个自定义事件
/// @param eventName 自定义事件名称
/// @param attributes 事件发生时所伴随的维度信息
- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *, id> *)attributes;

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
- (void)trackTimerEnd:(NSString *)timerId withAttributes:(NSDictionary<NSString *, id> *)attributes;

/// 删除事件计时器
/// @param timerId 计时器唯一标识
- (void)removeTimer:(NSString *)timerId;

/// 清除所有事件计时器
- (void)clearTrackTimer;

/// 设置埋点通用属性
/// @param props 事件通用属性，相同字段的新值将覆盖旧值
+ (void)setGeneralProps:(NSDictionary<NSString *, id> *)props;

/// 清除指定字段的埋点通用属性
/// @param keys 通用属性指定字段
+ (void)removeGeneralProps:(NSArray<NSString *> *)keys;

/// 清除所有埋点通用属性
+ (void)clearGeneralProps;

/// 设置埋点动态通用属性
/// @param generator 动态通用属性，其优先级大于通用属性
+ (void)setDynamicGeneralPropsGenerator:(NSDictionary<NSString *, id> * (^_Nullable)(void))generator
    NS_SWIFT_NAME(setDynamicGeneralProps(_:));

/// 设置属性插件
/// @param plugin 插件需实现GrowingPropertyPlugin接口
+ (void)setPropertyPlugins:(id <GrowingPropertyPlugin>)plugin;

///-------------------------------
#pragma mark Unavailable
///-------------------------------

- (instancetype)init NS_UNAVAILABLE;

///-------------------------------
#pragma mark Deprecated
///-------------------------------

/// 设置埋点通用属性
/// @param props 事件通用属性，相同字段的新值将覆盖旧值
- (void)setGeneralProps:(NSDictionary<NSString *, NSString *> *)props
    DEPRECATED_MSG_ATTRIBUTE("Use +[GrowingTracker setGeneralProps:] instead.");

/// 清除指定字段的埋点通用属性
/// @param keys 通用属性指定字段
- (void)removeGeneralProps:(NSArray<NSString *> *)keys
    DEPRECATED_MSG_ATTRIBUTE("Use +[GrowingTracker removeGeneralProps:] instead.");

/// 清除所有埋点通用属性
- (void)clearGeneralProps DEPRECATED_MSG_ATTRIBUTE("Use +[GrowingTracker clearGeneralProps] instead.");

@end

NS_ASSUME_NONNULL_END
