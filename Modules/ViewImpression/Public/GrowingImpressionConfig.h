//
//  GrowingImpressionConfig.h
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

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ImpressionConfig)
@interface GrowingImpressionConfig : NSObject <NSCopying>

/// 可见面积占比阈值，有效范围 0~1，超出范围将被截断，默认 0（露出即算曝光）
@property (nonatomic, assign) float impressionScale;

/// 最小可见时长，单位秒，负值按 0 处理，默认 0（无需停留）
@property (nonatomic, assign) NSTimeInterval stayDuration;

/// 是否允许同一元素多次曝光，默认 YES。
/// 置为 NO 时必须为元素指定 identifier，否则将被降级为 YES 处理
@property (nonatomic, assign, getter=isRepeatable) BOOL repeatable;

+ (instancetype)configWithImpressionScale:(float)impressionScale
                                 stayDuration:(NSTimeInterval)stayDuration
                                   repeatable:(BOOL)repeatable;

@end

NS_ASSUME_NONNULL_END
