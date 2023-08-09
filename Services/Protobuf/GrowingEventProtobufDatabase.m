//
//  GrowingEventProtobufDatabase.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/11.
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

#import "Services/Protobuf/GrowingEventProtobufDatabase.h"
#import "Services/Database/FMDB/GrowingFMDB.h"
#import "Services/Database/GrowingEventFMDatabase+Private.h"
#import "Services/Protobuf/GrowingEventProtobufPersistence.h"

GrowingService(GrowingPBEventDatabaseService, GrowingEventProtobufDatabase)

@implementation GrowingEventProtobufDatabase

#pragma mark - Init

+ (instancetype)databaseWithPath:(NSString *)path error:(NSError **)error {
    NSString *lastPathComponent = [NSURL fileURLWithPath:path].lastPathComponent;
    lastPathComponent = [NSString stringWithFormat:@"enc_%@", lastPathComponent];
    NSURL *url = [NSURL fileURLWithPath:path].URLByDeletingLastPathComponent;
    path = [url URLByAppendingPathComponent:lastPathComponent].path;

    return [super databaseWithPath:path error:error];
}

+ (Class)persistenceClass {
    return GrowingEventProtobufPersistence.class;
}

#pragma mark - Private Methods

- (BOOL)initDB {
    NSString *sqlInit =
        @"CREATE TABLE IF NOT EXISTS namedcachetable("
        @"id INTEGER PRIMARY KEY,"
        @"key TEXT,"
        @"value BLOB,"
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
        id value = [set dataForColumn:@"value"];
        NSString *type = [set stringForColumn:@"type"];
        NSUInteger policy = [set intForColumn:@"policy"];
        block(key, value, type, policy, &s);
    }];
}

@end
