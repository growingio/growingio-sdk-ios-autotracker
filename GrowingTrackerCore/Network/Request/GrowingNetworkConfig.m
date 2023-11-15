//
//  GrowingNetworkConfig.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 16/9/21.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Public/GrowingNetworkConfig.h"

@implementation GrowingNetworkConfig

- (instancetype)init {
    if (self = [super init]) {
        _requestTimeout = 30;
    }
    return self;
}

+ (instancetype)config {
    return [[GrowingNetworkConfig alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingNetworkConfig *config = [[[self class] allocWithZone:zone] init];
    config->_requestTimeout = _requestTimeout;
    return config;
}

#pragma mark - Setter & Getter

- (void)setRequestTimeout:(NSTimeInterval)requestTimeout {
    if (requestTimeout <= 0) {
        return;
    }
    _requestTimeout = requestTimeout;
}

@end
