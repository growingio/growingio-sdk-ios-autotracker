//
//  GrowingEventDatabaseTest.m
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

#import "InvocationHelper.h"
#import "GrowingServiceManager.h"
#import "GrowingEventDatabaseService.h"
#import "GrowingEventFMDatabase.h"
#import "GrowingEventDatabase.h"
#import "GrowingEventJSONPersistence.h"
#import "GrowingVisitEvent.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingFileStorage.h"

@interface DatabaseTest : XCTestCase

@property (nonatomic, strong) GrowingEventDatabase *database;
@property (nonatomic, strong) GrowingVisitEvent *event;

@end

@implementation DatabaseTest

+ (void)setUp {
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventDatabaseService)
                                                implClass:GrowingEventFMDatabase.class];
}

- (void)setUp {
    GrowingEventDatabase *database = [GrowingEventDatabase databaseWithPath:[GrowingFileStorage getTimingDatabasePath]];
    XCTAssertNotNil(database);
    self.database = database;

    self.event = (GrowingVisitEvent *)GrowingVisitEvent.builder.setExtraSdk(@{@"testkey": @"value"})
                     .setNetworkState(@"testNetworkState")
                     .setScreenHeight(1920)
                     .setScreenWidth(1280)
                     .setDeviceBrand(@"testDeviceBrand")
                     .setDeviceModel(@"testDeviceModel")
                     .setDeviceType(@"testDeviceType")
                     .setAppName(@"testAppName")
                     .setAppVersion(@"testAppVersion")
                     .setLanguage(@"testLanguage")
                     .setSdkVersion(@"testSdkVersion")
                     .setDomain(@"testdomain")
                     .setLanguage(@"testlanguage")
                     .setLatitude(10)
                     .setLongitude(11)
                     .setPlatform(@"iOS")
                     .setTimestamp(12345678)
                     .setUserId(@"zhangsan")
                     .setUserKey(@"phone")
                     .setDeviceId(@"testdeviceID")
                     .build;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDatabase {
    {
        XCTAssertTrue([self.database clearAllItems]);
        XCTAssertTrue([self.database cleanExpiredDataIfNeeded]);
        XCTAssertEqual(self.database.countOfEvents, 0);

        NSArray *events = [self.database getEventsWithPackageNum:1];
        XCTAssertEqual(events.count, 0);
        NSArray *events2 = [self.database getEventsWithPackageNum:1 policy:GrowingEventSendPolicyInstant];
        XCTAssertEqual(events2.count, 0);
    }

    {
        NSString *uuid = [NSUUID UUID].UUIDString;
        GrowingEventJSONPersistence *event =
            [[GrowingEventJSONPersistence alloc] initWithUUID:uuid
                                                    eventType:GrowingEventTypeVisit
                                                   jsonString:self.event.toDictionary.growingHelper_jsonString
                                                       policy:GrowingEventSendPolicyInstant];
        XCTAssertNoThrow([self.database setEvent:event forKey:uuid]);
        XCTAssertEqual(self.database.countOfEvents, 1);
        NSArray *events = [self.database getEventsWithPackageNum:1 policy:GrowingEventSendPolicyInstant];
        XCTAssertEqual(events.count, 1);
    }

    {
        NSString *uuid = [NSUUID UUID].UUIDString;
        GrowingEventJSONPersistence *event =
            [[GrowingEventJSONPersistence alloc] initWithUUID:uuid
                                                    eventType:GrowingEventTypeVisit
                                                   jsonString:self.event.toDictionary.growingHelper_jsonString
                                                       policy:GrowingEventSendPolicyInstant];
        XCTAssertNoThrow([GrowingEventDatabase buildRawEventsFromEvents:@[event]]);
        XCTAssertNoThrow([GrowingEventDatabase persistenceEventWithEvent:self.event uuid:uuid]);
    }
}

- (void)testHandleDatabaseError {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.database safePerformSelector:@selector(handleDatabaseError:) arguments:nil];
    NSError *error = [NSError errorWithDomain:@"com.growingio.xctest" code:500 userInfo:@{@"key": @"value"}];
    [self.database safePerformSelector:@selector(handleDatabaseError:) arguments:error, nil];
#pragma clang diagnostic pop
}

@end
