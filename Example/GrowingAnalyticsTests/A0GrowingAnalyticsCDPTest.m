//
//  GrowingAnalyticsCDPTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/2/18.
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
#import "GrowingAutotracker.h"
#import "GrowingTracker.h"
#import "GrowingDispatchManager.h"
#import "GrowingEventManager.h"
#import "GrowingSession.h"
#import "GrowingThread.h"
#import "MockEventQueue.h"
#import "GrowingCustomEvent.h"
#import "GrowingResourceCustomEvent.h"
#import "GrowingConversionVariableEvent.h"
#import "GrowingLoginUserAttributesEvent.h"
#import "GrowingVisitorAttributesEvent.h"
#import "GrowingTrackEventType.h"

@interface A0GrowingAnalyticsCDPTest : XCTestCase <GrowingEventInterceptor>

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@implementation A0GrowingAnalyticsCDPTest

+ (void)setUp {
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    configuration.idMappingEnabled = YES;
    configuration.sessionInterval = 10.0f;
    configuration.urlScheme = @"growing.xctest";
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
    [GrowingTracker startWithConfiguration:configuration launchOptions:nil];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingEventManager sharedInstance] addInterceptor:self];
}

- (void)tearDown {
    [[GrowingEventManager sharedInstance] removeInterceptor:self];
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *)event {
    XCTAssertTrue([NSThread currentThread] == [GrowingThread sharedThread]);
}

#pragma mark - GrowingCoreKit API Test

- (void)testSetUserId {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];
    NSString *userId = @"123456789";
    [[GrowingAutotracker sharedInstance] setLoginUserId:userId];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqual([GrowingSession currentSession].loginUserId, userId);
    } waitUntilDone:YES];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 1);
}

- (void)testClearUserId {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqual([GrowingSession currentSession].loginUserId, nil);
    } waitUntilDone:YES];
}

