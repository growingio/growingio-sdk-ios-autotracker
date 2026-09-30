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
#import "GrowingImpressionConfig.h"
#import "GrowingModuleProtocol.h"
#import "GrowingTrackConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ViewImpression)
@interface GrowingViewImpression : NSObject <GrowingModuleProtocol>

+ (instancetype)sharedInstance;

@end

@interface GrowingTrackConfiguration (ViewImpression)

/// 全局默认曝光配置（可见面积占比、最小可见时长），元素默认支持重复曝光
@property (nonatomic, copy) GrowingImpressionConfig *viewImpressionConfig;

/// 曝光采集开关，默认 YES。
/// 曝光采集属于无埋点能力的一部分，autotrackEnabled 为 NO 时曝光同样不采集，
/// 此开关仅用于在无埋点开启的前提下单独关掉曝光
@property (nonatomic, assign) BOOL viewImpressionEnabled;

/// 曝光检测节流间隔，单位秒，默认 0.5。置为 0 表示每次 runloop 休眠前都检测
@property (nonatomic, assign) NSTimeInterval viewImpressionCheckInterval;

@end

NS_ASSUME_NONNULL_END
