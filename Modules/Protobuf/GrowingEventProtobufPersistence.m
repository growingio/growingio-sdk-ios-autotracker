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

#import "Modules/Protobuf/GrowingEventProtobufPersistence.h"

#if SWIFT_PACKAGE
@import GrowingModule_SwiftProtobuf;
#else
#import "Modules/Protobuf/Catagory/GrowingBaseEvent+Protobuf.h"
#import "Modules/Protobuf/Catagory/GrowingPBEventV3Dto+GrowingHelper.h"
#import "Modules/Protobuf/Proto/GrowingEvent.pbobjc.h"
#endif

@interface GrowingEventProtobufPersistence ()

#if SWIFT_PACKAGE
@property (nonatomic, strong, readonly, nullable) GrowingSwiftProtobuf *dtoBox;
#else
@property (nonatomic, strong, readonly, nullable) GrowingPBEventV3Dto *dto;
#endif

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
#if SWIFT_PACKAGE
        _dtoBox = [GrowingSwiftProtobuf parseFromData:data];
#else
        _dto = [GrowingPBEventV3Dto parseFromData:data error:nil];
#endif
        _policy = policy;
    }
    return self;
}

+ (instancetype)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid {
    GrowingEventProtobufPersistence *persistence = [[GrowingEventProtobufPersistence alloc] init];
    persistence->_eventUUID = uuid;
    persistence->_eventType = event.eventType;
    persistence->_policy = event.sendPolicy;

#if SWIFT_PACKAGE
    persistence->_dtoBox = event.toProtobuf;
    persistence->_data = (persistence->_dtoBox).data;
#else
    persistence->_dto = event.toProtobuf;
    persistence->_data = (persistence->_dto).data;
#endif
    return persistence;
}

+ (NSData *)buildRawEventsFromEvents:(NSArray<GrowingEventProtobufPersistence *> *)events {
#if SWIFT_PACKAGE
    NSMutableArray *list = [NSMutableArray array];
    for (GrowingEventProtobufPersistence *e in events) {
        if (e.dtoBox) {
            [list addObject:e.dtoBox];
        }
    }
    return [GrowingSwiftProtobuf serializedDatasFromList:list];
#else
    GrowingPBEventV3List *list = [[GrowingPBEventV3List alloc] init];
    for (GrowingEventProtobufPersistence *e in events) {
        if (e.dto) {
            [list.valuesArray addObject:e.dto];
        }
    }
    return list.data;
#endif
}

- (id)toJSONObject {
#if SWIFT_PACKAGE
    return self.dtoBox.toJsonObject;
#else
    if (!self.dto) {
        return [NSDictionary dictionary];
    }
    return self.dto.growingHelper_jsonObject;
#endif
}

- (void)appendExtraParams:(NSDictionary<NSString *, id> *)extraParams {
    if (!extraParams || extraParams.count == 0) {
        return;
    }

#if SWIFT_PACKAGE
    [self.dtoBox appendWithExtraParams:extraParams];
#else
    [self.dto.attributes addEntriesFromDictionary:extraParams];
#endif
}

@end
