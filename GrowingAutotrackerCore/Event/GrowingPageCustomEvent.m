//
// GrowingPageCustomEvent.m
// GrowingAnalytics-Autotracker-AutotrackerCore-Tracker-TrackerCore
//
//  Created by sheng on 2020/11/16.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingPageCustomEvent.h"

@implementation GrowingPageCustomEvent

+ (GrowingPageCustomBuilder *)builder {
    return [[GrowingPageCustomBuilder alloc] init];
}

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingPageCustomBuilder *subBuilder = (GrowingPageCustomBuilder*)builder;
        _path = subBuilder.pageName;
        _pageShowTimestamp = subBuilder.pageShowTimestamp;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"path"] = self.path;
    dataDictM[@"pageShowTimestamp"] = @(self.pageShowTimestamp);
    return dataDictM;;
}

@end


@implementation GrowingPageCustomBuilder

- (GrowingPageCustomBuilder *(^)(NSString *value))setPath {
    return ^(NSString *value) {
        self->_pageName = value;
        return self;
    };
}

- (GrowingPageCustomBuilder *(^)(long long value))setPageShowTimestamp {
    return ^(long long value) {
        self->_pageShowTimestamp = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    return [[GrowingPageCustomEvent alloc] initWithBuilder:self];
}

@end
