//
//  GrowingAutoTracker.h
//  GrowingAutoTracker
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
#import "GrowingTracker.h"

#ifndef __cplusplus
@import Foundation;
@import WebKit;
#endif

typedef NS_ENUM(NSUInteger, GrowingIgnorePolicy) {
    GrowingIgnoreNone = 0,
    GrowingIgnoreSelf = 1,
    GrowingIgnoreChild = 2,
    GrowingIgnoreAll = 3,
};

@interface Growing (AutoTrackKit)

// SDK版本号
+ (NSString *)getAutoTrackVersion;

+ (void)addAutoTrackSwizzles;

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
@property (nonatomic, assign) GrowingIgnorePolicy growingViewIgonrePolicy;

// 手动标识该view的内容  比如banner广告条的id 可以放在banner按钮的任意view上
@property (nonatomic, copy) NSString *growingViewCustomContent;

// 手动标识该view的tag
// 这个tag必须是全局唯一的，在代码结构改变时也请保持不变
@property (nonatomic, copy)NSString *growingUniqueTag;

@end

// 该属性setter方法均使用 objc_setAssociatedObject实现
// 如果是自定义的UIViewController不要使用重写getter方法来实现,因为SDK在set方法内部有逻辑处理
@interface UIViewController (GrowingAttributes)

// 手动标识该页面的标题，必须在该UIViewController显示之前设置
@property (nonatomic, copy) NSString *growingPageAlias;

/**
 设置页面级变量
 SDK会缓存变量,在UIViewController没有被销毁之前, 每次进入都将自动补发
 页面级变量, 变量为nil,或者空字典, 清除所有缓存变量
 
 growingPageAttributes : 登录用户属性, 变量不能为nil
 */
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *growingPageAttributes;

@property (nonatomic, assign) GrowingIgnorePolicy growingPageIgonrePolicy;

@end

