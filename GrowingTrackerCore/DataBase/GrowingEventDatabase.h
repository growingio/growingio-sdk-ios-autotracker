//
//  GrowingEventDatabase.h
//  GrowingTracker
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

@class GrowingEventPersistence;

@interface GrowingEventDatabase : NSObject

@property (nonatomic, assign) NSUInteger autoFlushCount;

+ (instancetype)databaseWithPath:(NSString *)path;

- (NSUInteger)countOfEvents;

- (BOOL)flush;

- (BOOL)clearAllItems;

- (BOOL)cleanExpiredDataIfNeeded;

- (void)setEvent:(GrowingEventPersistence *)event forKey:(NSString *)key;

- (NSArray <GrowingEventPersistence *> *)getEventsWithPackageNum:(NSUInteger)packageNum policy:(NSUInteger)mask;

- (NSArray <GrowingEventPersistence *> *)getEventsWithPackageNum:(NSUInteger)packageNum;

@end
