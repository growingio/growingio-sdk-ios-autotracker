//
//  GrowingEventJSONDatabase.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/8/7.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Services/Database/GrowingEventJSONDatabase.h"
#import "Services/Database/FMDB/GrowingFMDB.h"
#import "Services/Database/GrowingEventFMDatabase+Private.h"
#import "Services/Database/GrowingEventJSONPersistence.h"

GrowingService(GrowingEventDatabaseService, GrowingEventJSONDatabase)

@implementation GrowingEventJSONDatabase

#pragma mark - Init

+ (instancetype)databaseWithPath:(NSString *)path error:(NSError **)error {
    return [super databaseWithPath:path persistenceClass:GrowingEventJSONPersistence.class error:error];
}

#pragma mark - Private Methods

- (BOOL)initDB {
    NSString *sqlInit =
        @"CREATE TABLE IF NOT EXISTS namedcachetable("
        @"id INTEGER PRIMARY KEY,"
        @"name TEXT,"
        @"key TEXT,"
        @"value TEXT,"
        @"createAt INTEGER NOT NULL,"
        @"type TEXT,"
        @"policy INTEGER);";
    NSString *sqlCreateIndex = @"CREATE INDEX IF NOT EXISTS namedcachetable_key ON namedcachetable (key);";
    return [self initDB:sqlInit createIndex:sqlCreateIndex];
}

- (void)enumerateKeysAndValuesUsingBlock:
    (void (^)(NSString *key, id value, NSString *type, NSUInteger policy, BOOL **stop))block {
    [self enumerateTableUsingBlock:^(GrowingFMResultSet *set, BOOL *s) {
        NSString *key = [set stringForColumn:@"key"];
        id value = [set stringForColumn:@"value"];
        NSString *type = [set stringForColumn:@"type"];
        NSUInteger policy = [set intForColumn:@"policy"];
        block(key, value, type, policy, &s);
    }];
}

@end
