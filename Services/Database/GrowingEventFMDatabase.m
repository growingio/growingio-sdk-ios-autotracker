//
// GrowingEventFMDatabase.m
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

#import "Services/Database/GrowingEventFMDatabase.h"
#import "GrowingTrackerCore/FileStorage/GrowingFileStorage.h"
#import "GrowingTrackerCore/Public/GrowingEventPersistenceProtocol.h"
#import "GrowingULTimeUtil.h"
#import "Services/Database/FMDB/GrowingFMDB.h"

@interface GrowingEventFMDatabase ()

@property (nonatomic, copy, readonly) NSString *lastPathComponent;

@end

@implementation GrowingEventFMDatabase

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

        _lastPathComponent = [NSURL fileURLWithPath:filePath].lastPathComponent;
        _db = [GrowingFMDatabaseQueue databaseQueueWithPath:filePath];
        if (!_db) {
            _databaseError = [self createDBErrorInDatabase:nil];
        } else {
            [self initDB];
        }

        if (error) {
            *error = _databaseError;
        }
    }

    return self;
}

+ (Class)persistenceClass {
    @throw [NSException
        exceptionWithName:NSInternalInconsistencyException
                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                 userInfo:nil];
}

#pragma mark - Public Methods

+ (NSData *)buildRawEventsFromEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events {
    return [self.persistenceClass buildRawEventsFromEvents:events];
}

+ (NSData *)buildRawEventsFromJsonObjects:(NSArray<NSDictionary *> *)jsonObjects {
    return [self.persistenceClass buildRawEventsFromJsonObjects:jsonObjects];
}

+ (id<GrowingEventPersistenceProtocol>)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid {
    return [self.persistenceClass persistenceEventWithEvent:event uuid:uuid];
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

- (nullable NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsByCount:(NSUInteger)count
                                                                  limitSize:(NSUInteger)limitSize
                                                                     policy:(NSUInteger)mask {
    NSInteger countOfEvents = [self countOfEvents];
    if (countOfEvents == 0) {
        return [[NSArray alloc] init];
    } else if (countOfEvents == -1) {
        return nil;
    }

    NSMutableArray<id<GrowingEventPersistenceProtocol>> *events = [[NSMutableArray alloc] init];
    __block NSUInteger eventsLength = 0;
    [self enumerateKeysAndValuesUsingBlock:^(NSString *key,
                                             id value,
                                             NSString *type,
                                             NSUInteger policy,
                                             NSString *sdkVersion,
                                             BOOL **stop) {
        if (mask & policy) {
            id<GrowingEventPersistenceProtocol> event = [[self.class.persistenceClass alloc] initWithUUID:key
                                                                                                eventType:type
                                                                                                     data:value
                                                                                                   policy:policy
                                                                                               sdkVersion:sdkVersion];
            if ([value isKindOfClass:[NSString class]]) {
                eventsLength += [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding].length;
            } else if ([value isKindOfClass:[NSData class]]) {
                eventsLength += [(NSData *)value length];
            }
            if (eventsLength >= limitSize) {
                **stop = YES;
            } else {
                [events addObject:event];

                if (events.count >= count) {
                    **stop = YES;
                }
            }
        }
    }];

    return events.count != 0 ? events : nil;
}

- (BOOL)insertEvent:(id<GrowingEventPersistenceProtocol>)event {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db
            executeUpdate:@"INSERT INTO namedcachetable(key,value,createAt,type,sdkVersion,policy) values(?,?,?,?,?,?)",
                          event.eventUUID,
                          event.data,
                          @([GrowingULTimeUtil currentTimeMillis]),
                          event.eventType,
                          event.sdkVersion,
                          @(event.policy)];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)insertEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events {
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
            id<GrowingEventPersistenceProtocol> event = events[i];
            result =
                [db executeUpdate:
                        @"INSERT INTO namedcachetable(key,value,createAt,type,sdkVersion,policy) values(?,?,?,?,?,?)",
                        event.eventUUID,
                        event.data,
                        @([GrowingULTimeUtil currentTimeMillis]),
                        event.eventType,
                        event.sdkVersion,
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
    @throw [NSException
        exceptionWithName:NSInternalInconsistencyException
                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                 userInfo:nil];
}

- (BOOL)initDB:(NSString *)sqlInit createIndex:(NSString *)sqlCreateIndex {
    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }

        if (![db executeUpdate:sqlInit]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }
        if (![db executeUpdate:sqlCreateIndex]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }

        // 兼容3.x早期版本无policy
        NSString *sqlCreatePolicy = @"ALTER TABLE namedcachetable ADD policy INTEGER DEFAULT 6";
        if (![db columnExists:@"policy" inTableWithName:@"namedcachetable"]) {
            if (![db executeUpdate:sqlCreatePolicy]) {
                self.databaseError = [self createDBErrorInDatabase:db];
                return;
            }
        }

        // 4.x新增sdkVersion，用于与3.x区分，过滤不兼容的事件类型
        NSString *sqlCreateSDKVersion = @"ALTER TABLE namedcachetable ADD sdkVersion TEXT DEFAULT '' NOT NULL";
        if (![db columnExists:@"sdkVersion" inTableWithName:@"namedcachetable"]) {
            if (![db executeUpdate:sqlCreateSDKVersion]) {
                self.databaseError = [self createDBErrorInDatabase:db];
                return;
            }
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
    NSString *vacuumDate = [NSString stringWithFormat:@"GIO_VACUUM_DATE_E7B96C4E-6EE2-49CD-87F0-B2E62D4EE96A-%@", name];
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
    (void (^)(NSString *key, id value, NSString *type, NSUInteger policy, NSString *sdkVersion, BOOL **stop))block {
    @throw [NSException
        exceptionWithName:NSInternalInconsistencyException
                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                 userInfo:nil];
}

- (void)enumerateTableUsingBlock:(void (^)(GrowingFMResultSet *set, BOOL *stop))block {
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
            block(set, &stop);
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
