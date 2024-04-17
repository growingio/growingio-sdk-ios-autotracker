//
//  TrackAPIMainThreadTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2019/11/8.
//  Copyright © 2019 GrowingIO. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GrowingAutotracker.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingConversionVariableEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "GrowingTrackerCore/Event/GrowingVisitorAttributesEvent.h"
#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Thread/GrowingThread.h"
#import "InvocationHelper.h"
#import "MockEventQueue.h"

static NSString *const kGrowingEventDuration = @"event_duration";

@interface A0GrowingAnalyticsTest : XCTestCase <GrowingEventInterceptor>

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation A0GrowingAnalyticsTest

+ (void)setUp {
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserId:nil];
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserKey:nil];
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

- (void)test01InitializedSuccessfully {
    XCTAssertFalse([GrowingAutotracker isInitializedSuccessfully]);
    
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
    configuration.dataSourceId = @"test";
    configuration.idMappingEnabled = YES;
    configuration.sessionInterval = 3.0f;
    configuration.urlScheme = @"growing.xctest";
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
    
    XCTAssertTrue([GrowingAutotracker isInitializedSuccessfully]);
}

- (void)test02SetUserId {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];
    NSString *userId = @"123456789";
    [[GrowingAutotracker sharedInstance] setLoginUserId:userId];

    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, userId);
        }
                  waitUntilDone:YES];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 0);
}

- (void)test03ClearUserId {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];

    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, nil);
        }
                  waitUntilDone:YES];
}

- (void)test04SetUserIdAndUserKeyTest {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];

    XCTestExpectation *expectation = [self expectationWithDescription:@"setUserIdAndUserKey Test failed : timeout"];
    expectation.expectedFulfillmentCount = 2;

    NSString *userId = @"123456789";
    [[GrowingAutotracker sharedInstance] setLoginUserId:userId userKey:@"number"];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, userId);
        XCTAssertEqualObjects([GrowingSession currentSession].loginUserKey, @"number");
        [expectation fulfill];
    }];

    userId = @"223344";
    [[GrowingAutotracker sharedInstance] setLoginUserId:userId];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, userId);
        XCTAssertEqualObjects([GrowingSession currentSession].loginUserKey, nil);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test05SetLoginUserAttributes {
    {
        [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"key": @"value"}];
        NSArray<GrowingBaseEvent *> *events =
            [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
        XCTAssertEqual(events.count, 1);

        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)events.firstObject;
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    }

    {
        [MockEventQueue.sharedQueue cleanQueue];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@1: @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"key": @1}]);
        NSArray<GrowingBaseEvent *> *events =
            [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)test06TrackCustomEvent {
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
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@1]);
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)test07TrackCustomEventWithAttributes {
    {
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName" withAttributes:@{@"key": @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    }

    {
        [MockEventQueue.sharedQueue cleanQueue];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:nil withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"" withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@1 withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName" withAttributes:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName" withAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                withAttributes:@{
                                                                    @1: @"value"
                                                                }]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"
                                                                withAttributes:@{
                                                                    @"key": @1
                                                                }]);
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)test08TrackTimer {
    {
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], nil);
        XCTAssertNotNil(event.attributes[kGrowingEventDuration]);
    }

    {
        // wrong eventName
        [MockEventQueue.sharedQueue cleanQueue];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerStart:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerStart:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerStart:@1]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerPause:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerPause:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerPause:@1]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerResume:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerResume:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerResume:@1]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@1]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] removeTimer:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] removeTimer:@""]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] removeTimer:@1]);
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }

    {
        // wrong timerId
        [MockEventQueue.sharedQueue cleanQueue];
        [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName"];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);

        [[GrowingAutotracker sharedInstance] clearTrackTimer];
    }

    {
        // remove timer
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] removeTimer:timerId];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }

    {
        // clear all timers
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] clearTrackTimer];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }

    {
        // pause
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        [[GrowingAutotracker sharedInstance] trackTimerPause:timerId];
        sleep(1);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertLessThan(((NSString *)event.attributes[kGrowingEventDuration]).floatValue, 1.0);
    }

    {
        // pause timer that not exist
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerPause:@"eventName"]);

        // pause twice
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        [[GrowingAutotracker sharedInstance] trackTimerPause:timerId];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerPause:timerId]);

        [[GrowingAutotracker sharedInstance] clearTrackTimer];
    }

    {
        // pause + resume
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        [[GrowingAutotracker sharedInstance] trackTimerPause:timerId];
        [[GrowingAutotracker sharedInstance] trackTimerResume:timerId];
        sleep(1);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertGreaterThanOrEqual(((NSString *)event.attributes[kGrowingEventDuration]).floatValue,
                                    0.6);  // sleep 不准
    }

    {
        // resume timer that not exist
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerResume:@"eventName"]);

        // resume twice
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        [[GrowingAutotracker sharedInstance] trackTimerPause:timerId];
        [[GrowingAutotracker sharedInstance] trackTimerResume:timerId];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerResume:timerId]);

        [[GrowingAutotracker sharedInstance] clearTrackTimer];
    }

    {
        // timer all pause & all resume
        [MockEventQueue.sharedQueue cleanQueue];

        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];

        [GrowingSession.currentSession performSelector:@selector(applicationDidEnterBackground)];
        NSNumber *sessionInterval = [GrowingSession.currentSession safePerformSelector:@selector(sessionInterval)];
        sleep((int)(sessionInterval.longLongValue / 1000LL) + 1);

        [GrowingSession.currentSession performSelector:@selector(applicationDidBecomeActive)];

        sleep(1);  // 2 > duration > 1
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertGreaterThanOrEqual(((NSString *)event.attributes[kGrowingEventDuration]).floatValue,
                                    0.6);  // sleep 不准
        // 不会算上前后台切换的时间
        XCTAssertLessThan(((NSString *)event.attributes[kGrowingEventDuration]).floatValue, 2.0);
    }
}

