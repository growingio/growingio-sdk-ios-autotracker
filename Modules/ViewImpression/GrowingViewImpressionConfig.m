//
//  GrowingViewImpressionConfig.m
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

#import "Modules/ViewImpression/Public/GrowingViewImpressionConfig.h"

@implementation GrowingViewImpressionConfig

- (instancetype)init {
    if (self = [super init]) {
        _viewImpressionScale = 0.0f;
        _stayDuration = 0.0;
        _repeatable = YES;
    }
    return self;
}

+ (instancetype)configWithViewImpressionScale:(float)viewImpressionScale
                                 stayDuration:(NSTimeInterval)stayDuration
                                   repeatable:(BOOL)repeatable {
    GrowingViewImpressionConfig *config = [[self alloc] init];
    config.viewImpressionScale = viewImpressionScale;
    config.stayDuration = stayDuration;
    config.repeatable = repeatable;
    return config;
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingViewImpressionConfig *config = [[[self class] allocWithZone:zone] init];
    config->_viewImpressionScale = _viewImpressionScale;
    config->_stayDuration = _stayDuration;
    config->_repeatable = _repeatable;
    return config;
}

#pragma mark - Setter

- (void)setViewImpressionScale:(float)viewImpressionScale {
    if (viewImpressionScale < 0.0f) {
        viewImpressionScale = 0.0f;
    } else if (viewImpressionScale > 1.0f) {
        viewImpressionScale = 1.0f;
    }
    _viewImpressionScale = viewImpressionScale;
}

- (void)setStayDuration:(NSTimeInterval)stayDuration {
    _stayDuration = stayDuration < 0.0 ? 0.0 : stayDuration;
}

@end
