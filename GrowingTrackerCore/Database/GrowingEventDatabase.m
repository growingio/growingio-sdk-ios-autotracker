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
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

NSString *const GrowingEventDatabaseErrorDomain = @"com.growing.event.database.error";

@interface GrowingEventDatabase ()

@property (nonatomic, strong) id<GrowingEventDatabaseService> db;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) Class databaseClass;
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

        _filePath = [filePath copy];
        _databaseClass = serviceClass;
        NSError *error = nil;
        _db = [(Class)serviceClass databaseWithPath:filePath error:&error];
        if (error || !_db) {
            [self handleDatabaseError:error];
            return nil;
        }
        [self cleanExpiredDataIfNeeded];
    }

    return self;
}

- (id<GrowingEventDatabaseService>)db {
    @synchronized(self) {
        if (!_db && self.databaseClass) {
            NSError *error = nil;
            _db = [self.databaseClass databaseWithPath:self.filePath error:&error];
            if (error) {
                [self handleDatabaseError:error];
                _db = nil;
            }
        }
        return _db;
    }
}

- (void)releaseIdleDatabase {
    @synchronized(self) {
        __block BOOL pending;
        [self performModifyArrayBlock:^{
            pending = self.updateKeys.count > 0;
        }];
        if (!pending) _db = nil;
    }
}

#pragma mark - Public Methods

- (NSUInteger)countOfEvents {
    if (![self flush]) {
        return 0;
    }

    NSInteger count = [self.db countOfEvents];
    if (count < 0) {
        [self handleDatabaseError:[self.db lastError]];
        return 0;
    }
    return (NSUInteger)count;
}

- (BOOL)flush {
    // Serialize flushes, while allowing producers to append under the short array lock.
    @synchronized(self) {
        __block NSArray *keys;
        __block NSArray *values;
        [self performModifyArrayBlock:^{
            keys = self.updateKeys.copy;
            values = self.updateValues.copy;
        }];
        if (!keys.count) {
            return YES;
        }
        NSMutableSet *seen = [NSMutableSet set];
        NSMutableArray *inserts = [NSMutableArray array];
        NSMutableArray *removes = [NSMutableArray array];
        for (NSInteger i = keys.count - 1; i >= 0; i--) {
            if ([seen containsObject:keys[i]]) {
                continue;
            }
            [seen addObject:keys[i]];
            if (values[i] == NSNull.null) {
                [removes addObject:keys[i]];
            } else {
                [inserts insertObject:values[i] atIndex:0];
            }
        }
        if (![self.db deleteEvents:removes] || ![self.db insertEvents:inserts]) {
            [self handleDatabaseError:self.db.lastError];
            return NO;
        }
        [self performModifyArrayBlock:^{
            // Appends made during IO remain queued, including newer deletes for the same UUID.
            [self.updateKeys removeObjectsInRange:NSMakeRange(0, keys.count)];
            [self.updateValues removeObjectsInRange:NSMakeRange(0, values.count)];
        }];
        return YES;
    }
}

- (BOOL)supportsDataSourceRouting {
    return [self.db respondsToSelector:@selector(dataSourceIds)] &&
           [self.db respondsToSelector:@selector(getEventsByCount:limitSize:policy:dataSourceId:)];
}

- (NSDictionary<NSString *, NSNumber *> *)eventCountsByDataSourceId {
    if ([self.db respondsToSelector:@selector(eventCountsByDataSourceId)]) return [self.db eventCountsByDataSourceId];
    return @{};
}

- (NSArray<NSString *> *)dataSourceIds {
    return self.supportsDataSourceRouting ? [self.db dataSourceIds] : @[];
}

- (NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsByCount:(NSUInteger)count
                                                         limitSize:(NSUInteger)limitSize
                                                            policy:(NSUInteger)mask
                                                      dataSourceId:(NSString *)dataSourceId {
    if (![self flush]) {
        return @[];
    }
    if (self.supportsDataSourceRouting) {
        return [self.db getEventsByCount:count limitSize:limitSize policy:mask dataSourceId:dataSourceId] ?: @[];
    }
    // Legacy services remain usable for single-source collection, without ever misrouting a batch.
    NSMutableArray *events = [NSMutableArray array];
    for (id<GrowingEventPersistenceProtocol> event in [self getEventsByCount:count limitSize:limitSize policy:mask]) {
        if ([[event toJSONObject][@"dataSourceId"] isEqual:dataSourceId]) {
            [events addObject:event];
        }
    }
    return events;
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
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    BOOL result = [self.db cleanExpiredEventIfNeeded:trackConfiguration.dataValidityPeriod];

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

- (NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsByCount:(NSUInteger)count
                                                         limitSize:(NSUInteger)limitSize
                                                            policy:(NSUInteger)mask {
    NSArray *events = [self.db getEventsByCount:count limitSize:limitSize policy:mask];
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
