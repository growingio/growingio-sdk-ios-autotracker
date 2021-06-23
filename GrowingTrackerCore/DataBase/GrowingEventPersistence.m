//
// GrowingEventPersistence.m
// Pods
//
//  Created by sheng on 2020/11/13.
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


#import "GrowingEventPersistence.h"
#import "NSString+GrowingHelper.h"

@implementation GrowingEventPersistence

- (instancetype)initWithUUID:(NSString *)uuid eventType:(NSString *)evnetType jsonString:(NSString *)jsonString {
    if (self = [super init]) {
        _eventUUID = uuid;
        _eventType = evnetType;
        _rawJsonString = jsonString;
    }
    return self;
}

+ (instancetype)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid{
    NSString *eventJsonString = [[NSString alloc] initWithJsonObject_growingHelper:event.toDictionary];

    return [[GrowingEventPersistence alloc] initWithUUID:uuid
                                               eventType:event.eventType
                                              jsonString:eventJsonString];
}

+ (NSArray<NSString *> *)buildRawEventsFromEvents:(NSArray<GrowingEventPersistence *> *)events {
    NSMutableArray *raws = [NSMutableArray array];
    for (GrowingEventPersistence *e in events) {
        NSString *rawStr = e.rawJsonString;
        if (rawStr && rawStr.length > 0) {
            [raws addObject:rawStr];
        }
    }
    return raws;
}

@end

