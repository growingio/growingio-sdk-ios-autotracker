//
// GrowingEventPersistence.h
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


#import <Foundation/Foundation.h>
#import "GrowingBaseEvent.h"
NS_ASSUME_NONNULL_BEGIN

@interface GrowingEventPersistence : NSObject

@property (nonatomic, copy, readonly) NSString *_Nonnull eventUUID;
@property (nonatomic, copy, readonly) NSString *_Nonnull eventType;
@property (nonatomic, copy, readonly) NSString *_Nonnull rawJsonString;

- (instancetype _Nonnull)initWithUUID:(NSString *_Nonnull)uuid
                            eventType:(NSString *_Nonnull)evnetType
                           jsonString:(NSString *_Nonnull)jsonString;

+ (instancetype _Nonnull)persistenceEventWithEvent:(GrowingBaseEvent *_Nonnull)event uuid:(NSString *)uuid;

+ (NSArray<NSString *> *_Nonnull)buildRawEventsFromEvents:(NSArray<GrowingEventPersistence *> *_Nonnull)events;


@end

NS_ASSUME_NONNULL_END
