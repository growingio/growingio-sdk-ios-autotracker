//
//  GrowingGA3Event.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/31.
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

#import "Modules/GA3Adapter/GrowingGA3Event.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"

@implementation GrowingGA3Event

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingGA3Builder *subBuilder = (GrowingGA3Builder *)builder;
        _baseEvent = subBuilder.baseEvent;
        _info = subBuilder.info;
    }
    return self;
}

+ (GrowingGA3Builder *_Nonnull)builder {
    return [[GrowingGA3Builder alloc] init];
}

- (GrowingEventSendPolicy)sendPolicy {
    return self.baseEvent.sendPolicy;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[self.baseEvent toDictionary]];
    dataDictM[@"userKey"] = nil; // 如果存在则移除userKey字段
    dataDictM[@"gioId"] = nil; // 如果存在则移除gioId字段
    dataDictM[@"dataSourceId"] = self.info.dataSourceId; // 替换dataSourceId
    dataDictM[@"sessionId"] = self.info.sessionId; // 替换sessionId
    dataDictM[@"userId"] = self.info.userId; // 替换userId
    if (self.timestamp > 0) { // 如果timestamp不为0，替换timestamp
        dataDictM[@"timestamp"] = @(self.timestamp);
    }
    
    // CUSTOM需要处理通用参数
    if ([self.eventType isEqualToString:GrowingEventTypeCustom]) {
        NSDictionary <NSString *, NSObject *> *attributes = dataDictM[@"attributes"] ? : @{};
        NSMutableDictionary *defaultParameters = self.info.extraParams.mutableCopy;
        [defaultParameters addEntriesFromDictionary:attributes]; // 如果与send设置的字段冲突，优先使用send方法中设置的字段值
        dataDictM[@"attributes"] = defaultParameters.copy;
    }
    return [dataDictM copy];
}

@end

@implementation GrowingGA3Builder

- (GrowingBaseEvent *)build {
    return [[GrowingGA3Event alloc] initWithBuilder:self];
}

- (NSString *)eventType {
    return self->_baseEvent.eventType;
}

- (GrowingGA3Builder *(^)(GrowingBaseEvent *baseEvent))setBaseEvent {
    return ^(GrowingBaseEvent *baseEvent) {
        self->_baseEvent = baseEvent;
        return self;
    };
}

- (GrowingGA3Builder *(^)(GrowingGA3TrackerInfo *info))setTrackerInfo {
    return ^(GrowingGA3TrackerInfo *info) {
        self->_info = info;
        return self;
    };
}

@end