- (void)test09TrackTimerWithAttributes {
    {
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key": @"value"}];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertNotNil(event.attributes[kGrowingEventDuration]);
    }

    {
        // wrong timerId
        [MockEventQueue.sharedQueue cleanQueue];
        [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName" withAttributes:@{@"key": @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);

        [[GrowingAutotracker sharedInstance] clearTrackTimer];
    }

    {
        // remove timer
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] removeTimer:timerId];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key": @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }

    {
        // clear all timers
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(100);
        [[GrowingAutotracker sharedInstance] clearTrackTimer];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key": @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }

    {
        // pause
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        [[GrowingAutotracker sharedInstance] trackTimerPause:timerId];
        sleep(1);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key": @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertLessThan(((NSString *)event.attributes[kGrowingEventDuration]).floatValue, 1.0);
    }

    {
        // pause + resume
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        [[GrowingAutotracker sharedInstance] trackTimerPause:timerId];
        [[GrowingAutotracker sharedInstance] trackTimerResume:timerId];
        sleep(1);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key": @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertGreaterThanOrEqual(((NSString *)event.attributes[kGrowingEventDuration]).floatValue,
                                    0.6);  // sleep 不准
    }

    {
        [MockEventQueue.sharedQueue cleanQueue];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:nil withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"" withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@1 withAttributes:@{@"key": @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName" withAttributes:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName" withAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName"
                                                             withAttributes:@{
                                                                 @1: @"value"
                                                             }]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName" withAttributes:@{@"key": @1}]);
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)test10TrackTimerWithAttributesBuilder {
    {
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
        [builder setString:@"value" forKey:@"key"];
        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
        [builder setArray:@[@1, @2, @3] forKey:@"key3"];
        [builder setArray:@[@[@"1"], @[@"2"], @[@"3"]] forKey:@"key4"];
        [builder setArray:@[@{@"value": @"key"}, @{@"value": @"key"}, @{@"value": @"key"}] forKey:@"key5"];
        [builder setArray:@[NSObject.new, NSObject.new, NSObject.new] forKey:@"key6"];
        [builder setArray:@[NSNull.new, NSNull.new, NSNull.new] forKey:@"key7"];
        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@""];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertEqualObjects(event.attributes[@"key2"], @"value1||value2||value3");
        XCTAssertEqualObjects(event.attributes[@"key3"], @"1||2||3");
        XCTAssertEqualObjects(event.attributes[@"key4"], @"(\n    1\n)||(\n    2\n)||(\n    3\n)");
        XCTAssertEqualObjects(event.attributes[@"key5"],
                              @"{\n    value = key;\n}"
                              @"||{\n    value = key;\n}"
                              @"||{\n    value = key;\n}");
        XCTAssertNotNil(event.attributes[@"key6"]);
        XCTAssertEqualObjects(event.attributes[@"key7"], @"||||");
        XCTAssertEqualObjects(event.attributes[@""], @"value1||value2||value3");
        XCTAssertNotNil(event.attributes[kGrowingEventDuration]);
    }

    {
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
        [builder setString:@"value" forKey:@"key"];
        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:nil withAttributes:builder.build]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"" withAttributes:builder.build]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@1 withAttributes:builder.build]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:nil]);

        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:nil forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:@1 forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:@"value" forKey:nil];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setString:@"value" forKey:@1];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:nil forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@[] forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@"value" forKey:@"key"];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@[@"value1", @"value2", @"value3"] forKey:nil];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        {
            GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
            [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@1];
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:builder.build]);
        }
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)test11GetDeviceId {
    XCTAssertNotNil([[GrowingAutotracker sharedInstance] getDeviceId]);
}

