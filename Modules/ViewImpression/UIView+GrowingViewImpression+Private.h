//
//  UIView+GrowingViewImpression+Private.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/30.
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

#import "Modules/ViewImpression/GrowingImpressionConfig+Private.h"
#import "Modules/ViewImpression/Public/UIView+GrowingViewImpression.h"

NS_ASSUME_NONNULL_BEGIN

/// 以下能力为内部预留，待后续迭代再公开
@interface UIView (GrowingViewImpressionPrivate)

/// 标记曝光元素（完整形式）
/// @param eventName 自定义事件名
/// @param attributes 事件属性，可为 nil
/// @param identifier 曝光标识。同一视图可挂载多个 identifier 不同的曝光标记；
///                   传 nil 时写入默认槽位。config 指定不可重复曝光时必须传入
/// @param config 单元素曝光配置，传 nil 则使用全局配置
- (void)growingTrackViewImpression:(NSString *)eventName
                        attributes:(nullable NSDictionary<NSString *, id> *)attributes
                        identifier:(nullable NSString *)identifier
                            config:(nullable GrowingImpressionConfig *)config
    NS_SWIFT_NAME(trackViewImpression(_:attributes:identifier:config:))
        NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 仅更新已标记元素的属性，不重置曝光状态、不触发重新曝光
/// @param attributes 新的事件属性
/// @param identifier 曝光标识，传 nil 时更新默认槽位
- (void)growingUpdateViewImpressionAttributes:(NSDictionary<NSString *, id> *)attributes
                                   identifier:(nullable NSString *)identifier
    NS_SWIFT_NAME(updateViewImpressionAttributes(_:identifier:))
        NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 只移除某一个曝光标记
/// @param identifier 曝光标识
- (void)growingStopTrackViewImpressionWithIdentifier:(NSString *)identifier
    NS_SWIFT_NAME(stopTrackViewImpression(identifier:))
        NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

@end

NS_ASSUME_NONNULL_END
