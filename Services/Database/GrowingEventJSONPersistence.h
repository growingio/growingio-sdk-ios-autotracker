//
//  GrowingEventJSONPersistence.h
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

#import <Foundation/Foundation.h>
#import "GrowingEventPersistenceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingEventJSONPersistence : NSObject <GrowingEventPersistenceProtocol>

@property (nonatomic, copy, readonly) NSString *eventUUID;
@property (nonatomic, copy, readonly) NSString *eventType;
@property (nonatomic, copy, readonly) NSString *rawJsonString;
@property (nonatomic, assign, readonly) GrowingEventSendPolicy policy;

- (instancetype)initWithUUID:(NSString *)uuid
                   eventType:(NSString *)eventType
                  jsonString:(NSString *)jsonString
                      policy:(GrowingEventSendPolicy)policy;

+ (instancetype)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid;

+ (NSData *)buildRawEventsFromEvents:(NSArray<GrowingEventJSONPersistence *> *)events;

@end

NS_ASSUME_NONNULL_END
