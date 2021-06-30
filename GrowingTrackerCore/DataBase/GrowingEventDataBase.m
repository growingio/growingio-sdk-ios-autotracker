//
//  GrowingEventDatabase.m
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

#import "GrowingEventDatabase.h"
#import "GrowingFMDB.h"
#import <pthread.h>
#import "NSString+GrowingHelper.h"
#import "GrowingLogger.h"
#import "GrowingEventPersistence.h"
#import "GrowingTimeUtil.h"

#define DAY_IN_MILLISECOND (86400000)
#define VACUUM_DATE(name) [NSString stringWithFormat:@"GIO_VACUUM_DATE_E7B96C4E-6EE2-49CD-87F0-B2E62D4EE96A-%@",name]

NSString *const GrowingEventDatabaseErrorDomain = @"com.growing.event.database.error";

@interface GrowingEventDatabase () {
    pthread_mutex_t _updateArrayMutex;
}

@property (nonatomic, strong) GrowingFMDatabaseQueue *db;
@property (nonatomic, strong) NSMutableArray *updateKeys;
@property (nonatomic, strong) NSMutableArray *updateValues;
@property (nonatomic, copy, readonly) NSString *sqliteName;

@end

@implementation GrowingEventDatabase

#pragma mark - Init

+ (instancetype)databaseWithPath:(NSString *)path name:(NSString *)name {
    return [[self alloc] initWithFilePath:path andName:name];
}

- (instancetype)initWithFilePath:(NSString *)filePath andName:(NSString *)name {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self makeDirByFileName:filePath];
        });

        if (filePath.length > 0) {
            NSArray *cArray = [filePath componentsSeparatedByString:@"/"];
            if (cArray.count > 0) {
                _sqliteName = cArray.lastObject;
            }
        }

        _name = name;
        _updateValues = [[NSMutableArray alloc] init];
        _updateKeys = [[NSMutableArray alloc] init];
        pthread_mutex_init(&_updateArrayMutex, NULL);
        _db = [GrowingFMDatabaseQueue databaseQueueWithPath:filePath];

        [self initDB];
    }

    return self;
}

#pragma mark - Public Methods

- (NSUInteger)countOfEvents {
    [self flush];

    __block NSInteger count = 0;
    __block NSError *readError = nil;

    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            readError = error;
            return;
        }
        GrowingFMResultSet *set = [db executeQuery:@"select count(*) from namedcachetable where name=?"
                                            values:@[self.name]
                                             error:nil];
        if (!set) {
            readError = [self readErrorInDatabase:db];
            return;
        }

        if ([set next]) {
            count = (NSUInteger)[set longLongIntForColumnIndex:0];
        }

        [set close];
    }];

    if (readError) {
        [self handleDatabaseError:readError];
    }

    return count;
}

- (BOOL)flush {
    NSMutableArray *removeArr = [[NSMutableArray alloc] init];
    NSMutableArray *updateKeyArr = [[NSMutableArray alloc] init];
    NSMutableArray *updateValueArr = [[NSMutableArray alloc] init];

    [self performModifyArrayBlock:^{
        if (!self.updateKeys.count) {
            return;
        }
        
        // 如果一个key被更改多次 则以最后一次为准 从后向前遍历一个key只用一次 该table用来记录使用过的key
        NSHashTable *checkTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPersonality
                                   | NSPointerFunctionsStrongMemory
                                                              capacity:self.updateValues.count];
        NSString *key = nil;
        NSString *value = nil;

        // 从后往前遍历
        for (NSInteger i = self.updateValues.count - 1; i >= 0; i--) {
            key = self.updateKeys[i];
            value = self.updateValues[i];
            // 如果已经使用过 则继续 否则添加到使用过的key里
            if ([checkTable containsObject:key]) {
                continue;
            } else {
                [checkTable addObject:key];
            }

            if (value != nil && ![value isKindOfClass:[NSNull class]]) {
                // 保持顺序
                [updateKeyArr insertObject:key atIndex:0];
                [updateValueArr insertObject:value atIndex:0];
            }else {
                [removeArr addObject:key];
            }
        }

        [self.updateValues removeAllObjects];
        [self.updateKeys removeAllObjects];
    }];

    // 缓存中无数据，无需flush
    if (removeArr.count == 0 && updateKeyArr.count == 0 && updateValueArr.count == 0) {
        return YES;
    }

    __block NSError *writeError = nil;
    [self performTransactionBlock:^(GrowingFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            writeError = error;
            return;
        }
        BOOL result = [self flush_deleteDatabaseV2:db byKeys:removeArr];
        if (!result) {
            writeError = [self writeErrorInDatabase:db];
            return;
        }
        result = [self flush_insertDatabaseV2:db byKeys:updateKeyArr values:updateValueArr];
        if (!result) {
            writeError = [self writeErrorInDatabase:db];
            return;
        }
    }];

    if (writeError) {
        [self handleDatabaseError:writeError];
        return NO;
    }

    return YES;
}

