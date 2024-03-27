//
//  GrowingEventDatabase.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/11/25.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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
#import "GrowingEventDatabaseService.h"

@interface GrowingEventDatabase : NSObject

@property (nonatomic, assign) NSUInteger autoFlushCount;

+ (instancetype)databaseWithPath:(NSString *)path isProtobuf:(BOOL)isProtobuf;

- (NSUInteger)countOfEvents;

- (BOOL)flush;

- (BOOL)clearAllItems;

- (void)setEvent:(id<GrowingEventPersistenceProtocol>)event forKey:(NSString *)key;

- (NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsByCount:(NSUInteger)count limitSize:(NSUInteger)limitSize policy:(NSUInteger)mask;

- (NSData *)buildRawEventsFromEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events;

- (id<GrowingEventPersistenceProtocol>)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid;

@end
