//
//  UIView+GrowingImpression.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/7/13.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

@interface UIView (GrowingImpression)

/**
 以下为元素展示打点事件
 在元素展示前调用即可,GIO负责监听元素展示并触发事件
 事件类型为自定义事件(cstm)
 @param eventName 自定义事件名称
 */
- (void)growingTrackImpression:(NSString *)eventName NS_SWIFT_NAME(trackImp(_:))
                                   NS_EXTENSION_UNAVAILABLE("ImpressionTrack is not supported for iOS extensions.");

/**
 以下为元素展示打点事件
 在元素展示前调用即可,GIO负责监听元素展示并触发事件
 事件类型为自定义事件(cstm)
 @param eventName 自定义事件名称
 @param attributes 自定义属性
 */
- (void)growingTrackImpression:(NSString *)eventName
                    attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes
    NS_SWIFT_NAME(trackImp(_:attributes:))
        NS_EXTENSION_UNAVAILABLE("ImpressionTrack is not supported for iOS extensions.");

// 停止该元素展示追踪
// 通常应用于列表中的重用元素
// 例如您只想追踪列表中的第一行元素的展示,但当第四行出现时重用了第一行的元素,此时您可调用此函数避免事件触发
- (void)growingStopTrackImpression NS_SWIFT_NAME(stopTrackImp())
    NS_EXTENSION_UNAVAILABLE("ImpressionTrack is not supported for iOS extensions.");

@end

NS_ASSUME_NONNULL_END
