//
// GrowingHybridCustomEvent.m
// GrowingAnalytics-Autotracker-AutotrackerCore-Tracker-TrackerCore
//
//  Created by sheng on 2020/11/17.
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


#import "GrowingHybridCustomEvent.h"

@implementation GrowingHybridCustomEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingHybridCustomBuilder *subBuilder = (GrowingHybridCustomBuilder*)builder;
        _query = subBuilder.query;
    }
    return self;
}


+ (GrowingHybridCustomBuilder*)builder {
    return [[GrowingHybridCustomBuilder alloc] init];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"query"] = self.query;
    return dataDictM;;
}

@end

@implementation GrowingHybridCustomBuilder

- (GrowingHybridCustomBuilder *(^)(NSString *value))setQuery {
    return  ^(NSString *value){
        self->_query = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    return [[GrowingHybridCustomEvent alloc] initWithBuilder:self];
}

@end
