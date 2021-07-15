//
// GrowingCustomEvent.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/12.
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


#import "GrowingCustomEvent.h"
@implementation GrowingCustomEvent


- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingCustomBuilder *subBuilder = (GrowingCustomBuilder*)builder;
        _eventName = subBuilder.eventName;
    }
    return self;
}

+ (GrowingCustomBuilder *)builder {
    return [[GrowingCustomBuilder alloc]init];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"eventName"] = self.eventName;
    return [dataDictM copy];
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingCustomBuilder

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmethod-signatures"
#pragma clang diagnostic ignored "-Wmismatched-return-types"
- (GrowingBaseBuilder *(^)(NSString *value))setEventName {
    return ^(NSString *value) {
        self->_eventName = value;
        return self;
    };
}
#pragma clang diagnostic pop

- (NSString *)eventType {
    return GrowingEventTypeCustom;
}

- (GrowingBaseEvent *)build {
    return [[GrowingCustomEvent alloc] initWithBuilder:self];
}


@end
#pragma clang diagnostic pop
