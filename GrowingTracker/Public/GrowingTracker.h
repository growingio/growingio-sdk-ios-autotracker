//
//  GrowingTracker.h
//  GrowingTracker
//
//  Created by GrowingIO on 2018/5/14.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
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


#import <UIKit/UIKit.h>
#import "GrowingConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

#ifndef __cplusplus
@import Foundation;
@import CoreTelephony;
@import SystemConfiguration;
@import Security;
@import CFNetwork;
@import CoreLocation;
@import WebKit;
#endif

@interface Growing : NSObject

// SDK版本号
+ (NSString *)getTrackVersion;

// 如果您的AppDelegate中 实现了其中一个或者多个方法 请以在已实现的函数中 调用handleURL
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
// 如果以上所有函数都未实现 则请实现 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation 方法并调用handleUrl
+ (BOOL)handleURL:(NSURL *)url;

/**
通过配置参数初始化 GrowingIO SDK
 此方法调用请满足以下条件：
    1. 请在applicationDidFinishLaunching中调用此函数初始化,
    2. 请在主线程中调用
@param configuration 配置参数
*/
+ (void)startWithConfiguration:(GrowingConfiguration * _Nonnull)configuration;

/// 设置经纬度坐标
/// @param latitude 纬度
/// @param longitude 经度
+ (void)setLocation:(double)latitude longitude:(double)longitude;

/// 清除地理位置
+ (void)cleanLocation;

// 设置 GDPR 是否生效
+ (void)setDataCollectionEnabled:(BOOL)enabled;
// 获取当前设备id
+ (NSString *)getDeviceId;
// 获取当前访问id
+ (NSString *)getSessionId;

/**
 设置登录用户ID
 
 @param userId 登陆用户ID, ID为正常英文数字组合的字符串, 长度<=1000, 请不要含有 "'|\*&$@/', 等特殊字符
 ！！！不允许传空或者nil, 如有此操作请调用clearUserId函数
 */
+ (void)setLoginUserId:(NSString *)userId;
/**
 清除登录用户ID
 */
+ (void)cleanLoginUserId;

/**
 转化变量
 
 @param variables : 变量名称为 key，变量值为 value, 不能为nil或者空字符串
 */
+ (void)setConversionVariables:(NSDictionary <NSString *, NSString *> *)variables;

/**
 登录用户属性
 
 @param attributes : 登录用户属性, 变量不能为nil
 */
+ (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

/**
 发送事件 API,
 
 @param eventName : 事件名称, eventName 为正常英文数字组合的字符串, 长度<=1000, 请不要含有 "'|\*&$@/', 等特殊字符
 */
+ (void)trackCustomEvent:(NSString *)eventName;

/**
 发送事件 API
 
 @param eventName : 事件名称, eventName 正常英文数字组合的字符串, 长度<=1000, 请不要含有 "'|\*&$@/', 等特殊字符
 @param attributes : 事件变量, 变量不能为nil
 */
+ (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary <NSString *, NSString *> *)attributes;

/**
 访问用户变量
 
 @param attributes : 访问用户变量, 不能为nil
 */
+ (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

@end

NS_ASSUME_NONNULL_END