- (BOOL)vacuum {
    if (!isExecuteVacuum(self.sqliteName)) {
        return YES;
    }

    __block NSError *vacuumError = nil;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            vacuumError = error;
            return;
        }
        BOOL result = [db executeUpdate:@"VACUUM namedcachetable"];
        if (!result) {
            vacuumError = [self writeErrorInDatabase:db];
            return;
        }
    }];

    if (vacuumError) {
        [self handleDatabaseError:vacuumError];
        return NO;
    }

    return YES;
}

- (BOOL)clearAllItems {
    if (![self flush]) {
        return NO;
    }

    __block NSError *clearError = nil;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            clearError = error;
            return;
        }
        BOOL result = [db executeUpdate:@"delete from namedcachetable where name=?" values:@[self.name] error:nil];
        if (!result) {
            clearError = [self writeErrorInDatabase:db];
            return;
        }
    }];

    if (clearError) {
        [self handleDatabaseError:clearError];
        return NO;
    }

    return YES;
}

- (BOOL)cleanExpiredDataIfNeeded {
    NSDate *dateNow = [NSDate date];
    NSNumber *now = [NSNumber numberWithLongLong:([dateNow timeIntervalSince1970] * 1000LL)];
    NSNumber *sevenDayBefore = [NSNumber numberWithLongLong:(now.longValue - DAY_IN_MILLISECOND * 7)];
    
    __block NSError *deleteError = nil;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            deleteError = error;
            return;
        }
        BOOL result = [db executeUpdate:@"delete from namedcachetable where name=? and createAt<=?;", self.name, sevenDayBefore];
        if (!result) {
            deleteError = [self writeErrorInDatabase:db];
            return;
        }
    }];

    if (deleteError) {
        [self handleDatabaseError:deleteError];
        return NO;
    }

    return YES;
}

- (void)setEvent:(GrowingEventPersistence *)event forKey:(NSString *)key {
    if (!key.length) {
        return;
    }

    __block NSUInteger count = 0;
    [self performModifyArrayBlock:^{
        [self.updateKeys addObject:key];
        [self.updateValues addObject:event ? event : [NSNull null]];
        count = self.updateValues.count;
    }];

    if (count >= self.autoFlushCount) {
        [self flush];
    }
}

- (void)enumerateKeysAndValuesUsingBlock:(void (^)(NSString *key, NSString *value, NSString *type, BOOL *stop))block {
    if (!block) {
        return;
    }

    [self flush];

    __block NSError *readError = nil;
    [self performDatabaseBlock:^(GrowingFMDatabase *db, NSError *error) {
        if (error) {
            readError = error;
            return;
        }
        GrowingFMResultSet *set = [db executeQuery:@"select * from namedcachetable where name=? order by id asc"
                                            values:@[self.name]
                                             error:nil];
        if (!set) {
            readError = [self readErrorInDatabase:db];
            return;
        }

        BOOL stop = NO;
        while (!stop && [set next]) {
            NSString *key = [set stringForColumn:@"key"];
            NSString *value = [set stringForColumn:@"value"];
            NSString *type = [set stringForColumn:@"type"];
            block(key, value, type, &stop);
        }

        [set close];
    }];

    if (readError) {
        [self handleDatabaseError:readError];
    }
}

- (NSArray<GrowingEventPersistence *> *)getEventsWithPackageNum:(NSUInteger)packageNum {
    if (self.countOfEvents == 0) {
        return nil;
    }
    
    NSMutableArray <GrowingEventPersistence *> *eventQueue = [[NSMutableArray alloc] init];
    
    [self enumerateKeysAndValuesUsingBlock:^(NSString *key, NSString *value, NSString *type, BOOL *stop) {
        
        GrowingEventPersistence *event = [[GrowingEventPersistence alloc] initWithUUID:key eventType:type jsonString:value];
        
        [eventQueue addObject:event];
        if (eventQueue.count >= packageNum) {
            *stop = YES;
        }
    }];

    return eventQueue;
}

#pragma mark - Private Methods

- (void)initDB {
    __block NSError *createError = nil;
    [self performTransactionBlock:^(GrowingFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            createError = error;
            return;
        }
        
        NSString *sql = @"create table if not exists namedcachetable("
        @"id INTEGER PRIMARY KEY,"
        @"name text,"
        @"key text,"
        @"value text,"
        @"createAt INTEGER NOT NULL,"
        @"type text);";
        NSString *sqlCreateIndexNameKey = @"create index if not exists namedcachetable_name_key on namedcachetable (name, key);";
        NSString *sqlCreateIndexNameId = @"create index if not exists namedcachetable_name_id on namedcachetable (name, id);";
        
        if (![db executeUpdate:sql]) {
            createError = [self createDBErrorInDatabase:db];
            return;
        }
        if (![db executeUpdate:sqlCreateIndexNameKey]) {
            createError = [self createDBErrorInDatabase:db];
            return;
        }
        if (![db executeUpdate:sqlCreateIndexNameId]) {
            createError = [self createDBErrorInDatabase:db];
            return;
        }
    }];

    if (createError) {
        [self handleDatabaseError:createError];
    }
}

