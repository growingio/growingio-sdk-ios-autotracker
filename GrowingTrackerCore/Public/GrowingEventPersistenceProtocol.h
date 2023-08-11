//
// GrowingEventPersistenceProtocol.h
// GrowingAnalytics
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

#import <Foundation/Foundation.h>
#import "GrowingBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GrowingEventPersistenceProtocol

@property (nonatomic, copy, readonly) NSString *eventUUID;
@property (nonatomic, copy, readonly) NSString *eventType;
@property (nonatomic, strong, readonly) id data;
@property (nonatomic, assign, readonly) GrowingEventSendPolicy policy;
@property (nonatomic, copy, readonly) NSString *sdkVersion;

+ (instancetype)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid;

+ (NSData *)buildRawEventsFromEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events;

+ (NSData *)buildRawEventsFromJsonObjects:(NSArray<NSDictionary *> *)jsonObjects;

- (instancetype)initWithUUID:(NSString *)uuid
                   eventType:(NSString *)eventType
                        data:(id)data
                      policy:(GrowingEventSendPolicy)policy
                  sdkVersion:(NSString *)sdkVersion;

- (id)toJSONObject;

- (void)appendExtraParams:(NSDictionary<NSString *, id> *)extraParams;

@end

NS_ASSUME_NONNULL_END
