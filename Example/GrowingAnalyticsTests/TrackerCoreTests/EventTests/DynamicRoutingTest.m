//
//  DynamicRoutingTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/31.
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

#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingEventDatabaseService.h"
#import "GrowingServiceManager.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingAppCloseEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"
#import "Services/Protobuf/GrowingEventProtobufDatabase.h"

#import "GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Network/Request/GrowingEventRequest.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "Services/Database/FMDB/GrowingFMDB.h"
#import "Services/JSON/GrowingEventJSONDatabase.h"
#import "Services/JSON/GrowingEventJSONPersistence.h"

@interface RoutingNetworkStub : NSObject <GrowingEventNetworkService>
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSMutableArray *requests;
@end
@implementation RoutingNetworkStub
+ (BOOL)singleton {
    return YES;
}
+ (instancetype)sharedInstance {
    static RoutingNetworkStub *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [self new];
        instance.requests = [NSMutableArray array];
    });
    return instance;
}
- (void)sendRequest:(id<GrowingRequestProtocol>)request
         completion:(void (^)(NSHTTPURLResponse *, NSData *, NSError *))callback {
    [self.requests addObject:request];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.absoluteURL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:nil];
    if (callback) callback(response, nil, nil);
}
@end

@interface GrowingPageManager (RoutingTest)
- (void)viewControllerDidAppear:(UIViewController *)controller;
@end

@interface DynamicRoutingTest : XCTestCase
@property (nonatomic, strong) GrowingTrackConfiguration *savedConfiguration;
@property (nonatomic, assign) NSUInteger savedSequence;
@property (nonatomic, copy) GrowingBaseBuilder * (^savedPageBuilder)(void);
@property (nonatomic, assign) Class savedNetworkClass;
@property (nonatomic, strong) id savedNetworkInstance;
@property (nonatomic, strong) UIWindow *pageWindow;
@property (nonatomic, strong) NSPointerArray *savedVisiblePages;
@property (nonatomic, copy) NSString *savedPagePath;
@property (nonatomic, strong) NSNumber *savedPageTimestamp;
@end