- (void)test12GetSessionId {
    XCTAssertNotNil([[GrowingSession currentSession] sessionId]);
}

- (void)test13SetLocation {
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

- (void)test14SetDataCollectionEnabled {
    NSString *eventName = @"name";
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:NO];

    [[GrowingAutotracker sharedInstance] trackCustomEvent:eventName];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            NSArray *events = MockEventQueue.sharedQueue.allEvent;
            XCTAssertEqual(events.count, 0);
        }
                  waitUntilDone:YES];

    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:YES];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            NSArray *events = MockEventQueue.sharedQueue.allEvent;
            XCTAssertEqual(events.count, 1);  // VISIT

            GrowingBaseEvent *event = [MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeVisit];
            XCTAssertTrue([event isKindOfClass:[GrowingVisitEvent class]]);
        }
                  waitUntilDone:YES];

    [[GrowingAutotracker sharedInstance] trackCustomEvent:eventName];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            NSArray *events = MockEventQueue.sharedQueue.allEvent;
            XCTAssertEqual(events.count, 2);  // VISIT + CUSTOM

            GrowingBaseEvent *event = [MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
            XCTAssertTrue([event isKindOfClass:[GrowingCustomEvent class]]);
            GrowingCustomEvent *customEvent = (GrowingCustomEvent *)event;
            XCTAssertEqualObjects(customEvent.eventName, eventName);
        }
                  waitUntilDone:YES];
}

#pragma mark - GrowingAutoTracker API Test

- (void)test15AutotrackPageWithoutAttributesNotTrackTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest"];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"testAutotrackPageWithoutAttributesNotTrackTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 0);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)test16AutotrackPageWithoutAttributesTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest"];
    [controller viewDidAppear:NO];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"testAutotrackPageWithoutAttributesTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 1);

        GrowingPageEvent *event = (GrowingPageEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
        XCTAssertEqualObjects(event.path, @"/XCTest");
        XCTAssertEqualObjects(event.attributes[@"key"], nil);

        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
        XCTAssertEqualObjects(dic[@"path"], @"/XCTest");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], nil);

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)test17AutotrackPageWithAttributesNotTrackTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:@{@"key": @"value"}];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"testAutotrackPageWithAttributesNotTrackTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 0);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)test18AutotrackPageWithAttributesTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:@{@"key": @"value"}];
    [controller viewDidAppear:NO];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"testAutotrackPageWithAttributesTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 1);

        GrowingPageEvent *event = (GrowingPageEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
        XCTAssertEqualObjects(event.path, @"/XCTest");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");

        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
        XCTAssertEqualObjects(dic[@"path"], @"/XCTest");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)test19AutotrackPageWithInvalidAliasTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:nil alias:@"XCTest"];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:nil];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@""];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@1];
    [controller viewDidAppear:NO];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"testAutotrackPageWithInvalidAliasTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 0);

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)test20AutotrackPageWithInvalidAttributesTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:nil];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:@"value"];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:@{@1: @"value"}];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:@{@"key": @1}];
    [controller viewDidAppear:NO];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"testAutotrackPageWithInvalidAttributesTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 0);

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)test21AutotrackPageInNotMainThreadTest {
    {
        UIViewController *controller = [[UIViewController alloc] init];
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest"]);
            XCTAssertNoThrow([[GrowingAutotracker sharedInstance] autotrackPage:controller
                                                                          alias:@"XCTest"
                                                                     attributes:@{@"key": @"value"}]);
        });
    }
}

#pragma mark - GeneralProps Test

