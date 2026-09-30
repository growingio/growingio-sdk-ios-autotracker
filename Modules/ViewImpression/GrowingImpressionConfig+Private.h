//
//  GrowingImpressionConfig+Private.h
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

#import "Modules/ViewImpression/Public/GrowingImpressionConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// 以下能力为内部预留，待后续迭代再公开
@interface GrowingImpressionConfig (Private)

/// 是否允许同一元素多次曝光，默认 YES。
/// 置为 NO 时必须为元素指定 identifier，否则将被降级为 YES 处理
@property (nonatomic, assign, getter=isRepeatable) BOOL repeatable;

+ (instancetype)configWithImpressionScale:(float)impressionScale
                             stayDuration:(NSTimeInterval)stayDuration
                               repeatable:(BOOL)repeatable;

@end

NS_ASSUME_NONNULL_END
