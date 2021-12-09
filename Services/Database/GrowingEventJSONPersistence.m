//
//  GrowingEventJSONPersistence.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/11/30.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingEventJSONPersistence.h"
#import "NSString+GrowingHelper.h"

@implementation GrowingEventJSONPersistence

- (instancetype)initWithUUID:(NSString *)uuid
                   eventType:(NSString *)eventType
                  jsonString:(NSString *)jsonString
                      policy:(GrowingEventSendPolicy)policy {
    if (self = [super init]) {
        _eventUUID = uuid;
        _eventType = eventType;
        _rawJsonString = jsonString;
        _policy = policy;
    }
    return self;
}

+ (instancetype)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid {
    NSString *eventJsonString = [[NSString alloc] initWithJsonObject_growingHelper:event.toDictionary];

    return [[GrowingEventJSONPersistence alloc] initWithUUID:uuid
                                               eventType:event.eventType
                                              jsonString:eventJsonString
                                                  policy:event.sendPolicy];
}

+ (NSData *)buildRawEventsFromEvents:(NSArray<GrowingEventJSONPersistence *> *)events {
    NSMutableArray *raws = [NSMutableArray array];
    for (GrowingEventJSONPersistence *e in events) {
        NSString *rawStr = e.rawJsonString;
        if (rawStr && rawStr.length > 0) {
            [raws addObject:rawStr];
        }
    }
    NSString *jsonString = [NSString stringWithFormat:@"[%@]", [raws componentsJoinedByString:@","]];
    NSData *JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return JSONData;
}

- (id)toJSONObject {
    return self.rawJsonString.growingHelper_jsonObject;
}

@end
