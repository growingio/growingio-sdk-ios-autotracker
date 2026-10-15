//
//  RoutingStorageTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/18.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import <XCTest/XCTest.h>

#import "GrowingEventDatabaseService.h"
#import "Services/JSON/GrowingEventJSONDatabase.h"
#import "Services/Protobuf/GrowingEventProtobufDatabase.h"

#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "Services/Database/FMDB/GrowingFMDB.h"

@interface RoutingStorageTest : XCTestCase
@property (nonatomic, copy) NSString *path;
@end
@implementation RoutingStorageTest
- (void)setUp {
    self.path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSString stringWithFormat:@"routing-%@/events.sqlite", NSUUID.UUID.UUIDString]];
}
- (id<GrowingEventPersistenceProtocol>)eventForSource:(NSString *)source uuid:(NSString *)uuid {
    GrowingBaseEvent *event = GrowingCustomEvent.builder.setEventName(@"routing")
                                  .setDataSourceId(source)
                                  .setSessionId([source stringByAppendingString:@"-session"])
                                  .setSdkVersion(@"4.13.0")
                                  .build;
    return [GrowingEventJSONDatabase persistenceEventWithEvent:event uuid:uuid];
}
- (void)testSourceFilterPrecedesBatchLimit {
    GrowingEventJSONDatabase *db = [GrowingEventJSONDatabase databaseWithPath:self.path error:nil];
    NSMutableArray *events = [NSMutableArray array];
    for (NSUInteger i = 0; i < 6; i++) {
        [events addObject:[self eventForSource:i < 5 ? @"A" : @"B" uuid:NSUUID.UUID.UUIDString]];
    }
    XCTAssertTrue([db insertEvents:events]);
    XCTAssertEqual(db.countOfEvents, 6);
    NSArray *batch = [db getEventsByCount:1 limitSize:100000 policy:~0UL dataSourceId:@"B"];
    XCTAssertEqual(batch.count, 1);
    XCTAssertEqualObjects([batch[0] toJSONObject][@"dataSourceId"], @"B");
    XCTAssertEqual([db getEventsByCount:1 limitSize:100000 policy:~0UL dataSourceId:@"outside"].count, 0);
    XCTAssertEqualObjects([NSSet setWithArray:db.dataSourceIds], ([NSSet setWithArray:@[@"A", @"B"]]));
}
- (void)checkLegacyRowsRecoverTheirOwnSource:(BOOL)isProtobuf {
    [[NSFileManager defaultManager] createDirectoryAtPath:self.path.stringByDeletingLastPathComponent
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSString *legacyPath =
        isProtobuf ? [self.path.stringByDeletingLastPathComponent
                         stringByAppendingPathComponent:[@"enc_" stringByAppendingString:self.path.lastPathComponent]]
                   : self.path;
    GrowingFMDatabaseQueue *legacy = [GrowingFMDatabaseQueue databaseQueueWithPath:legacyPath];
    Class<GrowingEventDatabaseService> databaseClass =
        isProtobuf ? GrowingEventProtobufDatabase.class : GrowingEventJSONDatabase.class;
    GrowingBaseEvent *built = GrowingCustomEvent.builder.setEventName(@"legacy")
                                  .setDataSourceId(@"old-source")
                                  .setSessionId(@"old-session")
                                  .setSdkVersion(@"4.13.0")
                                  .build;
    id<GrowingEventPersistenceProtocol> event = [databaseClass persistenceEventWithEvent:built uuid:@"legacy-event"];
    [legacy inDatabase:^(GrowingFMDatabase *db) {
        XCTAssertTrue([db executeUpdate:@"CREATE TABLE namedcachetable(id INTEGER PRIMARY KEY,key TEXT,value "
                                        @"TEXT,createAt INTEGER NOT NULL,type TEXT,sdkVersion TEXT,policy INTEGER)"]);
        XCTAssertTrue(([db
            executeUpdate:@"INSERT INTO namedcachetable(key,value,createAt,type,sdkVersion,policy) VALUES(?,?,?,?,?,?)",
                          event.eventUUID,
                          event.data,
                          @((long long)(NSDate.date.timeIntervalSince1970 * 1000)),
                          event.eventType,
                          event.sdkVersion,
                          @(event.policy)]));
    }];
    [legacy close];
    id<GrowingEventDatabaseService> db = [databaseClass databaseWithPath:self.path error:nil];
    NSArray *batch = [db getEventsByCount:10 limitSize:100000 policy:~0UL dataSourceId:@"old-source"];
    XCTAssertEqual(batch.count, 1);
    XCTAssertEqualObjects([batch[0] eventUUID], @"legacy-event");
    XCTAssertEqualObjects([batch[0] toJSONObject][@"sessionId"], @"old-session");
    XCTAssertEqual([db getEventsByCount:10 limitSize:100000 policy:~0UL dataSourceId:@"new-source"].count, 0);
}
- (void)testLegacyJSONRowsRecoverTheirOwnSource {
    [self checkLegacyRowsRecoverTheirOwnSource:NO];
}
- (void)testLegacyProtobufRowsRecoverTheirOwnSource {
    [self checkLegacyRowsRecoverTheirOwnSource:YES];
}
@end
