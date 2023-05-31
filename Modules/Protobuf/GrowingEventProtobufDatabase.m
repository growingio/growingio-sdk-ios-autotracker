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

#import "Modules/Protobuf/GrowingEventProtobufDatabase.h"
#import "GrowingULTimeUtil.h"
#import "Modules/Protobuf/GrowingEventProtobufPersistence.h"
#import "Services/Database/FMDB/GrowingFMDB.h"

@interface GrowingEventProtobufDatabase ()

@property (nonatomic, copy, readonly) NSString *lastPathComponent;

@end

@implementation GrowingEventProtobufDatabase

#pragma mark - Init

+ (instancetype)databaseWithPath:(NSString *)path error:(NSError **)error {
    return [[self alloc] initWithFilePath:path error:error];
}

- (instancetype)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self makeDirByFileName:filePath];
        });

        NSString *lastPathComponent = [NSURL fileURLWithPath:filePath].lastPathComponent;
        _lastPathComponent = [NSString stringWithFormat:@"enc_%@", lastPathComponent];
        NSURL *url = [NSURL fileURLWithPath:filePath].URLByDeletingLastPathComponent;
        NSString *path = [url URLByAppendingPathComponent:_lastPathComponent].path;

        self.db = [GrowingFMDatabaseQueue databaseQueueWithPath:path];
        if (!self.db) {
            self.databaseError = [self createDBErrorInDatabase:nil];
        } else {
            [self initDB];
        }

        if (error) {
            *error = self.databaseError;
        }
    }

    return self;
}

#pragma mark - Public Methods

+ (NSData *)buildRawEventsFromEvents:(NSArray<GrowingEventProtobufPersistence *> *)events {
    return [GrowingEventProtobufPersistence buildRawEventsFromEvents:events];
}

+ (GrowingEventProtobufPersistence *)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid {
    return [GrowingEventProtobufPersistence persistenceEventWithEvent:event uuid:uuid];
}

- (NSInteger)countOfEvents {
    __block NSInteger count = 0;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            count = -1;
            return;
        }

        GrowingFMResultSet *set = [db executeQuery:@"SELECT COUNT(*) FROM namedcachetable"];
        if (!set) {
            self.databaseError = [self readErrorInDatabase:db];
            count = -1;
            return;
        }

        if ([set next]) {
            count = (NSUInteger)[set longLongIntForColumnIndex:0];
        }

        [set close];
    }];

    return count;
}

- (nullable NSArray<GrowingEventProtobufPersistence *> *)getEventsByCount:(NSUInteger)count {
    if (self.countOfEvents == 0) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<GrowingEventProtobufPersistence *> *events = [[NSMutableArray alloc] init];
    [self enumerateKeysAndValuesUsingBlock:^(NSString *key,
                                             NSData *value,
                                             NSString *type,
                                             NSUInteger policy,
                                             BOOL *stop) {
        GrowingEventProtobufPersistence *event = [[GrowingEventProtobufPersistence alloc] initWithUUID:key
                                                                                             eventType:type
                                                                                                  data:value
                                                                                                policy:policy];
        [events addObject:event];
        if (events.count >= count) {
            *stop = YES;
        }
    }];

    return events.count != 0 ? events : nil;
}

- (nullable NSArray<GrowingEventProtobufPersistence *> *)getEventsByCount:(NSUInteger)count policy:(NSUInteger)mask {
    if (self.countOfEvents == 0) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<GrowingEventProtobufPersistence *> *events = [[NSMutableArray alloc] init];
    [self enumerateKeysAndValuesUsingBlock:^(NSString *key,
                                             NSData *value,
                                             NSString *type,
                                             NSUInteger policy,
                                             BOOL *stop) {
        if (mask & policy) {
            GrowingEventProtobufPersistence *event = [[GrowingEventProtobufPersistence alloc] initWithUUID:key
                                                                                                 eventType:type
                                                                                                      data:value
                                                                                                    policy:policy];
            [events addObject:event];
            if (events.count >= count) {
                *stop = YES;
            }
        }
    }];

    return events.count != 0 ? events : nil;
}

- (BOOL)insertEvent:(GrowingEventProtobufPersistence *)event {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"INSERT INTO namedcachetable(key,value,createAt,type,policy) VALUES(?,?,?,?,?)",
                                   event.eventUUID,
                                   ((GrowingEventProtobufPersistence *)event).data,
                                   @([GrowingULTimeUtil currentTimeMillis]),
                                   event.eventType,
                                   @(event.policy)];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)insertEvents:(NSArray<GrowingEventProtobufPersistence *> *)events {
    if (!events || events.count == 0) {
        return YES;
    }

    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        for (int i = 0; i < events.count; i++) {
            GrowingEventProtobufPersistence *event = (GrowingEventProtobufPersistence *)events[i];
            result = [db executeUpdate:@"INSERT INTO namedcachetable(key,value,createAt,type,policy) VALUES(?,?,?,?,?)",
                                       event.eventUUID,
                                       event.data,
                                       @([GrowingULTimeUtil currentTimeMillis]),
                                       event.eventType,
                                       @(event.policy)];

            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)deleteEvent:(NSString *)key {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"DELETE FROM namedcachetable WHERE key=?;", key];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)deleteEvents:(NSArray<NSString *> *)keys {
    if (!keys || keys.count == 0) {
        return YES;
    }

    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }

        for (NSString *key in keys) {
            result = [db executeUpdate:@"DELETE FROM namedcachetable WHERE key=?;", key];
            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)clearAllEvents {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"DELETE FROM namedcachetable"];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)cleanExpiredEventIfNeeded {
    NSNumber *now = [NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970] * 1000LL)];
    NSNumber *sevenDayBefore = [NSNumber numberWithLongLong:(now.longLongValue - GrowingEventDatabaseExpirationTime)];

    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"DELETE FROM namedcachetable WHERE createAt<=?;", sevenDayBefore];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (NSError *)lastError {
    return self.databaseError;
}

