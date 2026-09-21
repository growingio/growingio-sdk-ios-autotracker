//
//  UIView+GrowingViewImpression.m
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

#import "Modules/ViewImpression/Public/UIView+GrowingViewImpression.h"
#import "Modules/ViewImpression/UIView+GrowingViewImpressionInternal.h"

@implementation UIView (GrowingViewImpression)

- (void)growingMarkImpression:(NSString *)eventName {
    [self growingMarkImpression:eventName attributes:nil];
}

- (void)growingMarkImpression:(NSString *)eventName attributes:(NSDictionary<NSString *, id> *)attributes {
    [self growingViewImpMark:eventName attributes:attributes identifier:nil config:nil];
}

- (void)growingMarkImpression:(NSString *)eventName
                   attributes:(NSDictionary<NSString *, id> *)attributes
                   identifier:(NSString *)identifier
                       config:(GrowingViewImpressionConfig *)config {
    [self growingViewImpMark:eventName attributes:attributes identifier:identifier config:config];
}

- (void)growingUpdateImpressionAttributes:(NSDictionary<NSString *, id> *)attributes identifier:(NSString *)identifier {
    [self growingViewImpUpdateAttributes:attributes identifier:identifier];
}

- (void)growingUnmarkImpression {
    [self growingViewImpUnmarkAll];
}

- (void)growingUnmarkImpressionWithIdentifier:(NSString *)identifier {
    [self growingViewImpUnmarkSlot:identifier];
}

@end
