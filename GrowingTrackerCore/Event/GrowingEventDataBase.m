//
//  GrowingEventDataBase.m
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


#import "GrowingEventDataBase.h"
#import "GrowingFMDB.h"
#import <pthread.h>
#import "NSString+GrowingHelper.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingEventPersistence.h"
#import "GrowingTimeUtil.h"

#define DAY_IN_MILLISECOND (86400000)
#define VACUUM_DATE(name) [NSString stringWithFormat:@"GIO_VACUUM_DATE_E7B96C4E-6EE2-49CD-87F0-B2E62D4EE96A-%@",name]

@interface _GrowingDataBaseWithMutex : GrowingFMDatabase
{
    pthread_mutex_t _databaseMutex;
}

@property (nonatomic, readonly) pthread_mutex_t *dbMutex;

@end

@implementation _GrowingDataBaseWithMutex

- (instancetype)initWithPath:(NSString *)inPath
{
    self = [super initWithPath:inPath];
    if (self)
    {
        pthread_mutex_init(&_databaseMutex,NULL);
    }
    return self;
}

- (pthread_mutex_t*)dbMutex
{
    return &_databaseMutex;
}

@end


@interface GrowingEventDataBase()
{
    BOOL _stopAutoUpdate;
    pthread_mutex_t updateArrayMutext;

}

@property (nonatomic, retain) _GrowingDataBaseWithMutex *db;

@property (nonatomic, retain) NSMutableArray *updateKeys;
@property (nonatomic, retain) NSMutableArray *updateValues;

@property (nonatomic, copy, readonly) NSString *sqliteName;

@end

@implementation GrowingEventDataBase

+ (instancetype)databaseWithPath:(NSString *)path name:(NSString *)name
{
    return [[self alloc] initWithFilePath:path andName:name];
}


- (void)makeDirByFileName:(NSString*)filePath
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

static  NSMapTable *dbMap = nil;

- (instancetype)initWithFilePath:(NSString*)filePath andName:(NSString*)name
{
    self = [super init];
    if (self)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self makeDirByFileName:filePath];
        });
        
        pthread_mutex_init(&updateArrayMutext,NULL);
        _name = name;
        
        if (filePath.length > 0) {
            NSArray *cArray = [filePath componentsSeparatedByString:@"/"];
            if (cArray.count > 0) {
                _sqliteName = cArray.lastObject;
            }
        }
        
        
        self.updateValues = [[NSMutableArray alloc] init];
        self.updateKeys = [[NSMutableArray alloc] init];
        
        if (!dbMap)
        {
            dbMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                                            | NSPointerFunctionsObjectPersonality
                                              valueOptions:NSPointerFunctionsWeakMemory
                                                  capacity:2];
        }
        _GrowingDataBaseWithMutex *db = [dbMap objectForKey:filePath];
        if (!db)
        {
            db = [[_GrowingDataBaseWithMutex alloc] initWithPath:filePath];
            [dbMap setObject:db forKey:filePath];
        }
        
        self.db = db;
        [self initDB];
    }
    return self;
}

static BOOL isExecuteVacuum(NSString *name)
{
    if (name.length == 0) {
        return NO;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDate *beforeDate = [userDefault objectForKey:VACUUM_DATE(name)];

    NSDate *nowDate = [NSDate date];

    if (beforeDate) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit unit = NSCalendarUnitDay;
        NSDateComponents *delta = [calendar components:unit fromDate:beforeDate toDate:nowDate options:0];
        BOOL flag;
        if (delta.day > 30) {
            flag = YES;
        } else if (delta.day < 0) {
            flag = YES;
        } else {
            flag = NO;
        }
        
        if (flag) {
            [userDefault setObject:nowDate forKey:VACUUM_DATE(name)];
        }
        return flag;
    } else {
        [userDefault setObject:nowDate forKey:VACUUM_DATE(name)];
        return YES;
    }
}

- (void)initDB
{
    [self performDataBaseBlock:^(GrowingFMDatabase *db) {
        NSString* sql = @"create table if not exists namedcachetable("
        @"id INTEGER PRIMARY KEY,"
        @"name text,"
        @"key text,"
        @"value text,"
        @"createAt INTEGER NOT NULL,"
        @"type text);";
        NSString * sqlCreateIndexNameKey = @"create index if not exists namedcachetable_name_key on namedcachetable (name, key);";
        NSString * sqlCreateIndexNameId = @"create index if not exists namedcachetable_name_id on namedcachetable (name, id);";
        NSError *error = nil;
        [db beginTransaction];
        [db executeUpdate:sql values:nil error:&error];
        [db executeUpdate:sqlCreateIndexNameKey values:nil error:&error];
        [db executeUpdate:sqlCreateIndexNameId values:nil error:&error];
        [db commit];
    }];
}

