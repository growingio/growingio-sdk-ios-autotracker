//
// GrowingPageAttributesEvent.m
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


#import "GrowingPageAttributesEvent.h"

@implementation GrowingPageAttributesEvent

- (instancetype)initWithBuilder:(GrowingPageAttributesBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingPageAttributesBuilder *subBuilder = (GrowingPageAttributesBuilder*)builder;
        _pageName = subBuilder.pageName;
        _pageShowTimestamp = subBuilder.pageShowTimestamp;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"pageName"] = self.pageName;
    dataDictM[@"pageShowTimestamp"] = @(self.pageShowTimestamp);
    return dataDictM;;
}

+ (GrowingPageAttributesBuilder *)builder {
    return [[GrowingPageAttributesBuilder alloc] init];
}

@end

@implementation GrowingPageAttributesBuilder

- (GrowingPageAttributesBuilder *(^)(NSString *value))setPageName {
    return ^(NSString *value) {
        self->_pageName = value;
        return self;
    };
}

- (GrowingPageAttributesBuilder *(^)(long long value))setPageShowTimestamp{
    return ^(long long value) {
        self->_pageShowTimestamp = value;
        return self;
    };
}


- (NSString *)eventType {
    return GrowingEventTypePageAttributes;
}

- (GrowingBaseEvent *)build {
    return [[GrowingPageAttributesEvent alloc] initWithBuilder:self];
}

@end
