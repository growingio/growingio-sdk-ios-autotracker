//
// GrowingHybridPageAttributesEvent.m
// GrowingAnalytics
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


#import "GrowingHybridPageAttributesEvent.h"

@implementation GrowingHybridPageAttributesEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingHybridPageAttributesBuilder *subBuilder = (GrowingHybridPageAttributesBuilder*)builder;
        _query = subBuilder.query;
    }
    return self;
}


+ (GrowingHybridPageAttributesBuilder*)builder {
    return [[GrowingHybridPageAttributesBuilder alloc] init];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"query"] = self.query;
    return dataDictM;;
}


@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingHybridPageAttributesBuilder

- (GrowingHybridPageAttributesBuilder *(^)(NSString *value))setQuery {
    return  ^(NSString *value){
        self->_query = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    return [[GrowingHybridPageAttributesEvent alloc] initWithBuilder:self];
}

@end
#pragma clang diagnostic pop