- (void)test22SetGeneralProps {
    {
        // set generalProps
        {
            // set generalProps
            [MockEventQueue.sharedQueue cleanQueue];
            
            [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key" : @"value"}];
            
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        }
        
        {
            // merge generalProps
            [MockEventQueue.sharedQueue cleanQueue];
            
            [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key2" : @"value2"}];
            
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqualObjects(event.attributes[@"key2"], @"value2");
        }
        
        {
            // merge generalProps 2
            [MockEventQueue.sharedQueue cleanQueue];
                        
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName" withAttributes:@{@"key" : @"value_merged"}];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqualObjects(event.attributes[@"key"], @"value_merged");
        }
        
        {
            // merge generalProps 3 (hybrid)
            // customEventType = 1，track调用
            [MockEventQueue.sharedQueue cleanQueue];

            Class class = NSClassFromString(@"GrowingHybridBridgeProvider");
            SEL selector = NSSelectorFromString(@"sharedInstance");
            if (class && [class respondsToSelector:selector]) {
                id sharedInstance = [class performSelector:selector];
                SEL selector2 = NSSelectorFromString(@"parseEventJsonString:");
                if (sharedInstance && [sharedInstance respondsToSelector:selector2]) {
                    NSString *jsonString = @"{\"deviceId\":\"7196f014-d7bc-4bd8-b920-757cb2375ff6\",\"sessionId\":\"d5cbcf77-b38b-4223-954f-c6a2fdc0c098\","
                    @"\"eventType\":\"CUSTOM\",\"platform\":\"Web\",\"timestamp\":1602485628504,\"domain\":\"test-browser.growingio.com\",\"path\":\"/push/"
                    @"web.html\",\"query\":\"a=1&b=2\",\"title\":\"Hybrid测试页面\",\"referralPage\":\"http://test-browser.growingio.com/push\",\"globalSeque"
                    @"nceId\":99,\"eventSequenceId\":3,\"eventName\":\"eventName\",\"customEventType\":1,\"attributes\":{\"key\":\"value_hybrid\",\"key3\":\"\",\"key4\":null}}";
                    [sharedInstance performSelector:selector2 withObject:jsonString];
                    
                    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
                    XCTAssertEqual(events.count, 1);

                    GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
                    XCTAssertEqualObjects(event.eventName, @"eventName");
                    XCTAssertEqual(event.attributes.count, 3);
                    XCTAssertEqualObjects(event.attributes[@"key"], @"value_hybrid"); //hybrid优先
                    XCTAssertEqualObjects(event.attributes[@"key2"], @"value2"); //合并generalProps
                    XCTAssertEqualObjects(event.attributes[@"key3"], @"");
                }
            }
        }
        
        {
            // merge generalProps 4 (hybrid)
            // customEventType = 0，不是track调用，不加generalProps
            [MockEventQueue.sharedQueue cleanQueue];

            Class class = NSClassFromString(@"GrowingHybridBridgeProvider");
            SEL selector = NSSelectorFromString(@"sharedInstance");
            if (class && [class respondsToSelector:selector]) {
                id sharedInstance = [class performSelector:selector];
                SEL selector2 = NSSelectorFromString(@"parseEventJsonString:");
                if (sharedInstance && [sharedInstance respondsToSelector:selector2]) {
                    NSString *jsonString = @"{\"deviceId\":\"7196f014-d7bc-4bd8-b920-757cb2375ff6\",\"sessionId\":\"d5cbcf77-b38b-4223-954f-c6a2fdc0c098\","
                    @"\"eventType\":\"CUSTOM\",\"platform\":\"Web\",\"timestamp\":1602485628504,\"domain\":\"test-browser.growingio.com\",\"path\":\"/push/"
                    @"web.html\",\"query\":\"a=1&b=2\",\"title\":\"Hybrid测试页面\",\"referralPage\":\"http://test-browser.growingio.com/push\",\"globalSeque"
                    @"nceId\":99,\"eventSequenceId\":3,\"eventName\":\"eventName\",\"customEventType\":0,\"attributes\":{\"key\":\"value_hybrid\",\"key3\":\"\",\"key4\":null}}";
                    [sharedInstance performSelector:selector2 withObject:jsonString];
                    
                    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
                    XCTAssertEqual(events.count, 1);

                    GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
                    XCTAssertEqualObjects(event.eventName, @"eventName");
                    XCTAssertEqual(event.attributes.count, 2);
                    XCTAssertEqualObjects(event.attributes[@"key"], @"value_hybrid");
                    XCTAssertEqualObjects(event.attributes[@"key3"], @"");
                }
            }
        }
        
        {
            // merge generalProps 5 (hybrid)
            // customEventType = nil，无法判断是否track调用，统一加generalProps
            [MockEventQueue.sharedQueue cleanQueue];

            Class class = NSClassFromString(@"GrowingHybridBridgeProvider");
            SEL selector = NSSelectorFromString(@"sharedInstance");
            if (class && [class respondsToSelector:selector]) {
                id sharedInstance = [class performSelector:selector];
                SEL selector2 = NSSelectorFromString(@"parseEventJsonString:");
                if (sharedInstance && [sharedInstance respondsToSelector:selector2]) {
                    NSString *jsonString = @"{\"deviceId\":\"7196f014-d7bc-4bd8-b920-757cb2375ff6\",\"sessionId\":\"d5cbcf77-b38b-4223-954f-c6a2fdc0c098\","
                    @"\"eventType\":\"CUSTOM\",\"platform\":\"Web\",\"timestamp\":1602485628504,\"domain\":\"test-browser.growingio.com\",\"path\":\"/push/"
                    @"web.html\",\"query\":\"a=1&b=2\",\"title\":\"Hybrid测试页面\",\"referralPage\":\"http://test-browser.growingio.com/push\",\"globalSeque"
                    @"nceId\":99,\"eventSequenceId\":3,\"eventName\":\"eventName\",\"attributes\":{\"key\":\"value_hybrid\",\"key3\":\"\",\"key4\":null}}";
                    [sharedInstance performSelector:selector2 withObject:jsonString];
                    
                    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
                    XCTAssertEqual(events.count, 1);

                    GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
                    XCTAssertEqualObjects(event.eventName, @"eventName");
                    XCTAssertEqual(event.attributes.count, 3);
                    XCTAssertEqualObjects(event.attributes[@"key"], @"value_hybrid");
                    XCTAssertEqualObjects(event.attributes[@"key2"], @"value2");
                    XCTAssertEqualObjects(event.attributes[@"key3"], @"");
                }
            }
        }
        
        {
            // replace generalProps
            [MockEventQueue.sharedQueue cleanQueue];
            
            [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key" : @"value_modif"}];
            
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqualObjects(event.attributes[@"key"], @"value_modif");
        }
    }
    
    {
        // clear generalProps
        {
            // clear generalProps
            [MockEventQueue.sharedQueue cleanQueue];
            
            [[GrowingAutotracker sharedInstance] clearGeneralProps];
            
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqual(event.attributes.count, 0);
        }
        
        {
            // re-clear generalProps
            [MockEventQueue.sharedQueue cleanQueue];
            
            [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key" : @"value"}];
            [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key2" : @"value2"}];
            [[GrowingAutotracker sharedInstance] clearGeneralProps];
            
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqual(event.attributes.count, 0);
        }
    }
    
    {
        // remove generalProps
        {
            // remove key
            [MockEventQueue.sharedQueue cleanQueue];

            [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key" : @"value"}];
            [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key2" : @"value2"}];
            [[GrowingAutotracker sharedInstance] removeGeneralProps:@[@"key"]];
            
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqual(event.attributes.count, 1);
            XCTAssertEqualObjects(event.attributes[@"key2"], @"value2");
        }
        
        {
            // remove key2
            [MockEventQueue.sharedQueue cleanQueue];

            [[GrowingAutotracker sharedInstance] removeGeneralProps:@[@"key2"]];
            
            [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventName, @"eventName");
            XCTAssertEqual(event.attributes.count, 0);
        }
    }

    {
        // set wrong generalProps
        [MockEventQueue.sharedQueue cleanQueue];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setGeneralProps:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setGeneralProps:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setGeneralProps:@{ @1: @"value" }]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key": @1}]);
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName" withAttributes:@{@"key2": @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqual(event.attributes.count, 1);
        XCTAssertEqualObjects(event.attributes[@"key2"], @"value");
    }
    
    {
        // remove generalProps with wrong keys
        [MockEventQueue.sharedQueue cleanQueue];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] removeGeneralProps:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] removeGeneralProps:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] removeGeneralProps:@{@"key": @"value"}]);
        NSArray *array = @[@"key", @(1)];
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] removeGeneralProps:array]);
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqual(event.attributes.count, 0);
    }
    
    {
        // set dynamic generalProps
        [MockEventQueue.sharedQueue cleanQueue];
        
        [[GrowingAutotracker sharedInstance] setGeneralProps:@{@"key" : @"value", @"key2" : @"value2"}];
        [[GrowingAutotracker sharedInstance] registerDynamicGeneralPropsBlock:^NSDictionary<NSString *,NSString *> * _Nonnull{
            return @{@"key": @"valueChange", @"key3": @(1)};
        }];
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"eventName"];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);

        GrowingCustomEvent *event = (GrowingCustomEvent *)events.lastObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"valueChange");
        XCTAssertEqualObjects(event.attributes[@"key2"], @"value2");
        XCTAssertEqualObjects(event.attributes[@"key3"], @"1");
    }
}

@end

#pragma clang diagnostic pop
