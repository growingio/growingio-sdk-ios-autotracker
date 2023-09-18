//
//  GrowingEventDatabase.m
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

#import "GrowingTrackerCore/Database/GrowingEventDatabase.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

long long const GrowingEventDatabaseExpirationTime = 86400000 * 7;
NSString *const GrowingEventDatabaseErrorDomain = @"com.growing.event.database.error";

@interface GrowingEventDatabase ()

@property (nonatomic, strong) id<GrowingEventDatabaseService> db;
@property (nonatomic, strong) NSMutableArray *updateKeys;
@property (nonatomic, strong) NSMutableArray *updateValues;

@end

@implementation GrowingEventDatabase {
    GROWING_LOCK_DECLARE(lock);
}

#pragma mark - Init

+ (instancetype)databaseWithPath:(NSString *)path isProtobuf:(BOOL)isProtobuf {
    return [[self alloc] initWithFilePath:path isProtobuf:isProtobuf];
}

- (instancetype)initWithFilePath:(NSString *)filePath isProtobuf:(BOOL)isProtobuf {
    if (self = [super init]) {
        _updateValues = [[NSMutableArray alloc] init];
        _updateKeys = [[NSMutableArray alloc] init];
        GROWING_LOCK_INIT(lock);

        Class<GrowingEventDatabaseService> serviceClass = nil;
        if (isProtobuf) {
            serviceClass =
                [[GrowingServiceManager sharedInstance] serviceImplClass:@protocol(GrowingPBEventDatabaseService)];
        } else {
            serviceClass =
                [[GrowingServiceManager sharedInstance] serviceImplClass:@protocol(GrowingEventDatabaseService)];
        }
        if (!serviceClass) {
            GIOLogError(@"-databaseWithPath: event database error : no event database service support");
            return nil;
        }

        NSError *error;
        _db = [(Class)serviceClass databaseWithPath:filePath error:&error];
        if (error) {
            [self handleDatabaseError:error];
        }
        [self cleanExpiredDataIfNeeded];
    }

    return self;
}

#pragma mark - Public Methods

- (NSUInteger)countOfEvents {
    [self flush];

    NSInteger count = [self.db countOfEvents];
    if (count < 0) {
        [self handleDatabaseError:[self.db lastError]];
        return 0;
    }
    return (NSUInteger)count;
}

- (BOOL)flush {
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    NSMutableArray *insertArray = [[NSMutableArray alloc] init];

    [self performModifyArrayBlock:^{
        if (!self.updateKeys.count) {
            return;
        }

        // 如果一个key被更改多次 则以最后一次为准 从后向前遍历一个key只用一次 该table用来记录使用过的key
        NSHashTable *checkTable =
            [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsStrongMemory
                                        capacity:self.updateKeys.count];
        NSString *key = nil;
        id value = nil;

        // 从后往前遍历
        for (NSInteger i = self.updateKeys.count - 1; i >= 0; i--) {
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
                [insertArray insertObject:value atIndex:0];
            } else {
                [removeArray addObject:key];
            }
        }

        [self.updateValues removeAllObjects];
        [self.updateKeys removeAllObjects];
    }];

    // 缓存中无数据，无需flush
    if (removeArray.count == 0 && insertArray.count == 0) {
        return YES;
    }

    // 数据库操作
    BOOL result = [self.db deleteEvents:removeArray];
    if (!result) {
        [self handleDatabaseError:[self.db lastError]];
        return NO;
    }
    result = [self.db insertEvents:insertArray];
    if (!result) {
        [self handleDatabaseError:[self.db lastError]];
        return NO;
    }

    return YES;
}

- (BOOL)clearAllItems {
    if (![self flush]) {
        return NO;
    }

    BOOL result = [self.db clearAllEvents];
    if (!result) {
        [self handleDatabaseError:[self.db lastError]];
    }
    return result;
}

- (BOOL)cleanExpiredDataIfNeeded {
    BOOL result = [self.db cleanExpiredEventIfNeeded];

    if (!result) {
        [self handleDatabaseError:[self.db lastError]];
    }
    return result;
}

- (void)setEvent:(id<GrowingEventPersistenceProtocol>)event forKey:(NSString *)key {
    if (!key.length) {
        return;
    }

    __block NSUInteger count = 0;
    [self performModifyArrayBlock:^{
        [self.updateKeys addObject:key];
        [self.updateValues addObject:event ? event : (id)[NSNull null]];
        count = self.updateValues.count;
    }];

    if (count >= self.autoFlushCount) {
        [self flush];
    }
}

- (NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsByCount:(NSUInteger)count policy:(NSUInteger)mask {
    NSArray *events = [self.db getEventsByCount:count policy:mask];
    if (!events) {
        [self handleDatabaseError:[self.db lastError]];
    }
    return events ?: [[NSArray alloc] init];
}

- (NSData *)buildRawEventsFromEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events {
    return [self.db.class buildRawEventsFromEvents:events];
}

- (id<GrowingEventPersistenceProtocol>)persistenceEventWithEvent:(GrowingBaseEvent *)event uuid:(NSString *)uuid {
    return [self.db.class persistenceEventWithEvent:event uuid:uuid];
}

#pragma mark - Perform Block

- (void)performModifyArrayBlock:(void (^)(void))block {
    GROWING_LOCK(lock);
    block();
    GROWING_UNLOCK(lock);
}

#pragma mark - Error

- (void)handleDatabaseError:(NSError *)error {
    if (!error) {
        return;
    }
    GIOLogError(@"DB Error: %@, code: %ld, detail: %@", error.domain, (long)error.code, error.localizedDescription);
}

@end
