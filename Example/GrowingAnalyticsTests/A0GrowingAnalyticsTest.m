//
//  TrackAPIMainThreadTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2019/11/8.
//  Copyright © 2019 GrowingIO. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GrowingAutotracker.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Thread/GrowingThread.h"
#import "MockEventQueue.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingConversionVariableEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitorAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"

@interface A0GrowingAnalyticsTest : XCTestCase <GrowingEventInterceptor>

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@implementation A0GrowingAnalyticsTest

+ (void)setUp {
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    configuration.idMappingEnabled = YES;
    configuration.sessionInterval = 10.0f;
    configuration.urlScheme = @"growing.xctest";
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
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

- (void)testSetConversionVariables {
    {
        [[GrowingAutotracker sharedInstance] setConversionVariables:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeConversionVariables];
        XCTAssertEqual(events.count, 1);
        
        GrowingConversionVariableEvent *event = (GrowingConversionVariableEvent *)events.firstObject;
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:@{@1 : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:@{@"key" : @1}]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeConversionVariables];
        XCTAssertEqual(events.count, 0);
    }
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

- (void)testSetVisitorAttributes {
    {
        [[GrowingAutotracker sharedInstance] setVisitorAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisitorAttributes];
        XCTAssertEqual(events.count, 1);
        
        GrowingVisitorAttributesEvent *event = (GrowingVisitorAttributesEvent *)events.firstObject;
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    }

    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:@{@1 : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:@{@"key" : @1}]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisitorAttributes];
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
        [builder setArray:@[@1, @2, @3] forKey:@"key3"];
        [builder setArray:@[@[@"1"], @[@"2"], @[@"3"]] forKey:@"key4"];
        [builder setArray:@[@{@"value":@"key"}, @{@"value":@"key"}, @{@"value":@"key"}] forKey:@"key5"];
        [builder setArray:@[NSObject.new, NSObject.new, NSObject.new] forKey:@"key6"];
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                        withAttributesBuilder:builder];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertEqualObjects(event.attributes[@"key2"], @"value1||value2||value3");
        XCTAssertEqualObjects(event.attributes[@"key3"], @"1||2||3");
        XCTAssertEqualObjects(event.attributes[@"key4"], @"(\n    1\n)||(\n    2\n)||(\n    3\n)");
        XCTAssertEqualObjects(event.attributes[@"key5"], @"{\n    value = key;\n}"
                                                         @"||{\n    value = key;\n}"
                                                         @"||{\n    value = key;\n}");
        XCTAssertNotNil(event.attributes[@"key6"]);
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
        
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:nil forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:@1 forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:@"value" forKey:nil];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:@"value" forKey:@""];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:@"value" forKey:@1];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:nil forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@[] forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@"value" forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@[@"value1", @"value2", @"value3"] forKey:nil];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@""];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@1];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                             withAttributesBuilder:builder]);
        }
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

#pragma mark - GrowingAutoTracker API Test

- (void)testPageVariableToViewControllerTest {
    UIViewController *vc = [UIViewController new];
    vc.growingPageAttributes = @{@"key" : @"value"};
    XCTAssertEqualObjects(vc.growingPageAttributes[@"key"], @"value");
    
    vc.growingPageAttributes = nil;
    XCTAssertEqualObjects(vc.growingPageAttributes[@"key"], nil);
}

@end

#pragma clang diagnostic pop
