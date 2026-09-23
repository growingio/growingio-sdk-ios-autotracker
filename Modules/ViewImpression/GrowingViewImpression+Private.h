//
//  GrowingViewImpression+Private.h
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
#import "Modules/ViewImpression/Public/GrowingImpressionConfig.h"
#import "Modules/ViewImpression/Public/GrowingViewImpression.h"

NS_ASSUME_NONNULL_BEGIN

/// 内部接口一律要求在主线程调用，线程切换由 UIView 分类中的公开入口统一完成
@interface GrowingViewImpression (Private)

- (void)addImpressionView:(UIView *)view;

- (void)removeImpressionView:(UIView *)view;

/// 单元素 config > 全局 viewImpressionConfig > 默认值
+ (GrowingImpressionConfig *)effectiveConfig:(nullable GrowingImpressionConfig *)config;

@end

NS_ASSUME_NONNULL_END
