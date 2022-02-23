//
//  GrowingEventProtobufPersistence.m
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

#import "GrowingEventProtobufPersistence.h"
#import "GrowingEvent.pbobjc.h"
#import "GrowingBaseEvent+Protobuf.h"
#import "GrowingPBEventV3Dto+GrowingHelper.h"

@interface GrowingEventProtobufPersistence ()

@property (nonatomic, strong, readonly, nullable) GrowingPBEventV3Dto *dto;

@end

@implementation GrowingEventProtobufPersistence

- (instancetype)initWithUUID:(NSString *)uuid
                   eventType:(NSString *)eventType
                        data:(NSData *)data
                      policy:(GrowingEventSendPolicy)policy {
    if (self = [super init]) {
        _eventUUID = uuid;
        _eventType = eventType;
        _data = data;
        _dto = [GrowingPBEventV3Dto parseFromData:data error:nil];
        _policy = policy;
    }
    return self;
}

+ (instancetype)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid {
    GrowingEventProtobufPersistence *persistence = [[GrowingEventProtobufPersistence alloc] init];
    persistence->_eventUUID = uuid;
    persistence->_eventType = event.eventType;
    persistence->_policy = event.sendPolicy;
    persistence->_dto = event.toProtobuf;
    persistence->_data = (persistence->_dto).data;
    return persistence;
}

+ (NSData *)buildRawEventsFromEvents:(NSArray<GrowingEventProtobufPersistence *> *)events {
    GrowingPBEventV3List *list = [[GrowingPBEventV3List alloc] init];
    for (GrowingEventProtobufPersistence *e in events) {
        if (e.dto) {
            [list.valuesArray addObject:e.dto];
        }
    }
    return list.data;
}

- (id)toJSONObject {
    if (!self.dto) {
        return [NSDictionary dictionary];
    }
    return self.dto.growingHelper_jsonObject;
}

@end