static BOOL isExecuteVacuum(NSString *name) {
    if (name.length == 0) {
        return NO;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDate *beforeDate = [userDefault objectForKey:VACUUM_DATE(name)];
    NSDate *nowDate = [NSDate date];

    if (beforeDate) {
        NSDateComponents *delta = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                  fromDate:beforeDate
                                                                    toDate:nowDate
                                                                   options:0];
        BOOL flag = delta.day > 7 || delta.day < 0;
        if (flag) {
            [userDefault setObject:nowDate forKey:VACUUM_DATE(name)];
            [userDefault synchronize];
        }
        return flag;
    } else {
        [userDefault setObject:nowDate forKey:VACUUM_DATE(name)];
        [userDefault synchronize];
        return YES;
    }
}

- (void)makeDirByFileName:(NSString*)filePath {
    [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

#pragma mark - Perform Block

- (void)performDatabaseBlock:(void(^)(GrowingFMDatabase *db, NSError *error))block {
    [self.db inDatabase:^(GrowingFMDatabase *db) {
        if (!db) {
            block(db, [self openErrorInDatabase:db]);
        } else {
            block(db, nil);
        }
    }];
}

- (void)performTransactionBlock:(void(^)(GrowingFMDatabase *db, BOOL *rollback, NSError *error))block {
    [self.db inTransaction:^(GrowingFMDatabase *db, BOOL *rollback) {
        if (!db) {
            block(db, rollback, [self openErrorInDatabase:db]);
        } else {
            block(db, rollback, nil);
        }
    }];
}

- (void)performModifyArrayBlock:(void (^)(void))block {
    pthread_mutex_lock(&_updateArrayMutex);
    block();
    pthread_mutex_unlock(&_updateArrayMutex);
}

#pragma mark - Flush

// 采用循环的方式进行数据库插入操作
- (BOOL)flush_insertDatabaseV2:(GrowingFMDatabase *)db byKeys:(NSArray *)keys values:(NSArray *)values {
    if (!keys || keys.count == 0 || !values || values.count == 0 || keys.count != values.count) {
        return YES;
    }

    for (NSInteger i = 0; i < keys.count; i++) {
        id value = values[i];
        if ([value isKindOfClass:GrowingEventPersistence.class]) {
            GrowingEventPersistence *event = (GrowingEventPersistence *)value;
            NSString *type = event.eventType;
            NSString *eventString = event.rawJsonString;
            BOOL result = [db executeUpdate:@"insert into namedcachetable(name,key,value,createAt,type) values(?,?,?,?,?)",
                           self.name,
                           keys[i],
                           eventString,
                           @([GrowingTimeUtil currentTimeMillis]),
                           type];
            if (!result) {
                return NO;
            }
        }
    }
    return YES;
}

// 采用循环的方式进行数据库删除操作
- (BOOL)flush_deleteDatabaseV2:(GrowingFMDatabase *)db byKeys:(NSArray *)keys {
    if (!keys || keys.count == 0) {
        return YES;
    }

    for (NSString *key in keys) {
        BOOL result = [db executeUpdate:@"delete from namedcachetable where name=? and key=?;", self.name, key];
        if (!result) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Error

- (void)handleDatabaseError:(NSError *)error {
    if (!error) {
        return;
    }
    GIOLogError(@"DB Error: %@, code: %ld, detail: %@", error.domain, (long)error.code, error.localizedDescription);
}

- (NSError *)openErrorInDatabase:(GrowingFMDatabase *)db {
    return [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                               code:GrowingEventDatabaseOpenError
                           userInfo:@{NSLocalizedDescriptionKey : @"open database error"}];
}

- (NSError *)readErrorInDatabase:(GrowingFMDatabase *)db {
    return [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                               code:GrowingEventDatabaseReadError
                           userInfo:@{NSLocalizedDescriptionKey : ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)writeErrorInDatabase:(GrowingFMDatabase *)db {
    return [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                               code:GrowingEventDatabaseWriteError
                           userInfo:@{NSLocalizedDescriptionKey : ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)createDBErrorInDatabase:(GrowingFMDatabase *)db {
    return [NSError errorWithDomain:GrowingEventDatabaseErrorDomain
                               code:GrowingEventDatabaseCreateDBError
                           userInfo:@{NSLocalizedDescriptionKey : ([db lastErrorMessage] ?: @"")}];
}

@end