- (void)setEvent:(GrowingEventPersistence *)event forKey:(NSString *)key {
    [self setEvent:event forKey:key error:nil];
}

- (void)setEvent:(GrowingEventPersistence *)event forKey:(NSString *)key error:(NSError *__autoreleasing *)outError {
    
    if (!key.length) {
        return;
    }
    
    __block NSUInteger count = 0;
    [self performModifyArrayBlock:^{
        [self.updateKeys addObject:key];
        [self.updateValues addObject:event ? event : [NSNull null]];
        count = self.updateValues.count;
    }];
    if (count >= self.autoFlushCount)
    {
        NSError *error = [self flush];
        if (error && outError)
        {
            *outError = error;
        }
    }
}


- (NSUInteger)countOfEvents
{
    [self flush];
    __block NSInteger count = 0;
    [self performDataBaseBlock:^(GrowingFMDatabase *db) {
        GrowingFMResultSet *set =
        [db executeQuery:@"select count(*) from namedcachetable where name=?"
                  values:@[self.name]
                   error:nil];
        if ([set next])
        {
            count = (NSUInteger)[set longLongIntForColumnIndex:0];
        }
        [set close];
    }];
    return count;
}

- (NSError*)enumerateKeysAndValuesUsingBlock:(void (^)(NSString *, NSString *, NSString *, BOOL *))block
{
    if (!block)
    {
        return nil;
    }
    [self flush];
    
    __block NSError *readError = nil;
    NSError *openErr =
    [self performDataBaseBlock:^(GrowingFMDatabase *db) {
        NSError *dbErr = nil;
        GrowingFMResultSet *set =
        [db executeQuery:@"select * from namedcachetable where name=? order by id asc"
                  values:@[self.name]
                   error:&dbErr];
        if (dbErr && readError)
        {
            readError = dbErr;
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
        
    return openErr ? openErr : readError;
}

- (NSError*)clearAllItems
{
    NSError *err1 = [self flush];
    NSError *err2 =
    [self performDataBaseBlock:^(GrowingFMDatabase *db) {
        [db executeUpdate:@"delete from namedcachetable where name=?"
                        values:@[self.name]
                         error:nil];
    }];
    return err1 ? err1 : err2;
}

- (NSArray<GrowingEventPersistence *> *)getEventsWithPackageNum:(NSUInteger)packageNum {
    if (self.countOfEvents == 0) {
        return nil;
    }
    
    NSMutableArray <GrowingEventPersistence *> *eventQueue = [[NSMutableArray alloc] init];
    
    NSError *error =
    [self enumerateKeysAndValuesUsingBlock:^(NSString *key, NSString *value, NSString *type, BOOL *stop) {
        
        GrowingEventPersistence *event = [[GrowingEventPersistence alloc] initWithUUID:key eventType:type jsonString:value];
        
        [eventQueue addObject:event];
        if (eventQueue.count >= packageNum) {
            *stop = YES;
        }
    }];
    
    [self handleDatabaseError:error];
    
    return eventQueue;
}

- (void)handleDatabaseError:(NSError *)error {
    if (!error) { return; }
    GIOLogError(@"error = %@", error);
}

#pragma mark - perform
- (NSError*)performDataBaseBlock:(void(^)(GrowingFMDatabase *db))block
{
    NSError *err = nil;
    pthread_mutex_lock(self.db.dbMutex);
    
    if ([self.db open])
    {
        block(self.db);
        [self.db close];
    }
    else
    {
        err = [NSError errorWithDomain:@"open db error" code:GrowingEventDataBaseOpenError userInfo:nil];
    }
    pthread_mutex_unlock(self.db.dbMutex);
    return err;
}

- (void)performModifyArrayBlock:(void(^)(void))block
{
    pthread_mutex_lock(&updateArrayMutext);
    block();
    pthread_mutex_unlock(&updateArrayMutext);
}

#pragma mark - flush

// 采用循环的方式进行数据库插入操作
- (NSError *)flush_insertDataBaseV2:(GrowingFMDatabase *)db byKeys:(NSArray *)keys values:(NSArray *)values {
    if (!keys || keys.count == 0) {
        return nil;
    }
    
    if (!values || values.count == 0) {
        return nil;
    }
    
    if (keys.count != values.count) {
        return nil;
    }
    
    NSError *error = nil;
    for (NSInteger i = 0 ; i < keys.count ; i++) {
        id value = values[i];
        if ([value isKindOfClass:GrowingEventPersistence.class]) {
            GrowingEventPersistence *event = (GrowingEventPersistence *)value;
            NSString *type = event.eventType;
            NSString *eventString = event.rawJsonString;
            //传入的值不能是int,long这种常量类型，需要转为NSNumber or NSString
            BOOL result = [db executeUpdate:@"insert into namedcachetable(name,key,value,createAt,type) values(?,?,?,?,?)", self.name, keys[i], eventString, @([GrowingTimeUtil currentTimeMillis]), type];
            if (!result) {
                error = [db lastError];
                break;
            }
        }
    }
    return error;
}

// 采用循环的方式进行数据库删除操作
- (NSError *)flush_deleteDataBaseV2:(GrowingFMDatabase *)db byKeys:(NSArray *)keys {
    if (!keys || keys.count == 0) {
        return nil;
    }
    
    NSError *error = nil;
    for (NSString *key in keys) {
        BOOL result = [db executeUpdate:@"delete from namedcachetable where name=? and key=?;", self.name, key];
        if (!result) {
            error = [db lastError];
            break;
        }
    }
    return error;
}

- (NSError*)flush
{
    NSMutableArray *removeArr = [[NSMutableArray alloc] init];
    NSMutableArray *updateKeyArr = [[NSMutableArray alloc] init];
    NSMutableArray *updateValueArr = [[NSMutableArray alloc] init];
    
    [self performModifyArrayBlock:^{
        if (!self.updateKeys.count)
        {
            return ;
        }
        
        // 如果一个key被更改多次 则以最后一次为准 从后向前遍历一个key只用一次 该table用来记录使用过的key
        NSHashTable *checkTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPersonality
                                   | NSPointerFunctionsStrongMemory
                                                              capacity:self.updateValues.count];
        NSString *key = nil;
        NSString *value = nil;
        
        // 从后往前遍历
        for (NSInteger i = self.updateValues.count - 1 ; i >= 0 ; i--)
        {
            key = self.updateKeys[i];
            value = self.updateValues[i];
            // 如果已经使用过 则继续 否则添加到使用过的key里
            if ([checkTable containsObject:key])
            {
                continue;
            }
            else
            {
                [checkTable addObject:key];
            }
            
            // 每个key都需要先remove 后insert
            [removeArr addObject:key];
            
            if (value != nil && ![value isKindOfClass:[NSNull class]])
            {
                // 保持顺序
                [updateKeyArr insertObject:key atIndex:0];
                [updateValueArr insertObject:value atIndex:0];
            }
            
        }
        
        [self.updateValues removeAllObjects];
        [self.updateKeys removeAllObjects];
    }];
    
    __block NSError *writeError = nil;
    NSError *openError =
    [self performDataBaseBlock:^(GrowingFMDatabase *db) {
        // 采用事务的方式批量操作, 减少单词操作生成超长的字符串
        [db beginTransaction];
        NSError *err1 = [self flush_deleteDataBaseV2:db byKeys:removeArr];
        NSError *err2 = [self flush_insertDataBaseV2:db byKeys:updateKeyArr values:updateValueArr];
        [db commit];
        
        if (err1 || err2) {
            writeError = [NSError errorWithDomain:@"db write error" code:GrowingEventDataBaseWriteError userInfo:nil];
        }
    }];
    
    return openError ? openError : writeError;
}

- (NSError*)vacuum
{
    if (!isExecuteVacuum(self.sqliteName)) {
        return nil;
    }
    
    NSError *vacuumError =
    [self performDataBaseBlock:^(GrowingFMDatabase *db) {
        [db executeUpdate:@"VACUUM namedcachetable"];
    }];
    return vacuumError;
}

- (NSError *)cleanExpiredDataIfNeeded {
    
//    NSNumber *now = GROWGetTimestamp();
    NSNumber *now =0;
    NSNumber *sevenDayBefore = [NSNumber numberWithLong:(now.longValue - DAY_IN_MILLISECOND * 7)]; // (now.longValue - now.longValue);
    
    __block NSError *deleteError = nil;
    
    NSError *openError = [self performDataBaseBlock:^(GrowingFMDatabase *db) {
        BOOL result = [db executeUpdate:@"delete from namedcachetable where name=? and createAt<=?;", self.name, sevenDayBefore];
        if (!result) {
            deleteError = [db lastError];
        }
    }];
    
    return openError ? openError : deleteError;
}

@end
