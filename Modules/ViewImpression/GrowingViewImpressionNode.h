//
//  GrowingViewImpressionNode.h
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

#import <QuartzCore/QuartzCore.h>
#import "Modules/ViewImpression/Public/GrowingViewImpressionConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// identifier 缺省时槽位字典使用的固定 key
FOUNDATION_EXPORT NSString *const kGrowingViewImpDefaultSlot;

@interface GrowingViewImpressionNode : NSObject

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *attributes;
@property (nonatomic, copy, nullable) NSString *identifier;
@property (nonatomic, copy) GrowingViewImpressionConfig *config;
@property (nonatomic, assign) BOOL tracked;

/// 连续可见的计时起点，0 表示当前不可见
@property (nonatomic, assign) CFTimeInterval visibleSince;

/// 停留时长复检的配对令牌：令牌变化即代表此前调度的复检已失效
@property (nonatomic, assign) NSUInteger recheckToken;

@end

NS_ASSUME_NONNULL_END
