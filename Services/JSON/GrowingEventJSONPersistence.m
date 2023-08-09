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

#import "Services/JSON/GrowingEventJSONPersistence.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

@implementation GrowingEventJSONPersistence

- (instancetype)initWithUUID:(NSString *)uuid
                   eventType:(NSString *)eventType
                        data:(id)data
                      policy:(GrowingEventSendPolicy)policy {
    if (self = [super init]) {
        _eventUUID = uuid;
        _eventType = eventType;
        _data = data;
        _policy = policy;
    }
    return self;
}

+ (instancetype)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid {
    NSString *eventJsonString = [[NSString alloc] initWithJsonObject_growingHelper:event.toDictionary];

    return [[GrowingEventJSONPersistence alloc] initWithUUID:uuid
                                                   eventType:event.eventType
                                                        data:eventJsonString
                                                      policy:event.sendPolicy];
}

+ (NSData *)buildRawEventsFromEvents:(NSArray<GrowingEventJSONPersistence *> *)events {
    NSMutableArray *raws = [NSMutableArray array];
    for (GrowingEventJSONPersistence *e in events) {
        NSString *rawStr = e.data;
        if (rawStr && rawStr.length > 0) {
            [raws addObject:rawStr];
        }
    }
    NSString *jsonString = [NSString stringWithFormat:@"[%@]", [raws componentsJoinedByString:@","]];
    NSData *JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return JSONData;
}

+ (NSData *)buildRawEventsFromJsonObjects:(NSArray<NSDictionary *> *)jsonObjects {
    // 如果是3.x的数据，会多出gioId/globalSequenceId字段
    return [jsonObjects growingHelper_jsonData];
}

- (id)toJSONObject {
    return ((NSString *)self.data).growingHelper_jsonObject;
}

- (void)appendExtraParams:(NSDictionary<NSString *, id> *)extraParams {
    if (!extraParams || extraParams.count == 0) {
        return;
    }
    NSMutableDictionary *dictM = [(NSDictionary *)[self toJSONObject] mutableCopy];
    NSMutableDictionary *attributes =
        dictM[@"attributes"] ? [(NSDictionary *)dictM[@"attributes"] mutableCopy] : [NSMutableDictionary dictionary];
    [attributes addEntriesFromDictionary:extraParams];
    dictM[@"attributes"] = attributes.copy;
    NSString *eventJsonString = [[NSString alloc] initWithJsonObject_growingHelper:dictM];
    _data = eventJsonString;
}

@end
