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

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GrowingViewImpression)

/// 标记曝光元素，元素满足曝光条件时发送对应的自定义事件（cstm）。默认支持重复曝光：
/// 元素离开可视区再次进入时会再发送一次
/// @param eventName 自定义事件名
- (void)growingTrackViewImpression:(NSString *)eventName NS_SWIFT_NAME(trackViewImpression(_:))
                                       NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 标记曝光元素
/// @param eventName 自定义事件名
/// @param attributes 事件属性，可为 nil
- (void)growingTrackViewImpression:(NSString *)eventName
                        attributes:(nullable NSDictionary<NSString *, id> *)attributes
    NS_SWIFT_NAME(trackViewImpression(_:attributes:))
        NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

/// 移除该视图上的全部曝光标记
- (void)growingStopTrackViewImpression NS_SWIFT_NAME(stopTrackViewImpression())
    NS_EXTENSION_UNAVAILABLE("ViewImpression is not supported for iOS extensions.");

@end

NS_ASSUME_NONNULL_END
