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
#import "GrowingAutotrackConfiguration.h"
#import "GrowingRealAutotracker.h"
#import <UIKit/UIKit.h>

@interface GrowingAutotracker : GrowingDynamicProxy

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

/// 以登录用户的身份定义用户属性变量，用于用户信息相关分析。
/// @param attributes 用户属性信息
- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

/// 以访客的身份定义用户属性变量，也可用于A/B测试上传标签。
/// @param attributes 用户属性信息
- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

/// 发送一个转化信息用于高级归因分析，在添加代码之前必须在打点管理界面上声明转化变量。
/// @param variables 用户属性信息
- (void)setConversionVariables:(NSDictionary <NSString *, NSString *> *)variables;

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

// imp半自动打点
@interface UIView (GrowingImpression)

/**
 以下为元素展示打点事件
 在元素展示前调用即可,GIO负责监听元素展示并触发事件
 事件类型为自定义事件(cstm)
 @param eventName 自定义事件名称
 */
- (void)growingTrackImpression:(NSString *)eventName;

/**
 以下为元素展示打点事件
 在元素展示前调用即可,GIO负责监听元素展示并触发事件
 事件类型为自定义事件(cstm)
 @param eventName 自定义事件名称
 @param attributes 自定义属性
 */
- (void)growingTrackImpression:(NSString *)eventName attributes:(NSDictionary<NSString *, NSString *> *)attributes;

// 停止该元素展示追踪
// 通常应用于列表中的重用元素
// 例如您只想追踪列表中的第一行元素的展示,但当第四行出现时重用了第一行的元素,此时您可调用此函数避免事件触发
- (void)growingStopTrackImpression;

@end

// 该属性setter方法均使用 objc_setAssociatedObject实现
// 如果是自定义的View建议优先使用重写getter方法来实现 以提高性能
@interface UIView(GrowingAttributes)

// 手动标识该view的忽略策略，请在该view被初始化后立刻赋值
@property (nonatomic, assign) GrowingIgnorePolicy growingViewIgnorePolicy;

// 手动标识该view的tag
// 这个tag必须是全局唯一的，在代码结构改变时也请保持不变
@property (nonatomic, copy)NSString *growingUniqueTag;

@end

// 该属性setter方法均使用 objc_setAssociatedObject实现
// 如果是自定义的UIViewController不要使用重写getter方法来实现,因为SDK在set方法内部有逻辑处理
@interface UIViewController (GrowingAttributes)

// 手动标识该页面的标题，必须在该UIViewController显示之前设置
@property (nonatomic, copy) NSString *growingPageAlias;

@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *growingPageAttributes;

@property (nonatomic, assign) GrowingIgnorePolicy growingPageIgnorePolicy;

@end
