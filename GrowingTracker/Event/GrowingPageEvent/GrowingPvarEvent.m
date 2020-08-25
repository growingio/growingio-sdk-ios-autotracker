//
//  GrowingPvarEvent.m
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/5/19.
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

#import "GrowingPvarEvent.h"

@interface GrowingPvarEvent ()

@property (nonatomic, copy) NSString *_Nullable hybridDomain;
@property (nonatomic, copy, readwrite) NSString *_Nullable pageName;
@property (nonatomic, copy, readwrite) NSString *_Nullable pageTimestamp;
@property (nonatomic, copy, readwrite) NSString *_Nullable query;

@end

@implementation GrowingPvarEvent

- (NSString *)eventTypeKey {
    return kEventTypeKeyPageVariable;
}

- (instancetype)initWithPageName:(NSString *)pageName
                   showTimestamp:(NSNumber *)timestamp
                        variable:(NSDictionary *)variable {
    if (self = [super initWithTimestamp:timestamp]) {
        self.attributes = variable;
        self.pageName = pageName;
    }
    return self;
}

+ (instancetype)pvarEventWithPageName:(NSString *)pageName
                        showTimestamp:(NSNumber *)timestamp
                             variable:(NSDictionary *)variable {
    return [[GrowingPvarEvent alloc] initWithPageName:pageName showTimestamp:timestamp variable:variable];
}

+ (instancetype)hybridPvarEventWithDataDict:(NSDictionary *)dataDict {
    NSString *domain = dataDict[@"domain"];
    NSString *pageName = dataDict[@"pageName"];
    NSNumber *timestamp = dataDict[@"pageShowTimestamp"];
    NSDictionary *attributes = dataDict[@"attributes"];
    NSString *query = dataDict[@"queryParameters"];

    GrowingPvarEvent *pvarEvent = [[self alloc] initWithPageName:pageName showTimestamp:timestamp variable:attributes];
    pvarEvent.hybridDomain = domain;
    pvarEvent.query = query;

    return pvarEvent;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];

    dataDictM[@"timestamp"] = self.timestamp;
    dataDictM[@"pageShowTimestamp"] = self.pageTimestamp;
    dataDictM[@"domain"] = self.hybridDomain ?: self.domain;
    dataDictM[@"pageName"] = self.pageName;
    dataDictM[@"queryParameters"] = self.query;

    return dataDictM;
}

@end
