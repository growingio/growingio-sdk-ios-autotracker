//
//  UIView+GrowingViewImpression.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
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

#import <UIKit/UIKit.h>
#import "GrowingViewImpressionConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GrowingViewImpression)

/// 标记曝光元素，元素满足曝光条件时发送对应的自定义事件（cstm）
/// @param eventName 自定义事件名
- (void)growingMarkImpression:(NSString *)eventName NS_SWIFT_NAME(markImp(_:))
                                  NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 标记曝光元素
/// @param eventName 自定义事件名
/// @param attributes 事件属性，可为 nil
- (void)growingMarkImpression:(NSString *)eventName
                   attributes:(nullable NSDictionary<NSString *, id> *)attributes NS_SWIFT_NAME(markImp(_:attributes:))
                                  NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 标记曝光元素（完整形式）
/// @param eventName 自定义事件名
/// @param attributes 事件属性，可为 nil
/// @param identifier 曝光标识。同一视图可挂载多个 identifier 不同的曝光标记；
///                   传 nil 时写入默认槽位。config 指定不可重复曝光时必须传入
/// @param config 单元素曝光配置，传 nil 则使用全局配置
- (void)growingMarkImpression:(NSString *)eventName
                   attributes:(nullable NSDictionary<NSString *, id> *)attributes
                   identifier:(nullable NSString *)identifier
                       config:(nullable GrowingViewImpressionConfig *)config
    NS_SWIFT_NAME(markImp(_:attributes:identifier:config:))
        NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 仅更新已标记元素的属性，不重置曝光状态、不触发重新曝光
/// @param attributes 新的事件属性
/// @param identifier 曝光标识，传 nil 时更新默认槽位
- (void)growingUpdateImpressionAttributes:(NSDictionary<NSString *, id> *)attributes
                               identifier:(nullable NSString *)identifier
    NS_SWIFT_NAME(updateImpAttributes(_:identifier:))
        NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 移除该视图上的全部曝光标记
- (void)growingUnmarkImpression NS_SWIFT_NAME(unmarkImp())
    NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 只移除某一个曝光标记
/// @param identifier 曝光标识
- (void)growingUnmarkImpressionWithIdentifier:(NSString *)identifier
    NS_SWIFT_NAME(unmarkImp(identifier:))
        NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

@end

NS_ASSUME_NONNULL_END
