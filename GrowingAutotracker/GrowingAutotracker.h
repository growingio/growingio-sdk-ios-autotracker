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

#import "GrowingStrongProxy.h"
#import "GrowingTrackConfiguration+GrowingAutotracker.h"
#import "GrowingRealAutotracker.h"

@interface GrowingAutotracker : GrowingStrongProxy
+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions;

+ (instancetype)sharedInstance;

- (void)trackCustomEvent:(NSString *)eventName;

- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary <NSString *, NSString *> *)attributes;

- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

- (void)setConversionVariables:(NSDictionary <NSString *, NSString *> *)variables;

- (void)setLoginUserId:(NSString *)userId;

- (void)cleanLoginUserId;

- (void)setDataCollectionEnabled:(BOOL)enabled;

- (NSString *)getDeviceId;

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
