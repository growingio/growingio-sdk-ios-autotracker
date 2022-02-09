//
// GrowingPageEvent.m
// GrowingAnalytics
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

#import "GrowingPageEvent.h"

#import "GrowingDeviceInfo.h"

@implementation GrowingPageEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingPageBuilder *subBuilder = (GrowingPageBuilder *)builder;
        _pageName = subBuilder.pageName;
        _orientation = subBuilder.orientation;
        _title = subBuilder.title;
        _referralPage = subBuilder.referralPage;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"path"] = self.pageName;
    dataDictM[@"orientation"] = self.orientation;
    dataDictM[@"title"] = self.title;
    dataDictM[@"referralPage"] = self.referralPage;
    return dataDictM;
}

+ (GrowingPageBuilder *)builder {
    return [[GrowingPageBuilder alloc] init];
}

@end

@implementation GrowingPageBuilder

- (void)readPropertyInTrackThread {
    [super readPropertyInTrackThread];
    _orientation = [GrowingDeviceInfo currentDeviceInfo].deviceOrientation;
}

- (GrowingPageBuilder * (^)(NSString *value))setPath {
    return ^(NSString *value) {
        self->_pageName = value;
        return self;
    };
}
- (GrowingPageBuilder * (^)(NSString *value))setOrientation {
    return ^(NSString *value) {
        self->_orientation = value;
        return self;
    };
}
- (GrowingPageBuilder * (^)(NSString *value))setTitle {
    return ^(NSString *value) {
        self->_title = value;
        return self;
    };
}
- (GrowingPageBuilder * (^)(NSString *value))setReferralPage {
    return ^(NSString *value) {
        self->_referralPage = value;
        return self;
    };
}

- (NSString *)eventType {
    return GrowingEventTypePage;
}

- (GrowingBaseEvent *)build {
    return [[GrowingPageEvent alloc] initWithBuilder:self];
}

@end
