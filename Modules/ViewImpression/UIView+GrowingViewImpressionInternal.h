//
//  UIView+GrowingViewImpressionInternal.h
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
#import "Modules/ViewImpression/GrowingViewImpressionNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GrowingViewImpressionInternal)

/// 该视图上的曝光槽位，key 为 identifier，identifier 缺省时为 kGrowingViewImpDefaultSlot
@property (nonatomic, strong, readonly, nullable)
    NSMutableDictionary<NSString *, GrowingViewImpressionNode *> *growingViewImpNodes;

- (void)growingViewImpMark:(NSString *)eventName
                attributes:(nullable NSDictionary<NSString *, id> *)attributes
                identifier:(nullable NSString *)identifier
                    config:(nullable GrowingViewImpressionConfig *)config;

/// 只替换槽位上的属性，不重置曝光状态，因此不会触发重新曝光
- (void)growingViewImpUpdateAttributes:(NSDictionary<NSString *, id> *)attributes
                            identifier:(nullable NSString *)identifier;

- (void)growingViewImpUnmarkAll;

- (void)growingViewImpUnmarkSlot:(NSString *)identifier;

/// 判定该视图当前是否达到曝光可见条件：逐级祖先裁剪后与 window 求交，
/// 交集面积占自身 bounds 面积达到 viewImpressionScale 即为可见
- (BOOL)growingViewImpNodeIsVisibleWithScale:(float)viewImpressionScale;

@end

NS_ASSUME_NONNULL_END
