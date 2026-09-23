//
//  GrowingViewImpression.h
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

#import <Foundation/Foundation.h>
#import "GrowingModuleProtocol.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingImpressionConfig.h"
#import "GrowingImpressionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ViewImpression)
@interface GrowingViewImpression : NSObject <GrowingModuleProtocol>

+ (instancetype)sharedInstance;

/// delegate 为弱引用，无需手动移除；重复添加同一个对象只生效一次
- (void)addViewImpressionDelegate:(id<GrowingImpressionDelegate>)delegate;

- (void)removeViewImpressionDelegate:(id<GrowingImpressionDelegate>)delegate;

@end

@interface GrowingViewImpression (State)

/// 清除某个标识的"已曝光"记录，之后该标识的元素可再次曝光。
/// 仅对配置了不可重复曝光的元素有意义，适用于下拉刷新、切换数据源等场景
+ (void)resetViewImpressionStateWithIdentifier:(NSString *)identifier;

/// 清除全部"已曝光"记录
+ (void)resetAllViewImpressionState;

@end

@interface GrowingTrackConfiguration (ViewImpression)

/// 全局默认曝光配置，元素未单独指定 config 时使用
@property (nonatomic, copy) GrowingImpressionConfig *viewImpressionConfig;

/// 曝光采集开关，默认 YES。
/// 曝光采集属于无埋点能力的一部分，autotrackEnabled 为 NO 时曝光同样不采集，
/// 此开关仅用于在无埋点开启的前提下单独关掉曝光
@property (nonatomic, assign) BOOL viewImpressionEnabled;

/// 曝光检测节流间隔，单位秒，默认 0.5。置为 0 表示每次 runloop 休眠前都检测
@property (nonatomic, assign) NSTimeInterval viewImpressionCheckInterval;

@end

NS_ASSUME_NONNULL_END