- (void)testSetUserIdAndUserKeyTest {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setUserIdAndUserKey Test failed : timeout"];
    expectation.expectedFulfillmentCount = 2;
    
    NSString *userId = @"123456789";
    [[GrowingAutotracker sharedInstance] setLoginUserId:userId userKey:@"number"];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqual([GrowingSession currentSession].loginUserId, userId);
        XCTAssertEqual([GrowingSession currentSession].loginUserKey, @"number");
        [expectation fulfill];
    }];
    
    userId = @"223344";
    [[GrowingAutotracker sharedInstance] setLoginUserId:userId];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqual([GrowingSession currentSession].loginUserId, userId);
        XCTAssertEqual([GrowingSession currentSession].loginUserKey, nil);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)testSetLoginUserAttributes {
    {
        [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
        XCTAssertEqual(events.count, 1);
        
        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)events.firstObject;
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@1 : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"key" : @1}]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)testTrackCustomEvent {
    {
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], nil);
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@1]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)testTrackCustomEventWithAttributes {
    {
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                               withAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:nil
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@""
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@1
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                withAttributes:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                withAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                withAttributes:@{@1 : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                withAttributes:@{@"key" : @1}]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)testTrackCustomEventWithAttributesBuilder {
    {
        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
        [builder setString:@"value" forKey:@"key"];
        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                        withAttributesBuilder:builder];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertEqualObjects(event.attributes[@"key2"], @"value1||value2||value3");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
        [builder setString:@"value" forKey:@"key"];
        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:nil
                                                         withAttributesBuilder:builder]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@""
                                                         withAttributesBuilder:builder]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@1
                                                         withAttributesBuilder:builder]);
        
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                         withAttributesBuilder:nil]);
        
        GrowingAttributesBuilder *builder2 = GrowingAttributesBuilder.new;
        [builder2 setString:@1 forKey:@"key"];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                         withAttributesBuilder:builder2]);
        [builder2 setString:@"value" forKey:@1];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                         withAttributesBuilder:builder2]);
        [builder2 setArray:@"value" forKey:@"key2"];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                         withAttributesBuilder:builder2]);
        [builder2 setArray:@[] forKey:@"key2"];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                         withAttributesBuilder:builder2]);
        [builder2 setArray:@[@"value1", @"value2", @"value3"] forKey:@1];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                         withAttributesBuilder:builder2]);
        [builder2 setArray:@[@1, @2, @3] forKey:@"key2"];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                         withAttributesBuilder:builder2]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)testTrackCustomEventWithItem {
    // Autotracker
    {
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                      itemKey:@"itemKey"
                                                       itemId:@"itemId"];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingResourceCustomEvent *event = (GrowingResourceCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], nil);
        XCTAssertEqualObjects(event.resourceItem.itemKey, @"itemKey");
        XCTAssertEqualObjects(event.resourceItem.itemId, @"itemId");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:nil
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@""
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@1
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:nil
                                                                        itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@""
                                                                        itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@1
                                                                        itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:@1]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
    
    // Tracker
    {
        [[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                  itemKey:@"itemKey"
                                                   itemId:@"itemId"];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingResourceCustomEvent *event = (GrowingResourceCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], nil);
        XCTAssertEqualObjects(event.resourceItem.itemKey, @"itemKey");
        XCTAssertEqualObjects(event.resourceItem.itemId, @"itemId");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:nil
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@""
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@1
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:nil
                                                                    itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@""
                                                                    itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@1
                                                                    itemId:@"itemId"]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:nil]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:@""]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:@1]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)testTrackCustomEventWithItemAndAttributes {
    // Autotracker
    {
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                      itemKey:@"itemKey"
                                                       itemId:@"itemId"
                                               withAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingResourceCustomEvent *event = (GrowingResourceCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertEqualObjects(event.resourceItem.itemKey, @"itemKey");
        XCTAssertEqualObjects(event.resourceItem.itemId, @"itemId");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:nil
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@""
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@1
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:nil
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@""
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@1
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:nil
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:@""
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:@1
                                                                withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"
                                                                withAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@1 : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                       itemKey:@"itemKey"
                                                                        itemId:@"itemId"
                                                                withAttributes:@{@"key" : @1}]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
    
    // Tracker
    {
        [[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                  itemKey:@"itemKey"
                                                   itemId:@"itemId"
                                           withAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingResourceCustomEvent *event = (GrowingResourceCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertEqualObjects(event.resourceItem.itemKey, @"itemKey");
        XCTAssertEqualObjects(event.resourceItem.itemId, @"itemId");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:nil
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@""
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@1
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:nil
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@""
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@1
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:nil
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:@""
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:@1
                                                            withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"
                                                            withAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@1: @"value"}]);
        XCTAssertNoThrow([[GrowingTracker sharedInstance] trackCustomEvent:@"eventName"
                                                                   itemKey:@"itemKey"
                                                                    itemId:@"itemId"
                                                            withAttributes:@{@"key": @1}]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)testGetDeviceId {
    XCTAssertNotNil([[GrowingAutotracker sharedInstance] getDeviceId]);
}

- (void)testGetSessionId {
    XCTAssertNotNil([[GrowingSession currentSession] sessionId]);
}

- (void)testSetLocation {
    double latitude = 31.111111111;
    double longitude = 32.2222222222;
    [[GrowingAutotracker sharedInstance] setLocation:latitude longitude:longitude];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCleanLocation Test failed : timeout"];
    expectation.expectedFulfillmentCount = 2;
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqual([GrowingSession currentSession].latitude, latitude);
        XCTAssertEqual([GrowingSession currentSession].longitude, longitude);
        
        [expectation fulfill];
    }];

    [[GrowingAutotracker sharedInstance] cleanLocation];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqual([GrowingSession currentSession].latitude, 0);
        XCTAssertEqual([GrowingSession currentSession].longitude, 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)testSetLocationSendVisit {
    [[GrowingAutotracker sharedInstance] cleanLocation];
    double latitude = 30.11;
    double longitude = 32.22;
    [[GrowingAutotracker sharedInstance] setLocation:latitude longitude:longitude];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 1);
    
    GrowingVisitEvent *event = (GrowingVisitEvent *)events.firstObject;
    XCTAssertEqual(event.latitude, latitude);
    XCTAssertEqual(event.longitude, longitude);
}

- (void)testSetDataCollectionEnabled {
    NSString *eventName = @"name";
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:NO];
    
    [[GrowingAutotracker sharedInstance] trackCustomEvent:eventName];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        NSArray *events = MockEventQueue.sharedQueue.allEvent;
        XCTAssertEqual(events.count, 0);
    } waitUntilDone:YES];
    
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:YES];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        NSArray *events = MockEventQueue.sharedQueue.allEvent;
        XCTAssertEqual(events.count, 1); // VISIT
        
        GrowingBaseEvent *event = [MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeVisit];
        XCTAssertTrue([event isKindOfClass:[GrowingVisitEvent class]]);
    } waitUntilDone:YES];
    
    [[GrowingAutotracker sharedInstance] trackCustomEvent:eventName];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        NSArray *events = MockEventQueue.sharedQueue.allEvent;
        XCTAssertEqual(events.count, 2); // VISIT + CUSTOM
        
        GrowingBaseEvent *event = [MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        XCTAssertTrue([event isKindOfClass:[GrowingCustomEvent class]]);
        GrowingCustomEvent *customEvent = (GrowingCustomEvent *)event;
        XCTAssertEqualObjects(customEvent.eventName, eventName);
    } waitUntilDone:YES];
}

@end

#pragma clang diagnostic pop
