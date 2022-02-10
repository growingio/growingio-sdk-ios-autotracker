//
//  GrowingSessionTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/17.
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

#import "GrowingSession.h"
#import "GrowingConfigurationManager.h"
#import "GrowingServiceManager.h"
#import "GrowingEventDatabaseService.h"
#import "GrowingEventFMDatabase.h"
#import "MockEventQueue.h"
#import "GrowingTrackEventType.h"
#import "InvocationHelper.h"

@interface GrowingSessionTest : XCTestCase <GrowingUserIdChangedDelegate>

@end

@implementation GrowingSessionTest

+ (void)setUp {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithProjectId:@"test"];
    // 避免不执行readPropertyInTrackThread
    config.dataCollectionEnabled = YES;
    config.sessionInterval = 10.0f;
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
    
    // 避免insertEventToDatabase异常
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventDatabaseService)
                                                implClass:GrowingEventFMDatabase.class];
    
    [GrowingSession startSession];
    [GrowingSession.currentSession generateVisit];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSessionStart {
    XCTAssertNotNil(GrowingSession.currentSession);
    XCTAssertNotNil(GrowingSession.currentSession.sessionId);
}

- (void)testGenerateVisit {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled = NO;
    [GrowingSession.currentSession generateVisit];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 0);
    
    GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled = YES;
    [GrowingSession.currentSession generateVisit];
    NSArray<GrowingBaseEvent *> *events2 = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events2.count, 1);
}

- (void)testApplicationLifeCycle {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    {
        NSString *oldSessionId = GrowingSession.currentSession.sessionId;
        [GrowingSession.currentSession performSelector:@selector(applicationDidBecomeActive)];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
        XCTAssertEqual(events.count, 0);
        XCTAssertEqualObjects(oldSessionId, GrowingSession.currentSession.sessionId);
    }
    
    {
        [GrowingSession.currentSession performSelector:@selector(applicationDidEnterBackground)];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeAppClosed];
        XCTAssertEqual(events.count, 1);
    }
    
    {
        [GrowingSession.currentSession performSelector:@selector(applicationWillResignActive)];
        NSNumber *sessionInterval = [GrowingSession.currentSession safePerformSelector:@selector(sessionInterval)];
        sleep((int)(sessionInterval.longLongValue / 1000LL));
        
        NSString *oldSessionId = GrowingSession.currentSession.sessionId;
        [GrowingSession.currentSession performSelector:@selector(applicationDidBecomeActive)];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
        XCTAssertEqual(events.count, 1);
        XCTAssertNotEqualObjects(oldSessionId, GrowingSession.currentSession.sessionId);
    }
    
    {
        [GrowingSession.currentSession performSelector:@selector(applicationWillTerminate)];
    }
#pragma clang diagnostic pop
}

- (void)testUserIdChangedDelegate {
    [GrowingSession.currentSession addUserIdChangedDelegate:self];
    [GrowingSession.currentSession setLoginUserId:@"testUserIdChangedDelegate" userKey:@"testUserIdChangedDelegate"];
    [GrowingSession.currentSession removeUserIdChangedDelegate:self];
}

#pragma mark - GrowingUserIdChangedDelegate

- (void)userIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId {
    XCTAssertNotEqualObjects(oldUserId, newUserId);
}

@end
