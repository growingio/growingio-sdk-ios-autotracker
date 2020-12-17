//
// GrowingHybridPageEvent.m
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


#import "GrowingHybridPageEvent.h"

@implementation GrowingHybridPageEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingHybridPageBuilder *subBuilder = (GrowingHybridPageBuilder*)builder;
        _query = subBuilder.query;
        _protocolType = subBuilder.protocolType;
    }
    return self;
}

+ (GrowingHybridPageBuilder*)builder {
    return [[GrowingHybridPageBuilder alloc] init];
}


- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"query"] = self.query;
    dataDictM[@"protocolType"] = self.protocolType;
    return dataDictM;;
}
@end


@implementation GrowingHybridPageBuilder

- (GrowingHybridPageBuilder *(^)(NSString *value))setQuery {
    return  ^(NSString *value){
        self->_query = value;
        return self;
    };
}
- (GrowingHybridPageBuilder *(^)(NSString *value))setProtocolType {
    return  ^(NSString *value){
        self->_protocolType = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    return [[GrowingHybridPageEvent alloc] initWithBuilder:self];
}

@end
