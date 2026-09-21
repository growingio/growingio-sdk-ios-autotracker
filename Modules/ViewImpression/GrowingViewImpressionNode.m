//
//  GrowingViewImpressionNode.m
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

#import "Modules/ViewImpression/GrowingViewImpressionNode.h"

NSString *const kGrowingViewImpDefaultSlot = @"$default";

@implementation GrowingViewImpressionNode

- (BOOL)matchesEventName:(NSString *)eventName
              attributes:(NSDictionary<NSString *, id> *)attributes
                  config:(GrowingViewImpressionConfig *)config {
    if (![self.eventName isEqualToString:eventName]) {
        return NO;
    }
    if (self.attributes.count != attributes.count) {
        return NO;
    }
    if (attributes.count > 0 && ![self.attributes isEqualToDictionary:attributes]) {
        return NO;
    }
    return [self.config isEqual:config];
}

@end
