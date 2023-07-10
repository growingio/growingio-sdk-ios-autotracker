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
#import "InvocationHelper.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingConversionVariableEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitorAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"

static NSString * const kGrowingEventDuration = @"event_duration";

@interface A0GrowingAnalyticsTest : XCTestCase <GrowingEventInterceptor>

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@implementation A0GrowingAnalyticsTest

+ (void)setUp {
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserId:nil];
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserKey:nil];
    
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    configuration.dataSourceId = @"test";
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
        XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, userId);
    } waitUntilDone:YES];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 0);
}

- (void)testClearUserId {
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, nil);
    } waitUntilDone:YES];
}

- (void)testSetUserIdAndUserKeyTest {
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

//- (void)testSetConversionVariables {
//    {
//        [[GrowingAutotracker sharedInstance] setConversionVariables:@{@"key" : @"value"}];
//        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeConversionVariables];
//        XCTAssertEqual(events.count, 1);
//
//        GrowingConversionVariableEvent *event = (GrowingConversionVariableEvent *)events.firstObject;
//        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
//    }
//
//    {
//        [MockEventQueue.sharedQueue cleanQueue];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
//#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:nil]);
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:@"value"]);
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:@{@1 : @"value"}]);
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setConversionVariables:@{@"key" : @1}]);
//#pragma clang diagnostic pop
//        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeConversionVariables];
//        XCTAssertEqual(events.count, 0);
//    }
//}

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

//- (void)testSetVisitorAttributes {
//    {
//        [[GrowingAutotracker sharedInstance] setVisitorAttributes:@{@"key" : @"value"}];
//        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisitorAttributes];
//        XCTAssertEqual(events.count, 1);
//
//        GrowingVisitorAttributesEvent *event = (GrowingVisitorAttributesEvent *)events.firstObject;
//        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
//    }
//
//    {
//        [MockEventQueue.sharedQueue cleanQueue];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
//#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:nil]);
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:@"value"]);
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:@{@1 : @"value"}]);
//        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] setVisitorAttributes:@{@"key" : @1}]);
//#pragma clang diagnostic pop
//        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisitorAttributes];
//        XCTAssertEqual(events.count, 0);
//    }
//}

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

- (void)testTrackTimer {
    {
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(1000);
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
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
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
    
    {
        // wrong timerId
        [MockEventQueue.sharedQueue cleanQueue];
        [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(1000);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName"];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
        
        [[GrowingAutotracker sharedInstance] clearTrackTimer];
    }
    
    {
        // remove timer
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(1000);
        [[GrowingAutotracker sharedInstance] removeTimer:timerId];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
    
    {
        // clear all timers
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(1000);
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
        XCTAssertGreaterThanOrEqual(((NSString *)event.attributes[kGrowingEventDuration]).floatValue, 0.6); // sleep 不准
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
        
        NSString *oldSessionId = GrowingSession.currentSession.sessionId;
        [GrowingSession.currentSession performSelector:@selector(applicationDidBecomeActive)];
        
        sleep(1); // 2 > duration > 1
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertGreaterThanOrEqual(((NSString *)event.attributes[kGrowingEventDuration]).floatValue, 0.6); // sleep 不准
        // 不会算上前后台切换的时间
        XCTAssertLessThan(((NSString *)event.attributes[kGrowingEventDuration]).floatValue, 2.0);
    }
}

- (void)testTrackTimerWithAttributes {
    {
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(1000);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key" : @"value"}];
        
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
        usleep(1000);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName" withAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
        
        [[GrowingAutotracker sharedInstance] clearTrackTimer];
    }
    
    {
        // remove timer
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(1000);
        [[GrowingAutotracker sharedInstance] removeTimer:timerId];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
    
    {
        // clear all timers
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        usleep(1000);
        [[GrowingAutotracker sharedInstance] clearTrackTimer];
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
    
    {
        // pause
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        [[GrowingAutotracker sharedInstance] trackTimerPause:timerId];
        sleep(1);
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key" : @"value"}];
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
        [[GrowingAutotracker sharedInstance] trackTimerEnd:timerId withAttributes:@{@"key" : @"value"}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventName, @"eventName");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");
        XCTAssertGreaterThanOrEqual(((NSString *)event.attributes[kGrowingEventDuration]).floatValue, 0.6); // sleep 不准
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:nil
                                                             withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@""
                                                             withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@1
                                                             withAttributes:@{@"key" : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName"
                                                             withAttributes:nil]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName"
                                                             withAttributes:@"value"]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName"
                                                             withAttributes:@{@1 : @"value"}]);
        XCTAssertNoThrow([[GrowingAutotracker sharedInstance] trackTimerEnd:@"eventName"
                                                             withAttributes:@{@"key" : @1}]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)testTrackTimerWithAttributesBuilder {
    {
        NSString *timerId = [[GrowingAutotracker sharedInstance] trackTimerStart:@"eventName"];
        GrowingAttributesBuilder *builder = GrowingAttributesBuilder.new;
        [builder setString:@"value" forKey:@"key"];
        [builder setArray:@[@"value1", @"value2", @"value3"] forKey:@"key2"];
        [builder setArray:@[@1, @2, @3] forKey:@"key3"];
        [builder setArray:@[@[@"1"], @[@"2"], @[@"3"]] forKey:@"key4"];
        [builder setArray:@[@{@"value":@"key"}, @{@"value":@"key"}, @{@"value":@"key"}] forKey:@"key5"];
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
        XCTAssertEqualObjects(event.attributes[@"key5"], @"{\n    value = key;\n}"
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
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

- (void)testAutotrackPageWithoutAttributesNotTrackTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAutotrackPageWithoutAttributesNotTrackTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 0);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)testAutotrackPageWithoutAttributesTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest"];
    [controller viewDidAppear:NO];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAutotrackPageWithoutAttributesTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 1);
        
        GrowingPageEvent *event = (GrowingPageEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
        XCTAssertEqualObjects(event.pageName, @"XCTest");
        XCTAssertEqualObjects(event.attributes[@"key"], nil);

        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
        XCTAssertEqualObjects(dic[@"path"], @"XCTest");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], nil);

        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)testAutotrackPageWithAttributesNotTrackTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:@{@"key" : @"value"}];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAutotrackPageWithAttributesNotTrackTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 0);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)testAutotrackPageWithAttributesTest {
    UIViewController *controller = [[UIViewController alloc] init];
    [[GrowingAutotracker sharedInstance] autotrackPage:controller alias:@"XCTest" attributes:@{@"key" : @"value"}];
    [controller viewDidAppear:NO];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAutotrackPageWithAttributesTest Test failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertEqual(events.count, 1);
        
        GrowingPageEvent *event = (GrowingPageEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
        XCTAssertEqualObjects(event.pageName, @"XCTest");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");

        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
        XCTAssertEqualObjects(dic[@"path"], @"XCTest");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");

        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

@end

#pragma clang diagnostic pop