#pragma mark - Private Methods

- (BOOL)initDB {
    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }

        NSString *sql =
            @"CREATE TABLE IF NOT EXISTS namedcachetable("
            @"id INTEGER PRIMARY KEY,"
            @"key TEXT,"
            @"value BLOB,"
            @"createAt INTEGER NOT NULL,"
            @"type TEXT,"
            @"policy INTEGER);";
        NSString *sqlCreateIndexKey = @"CREATE INDEX IF NOT EXISTS namedcachetable_key ON namedcachetable (key);";
        if (![db executeUpdate:sql]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }
        if (![db executeUpdate:sqlCreateIndexKey]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }
        result = YES;
    }];

    if (result) {
        return [self vacuum];
    } else {
        return result;
    }
}

- (BOOL)vacuum {
    if (!isExecuteVacuum(self.lastPathComponent)) {
        return YES;
    }

    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"VACUUM namedcachetable"];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

static BOOL isExecuteVacuum(NSString *name) {
    if (name.length == 0) {
        return NO;
    }
    NSString *vacuumDate =
        [NSString stringWithFormat:@"GIO_VACUUM_DATE_E7B96C4E-6EE2-49CD-87F0-B2E62D4EE96A-ENCODE-%@", name];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDate *beforeDate = [userDefault objectForKey:vacuumDate];
    NSDate *nowDate = [NSDate date];

    if (beforeDate) {
        NSDateComponents *delta = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                  fromDate:beforeDate
                                                                    toDate:nowDate
                                                                   options:0];
        BOOL flag = delta.day > 7 || delta.day < 0;
        if (flag) {
            [userDefault setObject:nowDate forKey:vacuumDate];
            [userDefault synchronize];
        }
        return flag;
    } else {
        [userDefault setObject:nowDate forKey:vacuumDate];
        [userDefault synchronize];
        return YES;
    }
}

- (void)makeDirByFileName:(NSString *)filePath {
    [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

- (void)enumerateKeysAndValuesUsingBlock:
    (void (^)(NSString *key, NSData *value, NSString *type, NSUInteger policy, BOOL *stop))block {
    if (!block) {
        return;
    }

    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        GrowingFMResultSet *set = [db executeQuery:@"SELECT * FROM namedcachetable ORDER BY id ASC"];
        if (!set) {
            self.databaseError = [self readErrorInDatabase:db];
            return;
        }

        BOOL stop = NO;
        while (!stop && [set next]) {
            NSString *key = [set stringForColumn:@"key"];
            NSData *value = [set dataForColumn:@"value"];
            NSString *type = [set stringForColumn:@"type"];
            NSUInteger policy = [set intForColumn:@"policy"];
            block(key, value, type, policy, &stop);
        }

        [set close];
    }];
}

#pragma mark - Perform Block

- (void)performDatabaseBlock:(void (^)(GrowingFMDatabase *db, NSError *error))block {
    [self.db inDatabase:^(GrowingFMDatabase *db) {
        if (!db) {
            block(db, [self openErrorInDatabase:db]);
        } else {
            block(db, nil);
        }
    }];
}

- (void)performTransactionBlock:(void (^)(GrowingFMDatabase *db, BOOL *rollback, NSError *error))block {
    [self.db inTransaction:^(GrowingFMDatabase *db, BOOL *rollback) {
        if (!db) {
            block(db, rollback, [self openErrorInDatabase:db]);
        } else {
            block(db, rollback, nil);
        }
    }];
}

#pragma mark - Error

- (NSError *)openErrorInDatabase:(GrowingFMDatabase *)db {
    return [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                               code:GrowingEventDatabaseOpenError
                           userInfo:@{NSLocalizedDescriptionKey: @"open database error"}];
}

- (NSError *)readErrorInDatabase:(GrowingFMDatabase *)db {
    return [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                               code:GrowingEventDatabaseReadError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)writeErrorInDatabase:(GrowingFMDatabase *)db {
    return [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                               code:GrowingEventDatabaseWriteError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)createDBErrorInDatabase:(GrowingFMDatabase *)db {
    return
        [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                            code:GrowingEventDatabaseCreateDBError
                        userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"Could not create database")}];
}

@end
