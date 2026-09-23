//
//  GrowingImpressionConfig.m
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

#import "Modules/ViewImpression/Public/GrowingImpressionConfig.h"

@implementation GrowingImpressionConfig

- (instancetype)init {
    if (self = [super init]) {
        _impressionScale = 0.0f;
        _stayDuration = 0.0;
        _repeatable = YES;
    }
    return self;
}

+ (instancetype)configWithImpressionScale:(float)impressionScale
                                 stayDuration:(NSTimeInterval)stayDuration
                                   repeatable:(BOOL)repeatable {
    GrowingImpressionConfig *config = [[self alloc] init];
    config.impressionScale = impressionScale;
    config.stayDuration = stayDuration;
    config.repeatable = repeatable;
    return config;
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingImpressionConfig *config = [[[self class] allocWithZone:zone] init];
    config->_impressionScale = _impressionScale;
    config->_stayDuration = _stayDuration;
    config->_repeatable = _repeatable;
    return config;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[GrowingImpressionConfig class]]) {
        return NO;
    }

    // 这里要回答的是"调用方传进来的还是不是同一份配置"，不是"两个数值是否足够接近"，
    // 因此是精确比较：留容差反而会把 0.5 与 0.500001 当成同一份配置，静默沿用旧的
    GrowingImpressionConfig *other = (GrowingImpressionConfig *)object;
    return _impressionScale == other->_impressionScale && _stayDuration == other->_stayDuration &&
           _repeatable == other->_repeatable;
}

- (NSUInteger)hash {
    return @(_impressionScale).hash ^ @(_stayDuration).hash ^ @(_repeatable).hash;
}

#pragma mark - Setter

- (void)setImpressionScale:(float)impressionScale {
    if (impressionScale < 0.0f) {
        impressionScale = 0.0f;
    } else if (impressionScale > 1.0f) {
        impressionScale = 1.0f;
    }
    _impressionScale = impressionScale;
}

- (void)setStayDuration:(NSTimeInterval)stayDuration {
    _stayDuration = stayDuration < 0.0 ? 0.0 : stayDuration;
}

@end
