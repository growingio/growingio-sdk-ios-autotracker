//
//  GrowingImpressionDelegate.h
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

/// 三个回调均在主线程同步执行，实现中不要做耗时操作
NS_SWIFT_NAME(ImpressionDelegate)
@protocol GrowingImpressionDelegate <NSObject>

@optional

/// 返回 NO 则本次不发送曝光事件。元素离开可视区再次进入时会重新询问。
/// 注册了多个 delegate 时，任一返回 NO 即不发送
- (BOOL)growingViewImpressionShouldTrack:(UIView *)view
                               eventName:(NSString *)eventName
                              identifier:(nullable NSString *)identifier;

/// 曝光时刻求值的动态属性，与标记时的静态属性合并后作为事件属性，同名键以动态属性为准
- (nullable NSDictionary<NSString *, id> *)growingViewImpressionDynamicAttributes:(UIView *)view
                                                                        eventName:(NSString *)eventName
                                                                       identifier:(nullable NSString *)identifier;

/// 曝光事件已生成
- (void)growingViewImpressionDidTrack:(UIView *)view
                            eventName:(NSString *)eventName
                           identifier:(nullable NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
