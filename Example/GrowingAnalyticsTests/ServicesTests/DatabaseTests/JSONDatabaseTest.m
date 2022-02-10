//
//  DatabaseTest.m
//  GrowingAnalytics
//
//  Created by sheng on 2021/12/16.
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

#import "InvocationHelper.h"
#import "GrowingEventFMDatabase.h"
#import "GrowingEventJSONPersistence.h"
#import "GrowingVisitEvent.h"
#import "GrowingCustomEvent.h"
#import "GrowingFileStorage.h"

@interface JSONDatabaseTest : XCTestCase

@property (nonatomic, strong) NSString *path;

@end

@implementation JSONDatabaseTest

- (void)setUp {
    self.path = [GrowingFileStorage getTimingDatabasePath];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDatabaseBuildRawEvents {
    NSData *raw = [GrowingEventFMDatabase buildRawEventsFromEvents:@[self.customEventPersistence]];
    XCTAssertNotNil(raw);
}

- (void)testDatabasePersistence {
    GrowingCustomEvent *event = (GrowingCustomEvent *)(GrowingCustomEvent.builder.build);
    id persistence = [GrowingEventFMDatabase persistenceEventWithEvent:event uuid:[NSUUID UUID].UUIDString];
    XCTAssertNotNil(persistence);
}

- (void)testDatabaseInstanceMethods {
    GrowingEventFMDatabase *database = [GrowingEventFMDatabase databaseWithPath:self.path error:nil];
    XCTAssertNotNil(database.db);

    // clean expired event if need
    XCTAssertEqual(database.cleanExpiredEventIfNeeded, YES);

    // clear all events
    XCTAssertEqual(database.clearAllEvents, YES);

    NSInteger count = database.countOfEvents;

    // insert single event
    GrowingEventJSONPersistence *event = self.customEventPersistence;
    XCTAssertEqual([database insertEvent:event], YES);

    NSInteger count2 = database.countOfEvents;
    XCTAssertNotEqual(count, count2);

    // delete single event
    XCTAssertEqual([database deleteEvent:event.eventUUID], YES);

    NSMutableArray *events = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    NSInteger insertCount = 3;
    for (int i = 0; i < insertCount; i++) {
        GrowingEventJSONPersistence *e = self.visitEventPersistence;  // GrowingEventSendPolicyInstant
        [events addObject:e];
        [keys addObject:e.eventUUID];
    }

    // clear all events
    XCTAssertEqual(database.clearAllEvents, YES);

    // insert events
    XCTAssertEqual([database insertEvents:events], YES);

    NSArray *array = [database getEventsByCount:insertCount];
    XCTAssertEqual(array.count, insertCount);

    NSArray *array2 = [database getEventsByCount:insertCount policy:GrowingEventSendPolicyInstant];
    XCTAssertEqual(array2.count, insertCount);

    // delete events
    XCTAssertEqual([database deleteEvents:keys], YES);

    // last error
    NSString *errorPath = @"errorPath";
    NSError *error = nil;
    GrowingEventFMDatabase *errorDatabase = [GrowingEventFMDatabase databaseWithPath:errorPath error:&error];
    if (error) {
        // 这里使用一个错误/无权限路径来实现 Database 初始化异常
        // 使用模拟器运行，实测不会因错误/无权限路径导致初始化异常，error 为 nil，不会进到这一步
        XCTAssertNotNil(errorDatabase.lastError);
    }
}

- (void)testDatabaseEventIO {
    GrowingEventFMDatabase *database = [GrowingEventFMDatabase databaseWithPath:self.path error:nil];
    XCTAssertNotNil(database.db);

    // clear all events
    XCTAssertEqual(database.clearAllEvents, YES);

    GrowingCustomEvent *event =
        (GrowingCustomEvent *)(GrowingCustomEvent.builder.setEventName(@"custom")
                                   .setAttributes(@{@"key": @"value"})
                                   .setPlatform(@"platform")
                                   .setPlatformVersion(@"20")
                                   .setDeviceId([NSUUID UUID].UUIDString)
                                   .setUserId(@"userId")
                                   .setSessionId([NSUUID UUID].UUIDString)
                                   .setTimestamp(1638857558209)
                                   .setDomain(@"com.bundle.id")
                                   .setUrlScheme(@"growing.xxxxxx")
                                   .setAppState(GrowingAppStateForeground)
                                   .setGlobalSequenceId(999)
                                   .setEventSequenceId(999)
                                   .setExtraParams(@{@"dataSourceId": @"123456", @"gioId": @"654321"})
                                   .setNetworkState(@"5G")
                                   .setScreenHeight(1334)
                                   .setScreenWidth(750)
                                   .setDeviceBrand(@"device brand")
                                   .setDeviceModel(@"device model")
                                   .setDeviceType(@"device type")
                                   .setAppVersion(@"3.0.0")
                                   .setAppName(@"Example")
                                   .setLanguage(@"zh-Hans-CN")
                                   .setLatitude(30.11)
                                   .setLongitude(32.22)
                                   .setSdkVersion(@"3.3.3")
                                   .setUserKey(@"iPhone")
                                   .build);
    NSString *uuid = [NSUUID UUID].UUIDString;
    GrowingEventJSONPersistence *persistenceIn = [GrowingEventJSONPersistence persistenceEventWithEvent:event
                                                                                                   uuid:uuid];
    // insert
    XCTAssertEqual([database insertEvent:persistenceIn], YES);

    NSInteger insertCount = 1;
    NSArray *array = [database getEventsByCount:5];  // 避免多线程情况下，刚好还有其他事件产生入库，这里数值设定大一点
    XCTAssertGreaterThanOrEqual(array.count, insertCount);

    GrowingEventJSONPersistence *persistenceOut;
    for (GrowingEventJSONPersistence *p in array) {
        if ([p.eventUUID isEqualToString:uuid]) {
            persistenceOut = p;
            break;
        }
    }
    XCTAssertNotNil(persistenceOut);

    NSDictionary *jsonObject = persistenceOut.toJSONObject;
    XCTAssertEqualObjects(event.platform ?: @"", jsonObject[@"platform"]);
    XCTAssertEqualObjects(event.platformVersion ?: @"", jsonObject[@"platformVersion"]);
    XCTAssertEqualObjects(event.deviceId ?: @"", jsonObject[@"deviceId"]);
    XCTAssertEqualObjects(event.userId ?: @"", jsonObject[@"userId"]);
    XCTAssertEqualObjects(event.sessionId ?: @"", jsonObject[@"sessionId"]);
    XCTAssertEqualObjects(event.eventType ?: @"", jsonObject[@"eventType"]);
    XCTAssertEqual(event.timestamp, ((NSNumber *)(jsonObject[@"timestamp"])).longLongValue);
    XCTAssertEqualObjects(event.domain ?: @"", jsonObject[@"domain"]);
    XCTAssertEqualObjects(event.urlScheme ?: @"", jsonObject[@"urlScheme"]);
    XCTAssertEqualObjects((event.appState == GrowingAppStateForeground ? @"FOREGROUND" : @"BACKGROUND"),
                          jsonObject[@"appState"]);
    XCTAssertEqual(event.globalSequenceId, ((NSNumber *)(jsonObject[@"globalSequenceId"])).longLongValue);
    XCTAssertEqual(event.eventSequenceId, ((NSNumber *)(jsonObject[@"eventSequenceId"])).longLongValue);
    // 3.2.0
    XCTAssertEqualObjects(event.networkState ?: @"", jsonObject[@"networkState"]);
    XCTAssertEqual(event.screenHeight, ((NSNumber *)(jsonObject[@"screenHeight"])).intValue);
    XCTAssertEqual(event.screenWidth, ((NSNumber *)(jsonObject[@"screenWidth"])).intValue);
    XCTAssertEqualObjects(event.deviceBrand ?: @"", jsonObject[@"deviceBrand"]);
    XCTAssertEqualObjects(event.deviceModel ?: @"", jsonObject[@"deviceModel"]);
    XCTAssertEqualObjects(event.deviceType ?: @"", jsonObject[@"deviceType"]);
    XCTAssertEqualObjects(event.appVersion ?: @"", jsonObject[@"appVersion"]);
    XCTAssertEqualObjects(event.appName ?: @"", jsonObject[@"appName"]);
    XCTAssertEqualObjects(event.language ?: @"", jsonObject[@"language"]);
    XCTAssertEqual(event.latitude, ((NSNumber *)(jsonObject[@"latitude"])).doubleValue);
    XCTAssertEqual(event.longitude, ((NSNumber *)(jsonObject[@"longitude"])).doubleValue);
    XCTAssertEqualObjects(event.sdkVersion ?: @"", jsonObject[@"sdkVersion"]);
    // 3.3.0
    XCTAssertEqualObjects(event.userKey ?: @"", jsonObject[@"userKey"]);
    // CUSTOM
    XCTAssertEqualObjects(event.eventName ?: @"", jsonObject[@"eventName"]);
    XCTAssertEqualObjects(event.attributes ?: @{}, jsonObject[@"attributes"]);
}

- (GrowingEventJSONPersistence *)customEventPersistence {
    GrowingCustomEvent *event = (GrowingCustomEvent *)(GrowingCustomEvent.builder.build);
    return [GrowingEventJSONPersistence persistenceEventWithEvent:event uuid:[NSUUID UUID].UUIDString];
}

- (GrowingEventJSONPersistence *)visitEventPersistence {
    GrowingVisitEvent *event = (GrowingVisitEvent *)(GrowingVisitEvent.builder.build);
    return [GrowingEventJSONPersistence persistenceEventWithEvent:event uuid:[NSUUID UUID].UUIDString];
}

@end
