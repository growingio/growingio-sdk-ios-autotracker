//
// GrowingEventFMDatabase.h
// GrowingAnalytics
//
//  Created by YoloMao on 2021/7/5.
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
#import "GrowingEventDatabaseService.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingEventFMDatabase : NSObject <GrowingEventDatabaseService>

+ (instancetype)databaseWithPath:(NSString *)path error:(NSError **)error;

- (NSInteger)countOfEvents;

- (NSArray<GrowingEventPersistence *> *)getEventsByCount:(NSUInteger)count;

- (NSArray<GrowingEventPersistence *> *)getEventsByCount:(NSUInteger)count policy:(NSUInteger)mask;

- (BOOL)insertEvent:(GrowingEventPersistence *)event;

- (BOOL)insertEvents:(NSArray<GrowingEventPersistence *> *)events;

- (BOOL)deleteEvent:(NSString *)key;

- (BOOL)deleteEvents:(NSArray<NSString *> *)keys;

- (BOOL)clearAllEvents;

- (BOOL)cleanExpiredEventIfNeeded;

- (NSError *)lastError;

@end

NS_ASSUME_NONNULL_END
