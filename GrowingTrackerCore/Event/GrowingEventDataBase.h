//
//  GrowingEventDataBase.h
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

typedef NS_ENUM(NSInteger , GrowingEventDataBaseError)
{
    GrowingEventDataBaseOpenError,
    GrowingEventDataBaseWriteError,
    GrowingEventDataBaseReadError,
    GrowingEventDataBaseCreateDBError, // for future use
    
};


@interface GrowingEventDataBase : NSObject

@property (nonatomic, assign) NSUInteger autoFlushCount;

+ (instancetype)databaseWithPath:(NSString*)path name:(NSString *)name;

@property (nonatomic, readonly) NSString *name;

- (NSError*)enumerateKeysAndValuesUsingBlock:(void (^)(NSString *, NSString *, NSString *, BOOL *))block;
- (NSUInteger)countOfEvents;

- (void)setEvent:(GrowingEventPersistence *)event forKey:(NSString *)key error:(NSError **)error;
- (void)setEvent:(GrowingEventPersistence *)event forKey:(NSString *)key;

- (NSError*)clearAllItems;

- (NSError*)flush;

- (NSError*)vacuum;

- (NSError *)cleanExpiredDataIfNeeded;

- (NSArray <GrowingEventPersistence *>*)getEventsWithPackageNum:(NSUInteger)packageNum;

- (void)handleDatabaseError:(NSError *)error;

@end
