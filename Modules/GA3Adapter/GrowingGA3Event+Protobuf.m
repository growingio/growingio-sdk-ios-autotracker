//
//  GrowingGA3Event+Protobuf.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/6/1.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#if __has_include("Dummy-GrowingModule-Protobuf.h")

#import "Modules/GA3Adapter/GrowingGA3Event+Protobuf.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "Modules/Protobuf/Proto/GrowingEvent.pbobjc.h"
#import "Modules/Protobuf/Events/GrowingBaseEvent+Protobuf.h"

@implementation GrowingGA3Event (Protobuf)

- (GrowingPBEventV3Dto *)toProtobuf {
    GrowingPBEventV3Dto *dto = self.baseEvent.toProtobuf;
    dto.userKey = nil; // 如果存在则移除userKey字段
    dto.gioId = self.info.lastUserId; // 替换gioId
    dto.dataSourceId = self.info.dataSourceId; // 替换dataSourceId
    dto.sessionId = self.info.sessionId; // 替换sessionId
    dto.userId = self.info.userId; // 替换userId
    if (self.timestamp > 0) { // 如果timestamp不为0，替换timestamp
        dto.timestamp = self.timestamp;
    }
    
    // CUSTOM需要处理通用参数
    if ([self.eventType isEqualToString:GrowingEventTypeCustom]) {
        NSDictionary <NSString *, NSObject *> *attributes = dto.attributes ? : @{};
        NSMutableDictionary *defaultParameters = self.info.extraParams.mutableCopy;
        [defaultParameters addEntriesFromDictionary:attributes]; // 如果与send设置的字段冲突，优先使用send方法中设置的字段值
        dto.attributes = defaultParameters.copy;
    }
    return dto;
}

@end

#endif