@implementation DynamicRoutingTest
- (void)setUp {
    [GrowingPageManager.sharedInstance start];
    [GrowingServiceManager.sharedInstance registerAllServices];
    self.savedNetworkClass =
        [GrowingServiceManager.sharedInstance serviceImplClass:@protocol(GrowingEventNetworkService)];
    NSMutableDictionary *instances = [GrowingServiceManager.sharedInstance valueForKey:@"allServiceInstanceDict"];
    self.savedNetworkInstance = instances[NSStringFromProtocol(@protocol(GrowingEventNetworkService))];
    instances[NSStringFromProtocol(@protocol(GrowingEventNetworkService))] = RoutingNetworkStub.sharedInstance;
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventNetworkService)
                                                implClass:RoutingNetworkStub.class];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            self.savedConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
            self.savedSequence = GrowingConfigurationManager.sharedInstance.routingSequence;
            self.savedPageBuilder = GrowingEventManager.sharedInstance.dataSourcePageBuilder;
            GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"routing-test"];
            config.dataSourceId = @"A";
            config.serverHostMapping = @{@"A": @"https://a.example.com/base", @"B": @"https://b.example.com"};
            config.useProtobuf = NO;
            config.dataCollectionEnabled = YES;
            GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
            GrowingConfigurationManager.sharedInstance.routingSequence = 0;
            GrowingEventManager.sharedInstance.dataSourcePageBuilder = nil;
            [GrowingSession startSession];
            [RoutingNetworkStub.sharedInstance.requests removeAllObjects];
        }
                  waitUntilDone:YES];
    [GrowingEventManager.sharedInstance configManager];
    [MockEventQueue.sharedQueue cleanQueue];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
}
- (void)tearDown {
    if (self.pageWindow) {
        self.pageWindow.hidden = YES;
        [GrowingPageManager.sharedInstance setValue:self.savedVisiblePages forKey:@"visiblePages"];
    }
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [GrowingEventManager.sharedInstance flushDB];
            GrowingConfigurationManager.sharedInstance.trackConfiguration = self.savedConfiguration;
            GrowingConfigurationManager.sharedInstance.routingSequence = self.savedSequence;
            GrowingEventManager.sharedInstance.dataSourcePageBuilder = self.savedPageBuilder;
            if (self.pageWindow) {
                [GrowingPageManager.sharedInstance setValue:self.savedPagePath forKey:@"lastPagePath"];
                [GrowingPageManager.sharedInstance setValue:self.savedPageTimestamp forKey:@"lastPageTimestamp"];
            }
            GrowingConfigurationManager.sharedInstance.committedContext =
                GrowingConfigurationManager.sharedInstance.eventContext;
        }
                  waitUntilDone:YES];
    NSMutableDictionary *instances = [GrowingServiceManager.sharedInstance valueForKey:@"allServiceInstanceDict"];
    if (self.savedNetworkInstance) {
        instances[NSStringFromProtocol(@protocol(GrowingEventNetworkService))] = self.savedNetworkInstance;
    } else {
        [instances removeObjectForKey:NSStringFromProtocol(@protocol(GrowingEventNetworkService))];
    }
    if (self.savedNetworkClass) {
        [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventNetworkService)
                                                    implClass:self.savedNetworkClass];
    }
}
- (void)testMappingValidationAndRequestSnapshot {
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    XCTAssertEqualObjects([GrowingConfigurationManager normalizedServerHost:@"HTTPS://A.EXAMPLE.COM:443/base/"],
                          @"https://a.example.com/base");
    XCTAssertNil([GrowingConfigurationManager normalizedServerHost:@"file:///tmp/events"]);
    XCTAssertNil([GrowingConfigurationManager normalizedServerHost:@"https://example.com/?query=1"]);
    XCTAssertNil([GrowingConfigurationManager normalizedServerHost:@"https://example.com:99999"]);
    GrowingEventRequest *request =
        [[GrowingEventRequest alloc] initWithEvents:[@"[]" dataUsingEncoding:NSUTF8StringEncoding]
                                         serverHost:config.serverHostMapping[@"A"]
                                          accountId:config.accountId];
    config.dataCollectionServerHost = @"https://b.example.com";
    config.dataSourceId = @"B";
    XCTAssertEqualObjects(request.absoluteURL.host, @"a.example.com");
    XCTAssertEqualObjects(request.absoluteURL.path, @"/base/v3/projects/routing-test/collect");
    config.serverHostMapping = @{@"A": @"https://a.example.com"};
    XCTAssertNil([GrowingConfigurationManager validatedMapping:config error:nil]);
}
- (void)testOrderedSwitchAndLateTask {
    __block NSDictionary *oldContext;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            oldContext = GrowingConfigurationManager.sharedInstance.eventContext;
        }
                  waitUntilDone:YES];
    XCTestExpectation *done = [self expectationWithDescription:@"ordered switches"];
    done.expectedFulfillmentCount = 2;
    NSMutableArray *callbacks = [NSMutableArray array];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"B"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    XCTAssertTrue(NSThread.isMainThread);
                                                    [callbacks addObject:@"B"];
                                                    [done fulfill];
                                                }];
    [GrowingEventManager.sharedInstance postEventBuilder:GrowingCustomEvent.builder.setEventName(@"afterB")];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"A"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [callbacks addObject:@"A"];
                                                    [done fulfill];
                                                }];
    GrowingBaseBuilder *late = GrowingCustomEvent.builder.setEventName(@"lateA");
    late.eventContext = oldContext;
    [GrowingEventManager.sharedInstance postEventBuilder:late];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqualObjects(callbacks, (@[@"B", @"A"]));
    NSArray<GrowingBaseEvent *> *visits = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(visits.count, 2);
    XCTAssertNotEqualObjects(visits[0].sessionId, visits[1].sessionId);
    NSArray<GrowingBaseEvent *> *customs = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    XCTAssertEqual(customs.count, 2);
    XCTAssertEqualObjects(customs[0].dataSourceId, @"B");
    XCTAssertEqualObjects(customs[0].sessionId, visits[0].sessionId);
    XCTAssertEqualObjects(customs[1].dataSourceId, @"A");
    XCTAssertEqualObjects(customs[1].sessionId, oldContext[@"sessionId"]);
}
- (void)testIdempotenceConflictAndCollectionDisabled {
    NSString *session = GrowingSession.currentSession.sessionId;
    XCTestExpectation *done = [self expectationWithDescription:@"validation"];
    done.expectedFulfillmentCount = 4;
    [GrowingEventManager.sharedInstance updateDataSourceId:nil
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNotNil(error);
                                                    [done fulfill];
                                                }];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"A"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [done fulfill];
                                                }];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"A"
                                  dataCollectionServerHost:@"https://different.example.com"
                                                completion:^(NSError *error) {
                                                    XCTAssertNotNil(error);
                                                    [done fulfill];
                                                }];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects(session, GrowingSession.currentSession.sessionId);
        GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled = NO;
    }];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"B"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [done fulfill];
                                                }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 0);
    XCTAssertFalse(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled);
    XCTAssertNotEqualObjects(session, GrowingSession.currentSession.sessionId);
}
- (void)testRuntimeRegistrationAndFrozenBatchDestination {
    XCTestExpectation *done = [self expectationWithDescription:@"registration"];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"C"
                                  dataCollectionServerHost:@"https://c.example.com/api/"
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [done fulfill];
                                                }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.serverHostMapping[@"C"],
                          @"https://c.example.com/api");
    [GrowingEventManager.sharedInstance sendAllChannelEvents];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    XCTAssertGreaterThan(RoutingNetworkStub.sharedInstance.requests.count, 0);
    for (id<GrowingRequestProtocol> request in RoutingNetworkStub.sharedInstance.requests) {
        NSArray *events = [NSJSONSerialization JSONObjectWithData:request.events options:0 error:nil];
        for (NSDictionary *event in events) {
            NSString *source = event[@"dataSourceId"];
            NSString *host = [NSURL URLWithString:GrowingConfigurationManager.sharedInstance.trackConfiguration
                                                      .serverHostMapping[source]]
                                 .host;
            XCTAssertEqualObjects(request.absoluteURL.host, host);
        }
    }
}
- (GrowingPage *)prepareCurrentPage {
    GrowingPageManager *pages = GrowingPageManager.sharedInstance;
    [pages start];
    if (self.savedPageBuilder) GrowingEventManager.sharedInstance.dataSourcePageBuilder = self.savedPageBuilder;
    XCTAssertNotNil(GrowingEventManager.sharedInstance.dataSourcePageBuilder);
    self.savedVisiblePages = [pages valueForKey:@"visiblePages"];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            self.savedPagePath = [pages valueForKey:@"lastPagePath"];
            self.savedPageTimestamp = [pages valueForKey:@"lastPageTimestamp"];
        }
                  waitUntilDone:YES];

    UIViewController *controller = [UIViewController new];
    controller.growingPageAlias = @"same-page";
    controller.growingPageTitle = @"Routing page";
    controller.growingPageAttributes = @{@"key": @"value"};
    self.pageWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    self.pageWindow.rootViewController = controller;
    [self.pageWindow makeKeyAndVisible];
    [pages setValue:[NSPointerArray weakObjectsPointerArray] forKey:@"visiblePages"];
    [pages viewControllerDidAppear:controller];
    GrowingPage *page = pages.currentPage;
    XCTAssertNotNil(page);
    [page setValue:@123 forKey:@"showTimestamp"];
    [MockEventQueue.sharedQueue cleanQueue];
    return page;
}
- (void)testPageReplayReusesCurrentPageAcrossSwitches {
    GrowingPage *page = [self prepareCurrentPage];
    XCTestExpectation *done = [self expectationWithDescription:@"page replay"];
    done.expectedFulfillmentCount = 3;
    [GrowingEventManager.sharedInstance updateDataSourceId:@"B"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [done fulfill];
                                                }];
    [GrowingEventManager.sharedInstance postEventBuilder:GrowingCustomEvent.builder.setEventName(@"afterB")];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"B"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [done fulfill];
                                                }];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"A"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [done fulfill];
                                                }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    NSArray<GrowingPageEvent *> *events = (id)[MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    NSArray<GrowingBaseEvent *> *visits = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 2);
    XCTAssertEqual(visits.count, 2);
    XCTAssertEqualObjects(events.firstObject.dataSourceId, @"B");
    XCTAssertEqualObjects(events.lastObject.dataSourceId, @"A");
    XCTAssertEqualObjects(events.firstObject.sessionId, visits.firstObject.sessionId);
    XCTAssertEqualObjects(events.lastObject.sessionId, visits.lastObject.sessionId);
    XCTAssertNotEqualObjects(events.firstObject.sessionId, events.lastObject.sessionId);
    for (GrowingPageEvent *event in events) {
        XCTAssertEqualObjects(event.path, @"/same-page");
        XCTAssertEqualObjects(event.title, @"Routing page");
        XCTAssertEqualObjects(event.attributes, (@{@"key": @"value"}));
        XCTAssertGreaterThan(event.timestamp, 123);
    }
    XCTAssertEqual(page.showTimestamp, 123);
    NSArray *all = [MockEventQueue.sharedQueue.allEvent copy];
    GrowingBaseEvent *custom = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom].firstObject;
    XCTAssertEqualObjects(custom.sessionId, events.firstObject.sessionId);
    XCTAssertLessThan([all indexOfObject:visits.firstObject], [all indexOfObject:events.firstObject]);
    XCTAssertLessThan([all indexOfObject:events.firstObject], [all indexOfObject:custom]);

    // Normal page appearances keep their existing PAGE behavior.
    [GrowingPageManager.sharedInstance viewControllerDidAppear:page.carrier];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 3);

    // A page that has left the window must not be replayed.
    self.pageWindow.rootViewController = [UIViewController new];
    XCTestExpectation *hidden = [self expectationWithDescription:@"no visible page"];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"B"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [hidden fulfill];
                                                }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 3);
}
- (void)testPageReplayFromWorkerReadsPageOnMainThread {
    [self prepareCurrentPage];
    GrowingBaseBuilder * (^pageBuilder)(void) = GrowingEventManager.sharedInstance.dataSourcePageBuilder;
    GrowingEventManager.sharedInstance.dataSourcePageBuilder = ^GrowingBaseBuilder * {
        XCTAssertTrue(NSThread.isMainThread);
        return pageBuilder();
    };
    XCTestExpectation *done = [self expectationWithDescription:@"worker switch"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [GrowingEventManager.sharedInstance updateDataSourceId:@"B"
                                      dataCollectionServerHost:nil
                                                    completion:^(NSError *error) {
                                                        XCTAssertNil(error);
                                                        XCTAssertTrue(NSThread.isMainThread);
                                                        [done fulfill];
                                                    }];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    XCTAssertEqualObjects(events.firstObject.dataSourceId, @"B");
    XCTAssertEqualObjects(events.firstObject.sessionId, GrowingSession.currentSession.sessionId);
}

@end
