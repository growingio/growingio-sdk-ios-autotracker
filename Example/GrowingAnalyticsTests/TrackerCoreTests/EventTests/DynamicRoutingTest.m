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
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingAutotrackerCore/Public/GrowingAutotrackConfiguration.h"
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
#import "GrowingWebSocketService.h"
#import "Modules/WebCircle/GrowingWebCircle.h"
#import "Services/Database/FMDB/GrowingFMDB.h"
#import "Services/JSON/GrowingEventJSONDatabase.h"
#import "Services/JSON/GrowingEventJSONPersistence.h"

@interface RoutingWebSocketStub : NSObject <GrowingWebSocketService>
@property (nonatomic, weak) id<GrowingWebSocketDelegate> delegate;
@property (nonatomic, assign) GrowingWebSocketReadyState readyState;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSUInteger closeCount;
@property (nonatomic, strong) NSMutableArray *messages;
@end
@implementation RoutingWebSocketStub
- (instancetype)initWithURLRequest:(NSURLRequest *)request {
    if (self = [super init]) {
        _url = request.URL;
        _messages = [NSMutableArray array];
        _readyState = Growing_WS_OPEN;
    }
    return self;
}
- (void)open {
    self.readyState = Growing_WS_OPEN;
}
- (void)close {
    self.closeCount++;
    self.readyState = Growing_WS_CLOSED;
}
- (void)send:(id)data {
    [self.messages addObject:data];
}
@end

@interface GrowingWebCircle (RoutingTest)
- (BOOL)isRunning;
- (void)sendJson:(id)json;
@end

@interface RoutingNetworkStub : NSObject <GrowingEventNetworkService>
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *pendingResponses;
@property (nonatomic, assign) BOOL holdResponses;
@property (nonatomic, copy) NSString *failedHost;
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
        instance.pendingResponses = [NSMutableArray array];
    });
    return instance;
}
- (void)sendRequest:(id<GrowingRequestProtocol>)request
         completion:(void (^)(NSHTTPURLResponse *, NSData *, NSError *))callback {
    [self.requests addObject:request];
    NSInteger status = [request.absoluteURL.host isEqual:self.failedHost] ? 503 : 200;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.absoluteURL
                                                              statusCode:status
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:nil];
    dispatch_block_t respond = ^{
        if (callback) callback(response, nil, nil);
    };
    if (self.holdResponses) {
        [self.pendingResponses addObject:respond];
    } else {
        respond();
    }
}
@end

@interface GrowingEventManager (RoutingTest)
- (void)sendEventsInstantWithChannel:(GrowingEventChannel *)channel;
@end

@interface GrowingPageManager (RoutingTest)
- (void)viewControllerDidAppear:(UIViewController *)controller;
@end

@interface DynamicRoutingTest : XCTestCase
@property (nonatomic, strong) GrowingTrackConfiguration *savedConfiguration;
@property (nonatomic, strong) GrowingRealAutotracker *autotracker;
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
            GrowingTrackConfiguration *config =
                [GrowingAutotrackConfiguration configurationWithAccountId:@"routing-test"];
            config.dataSourceId = @"A";
            config.serverHostMapping = @{@"A": @"https://a.example.com/base", @"B": @"https://b.example.com"};
            config.useProtobuf = NO;
            config.dataCollectionEnabled = YES;
            GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
            [GrowingSession startSession];
            [RoutingNetworkStub.sharedInstance.requests removeAllObjects];
            [RoutingNetworkStub.sharedInstance.pendingResponses removeAllObjects];
            RoutingNetworkStub.sharedInstance.holdResponses = NO;
            RoutingNetworkStub.sharedInstance.failedHost = nil;
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
            if (self.pageWindow) {
                [GrowingPageManager.sharedInstance setValue:self.savedPagePath forKey:@"lastPagePath"];
                [GrowingPageManager.sharedInstance setValue:self.savedPageTimestamp forKey:@"lastPageTimestamp"];
            }
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
    GrowingTrackConfiguration *input = [config copy];
    input.serverHostMapping = @{@"A": @"HTTPS://A.EXAMPLE.COM:443/base/"};
    XCTAssertEqualObjects([GrowingConfigurationManager validatedMapping:input
                                                                  error:nil][@"A"], @"HTTPS://A.EXAMPLE.COM:443/base/");
    for (NSString *host in @[@"file:///tmp/events", @"https://example.com/?query=1", @"https://example.com:99999"]) {
        input.serverHostMapping = @{@"A": host};
        XCTAssertNil([GrowingConfigurationManager validatedMapping:input error:nil]);
    }
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
- (void)testOrderedSwitchAndDelayedBuilderUseCurrentConfiguration {
    NSString *oldSession = GrowingSession.currentSession.sessionId;
    GrowingBaseBuilder *late =
        GrowingCustomEvent.builder.setEventName(@"delayed").setDataSourceId(@"A").setSessionId(oldSession);
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
    [GrowingEventManager.sharedInstance postEventBuilder:late];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"A"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    [callbacks addObject:@"A"];
                                                    [done fulfill];
                                                }];
    [GrowingEventManager.sharedInstance postEventBuilder:GrowingCustomEvent.builder.setEventName(@"afterA")];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqualObjects(callbacks, (@[@"B", @"A"]));
    NSArray<GrowingBaseEvent *> *visits = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(visits.count, 2);
    XCTAssertNotEqualObjects(visits[0].sessionId, visits[1].sessionId);
    NSArray<GrowingBaseEvent *> *customs = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    XCTAssertEqual(customs.count, 3);
    XCTAssertEqualObjects(customs[0].dataSourceId, @"B");
    XCTAssertEqualObjects(customs[0].sessionId, visits[0].sessionId);
    XCTAssertEqualObjects(customs[1].dataSourceId, @"B");
    XCTAssertEqualObjects(customs[1].sessionId, visits[0].sessionId);
    XCTAssertNotEqualObjects(customs[1].sessionId, oldSession);
    XCTAssertEqualObjects(customs[2].dataSourceId, @"A");
    XCTAssertEqualObjects(customs[2].sessionId, visits[1].sessionId);
}
- (void)testIdempotenceConflictAndCollectionDisabled {
    NSString *session = GrowingSession.currentSession.sessionId;
    XCTestExpectation *done = [self expectationWithDescription:@"validation"];
    done.expectedFulfillmentCount = 5;
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
    [GrowingEventManager.sharedInstance updateDataSourceId:@"A"
                                  dataCollectionServerHost:@"https://a.example.com/base/"
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
                          @"https://c.example.com/api/");
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
- (GrowingEventDatabase *)databaseWithSources:(NSArray<NSString *> *)sources {
    return [self databaseWithSources:sources isProtobuf:NO];
}
- (GrowingEventDatabase *)databaseWithSources:(NSArray<NSString *> *)sources isProtobuf:(BOOL)isProtobuf {
    NSString *path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSString stringWithFormat:@"routing-upload-%@/events.sqlite",
                                                                  NSUUID.UUID.UUIDString]];
    GrowingEventDatabase *db = [GrowingEventDatabase databaseWithPath:path isProtobuf:isProtobuf];
    db.autoFlushCount = NSUIntegerMax;
    for (NSString *source in sources) {
        GrowingBaseEvent *event = GrowingCustomEvent.builder.setEventName(@"cached")
                                      .setDataSourceId(source)
                                      .setSessionId([source stringByAppendingString:@"-session"])
                                      .setSdkVersion(@"4.13.0")
                                      .build;
        NSString *uuid = NSUUID.UUID.UUIDString;
        [db setEvent:[db persistenceEventWithEvent:event uuid:uuid] forKey:uuid];
    }
    XCTAssertTrue([db flush]);
    return db;
}
- (void)completePendingUploads {
    while (RoutingNetworkStub.sharedInstance.pendingResponses.count) {
        dispatch_block_t response = RoutingNetworkStub.sharedInstance.pendingResponses.firstObject;
        [RoutingNetworkStub.sharedInstance.pendingResponses removeObjectAtIndex:0];
        response();
        [GrowingDispatchManager
            dispatchInGrowingThread:^{
            }
                      waitUntilDone:YES];
    }
}
- (void)testInstantUploadUsesOriginalChannelAndKeepsBatchDestination {
    NSMutableArray *sources = [NSMutableArray array];
    for (NSUInteger i = 0; i < 501; i++) [sources addObject:@"A"];
    [sources addObjectsFromArray:@[@"B", @"outside"]];
    GrowingEventDatabase *trackDB = [self databaseWithSources:sources];
    GrowingEventDatabase *autotrackDB = [self databaseWithSources:@[@"B"]];
    GrowingEventChannel *track = [GrowingEventChannel eventChannelWithName:@"Track" eventTypes:nil isRealtimeEvent:YES];
    GrowingEventChannel *autotrack = [GrowingEventChannel eventChannelWithName:@"Autotrack"
                                                                    eventTypes:nil
                                                               isRealtimeEvent:NO];
    track.db = trackDB;
    autotrack.db = autotrackDB;
    GrowingEventManager *manager = [GrowingEventManager new];
    [manager setValue:@[track, autotrack] forKey:@"allEventChannels"];
    RoutingNetworkStub.sharedInstance.holdResponses = YES;
    [manager sendEventsInstantWithChannel:track];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    XCTAssertTrue(track.isUploading);
    XCTAssertFalse(autotrack.isUploading);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    [manager sendEventsInstantWithChannel:track];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId = @"B";
        }
                  waitUntilDone:YES];
    [self completePendingUploads];
    XCTAssertFalse(track.isUploading);
    XCTAssertEqual(trackDB.countOfEvents, 1);
    XCTAssertEqual(autotrackDB.countOfEvents, 1);
    NSUInteger sent = 0;
    for (id<GrowingRequestProtocol> request in RoutingNetworkStub.sharedInstance.requests) {
        NSArray *events = [NSJSONSerialization JSONObjectWithData:request.events options:0 error:nil];
        XCTAssertGreaterThan(events.count, 0);
        XCTAssertLessThanOrEqual(events.count, 500);
        NSString *source = events.firstObject[@"dataSourceId"];
        NSString *host =
            [NSURL
                URLWithString:GrowingConfigurationManager.sharedInstance.trackConfiguration.serverHostMapping[source]]
                .host;
        XCTAssertEqualObjects(request.absoluteURL.host, host);
        for (NSDictionary *event in events) XCTAssertEqualObjects(event[@"dataSourceId"], source);
        sent += events.count;
    }
    XCTAssertEqual(sent, 502);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 3);
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [RoutingNetworkStub.sharedInstance.requests removeAllObjects];
        }
                  waitUntilDone:YES];
    [manager sendAllChannelEvents];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    XCTAssertEqual(autotrackDB.countOfEvents, 0);
    XCTAssertEqual(trackDB.countOfEvents, 1);
}
- (void)testFailedSourceRemainsCachedWhileOtherSourceUploads {
    GrowingEventDatabase *db = [self databaseWithSources:@[@"A", @"B"]];
    GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                  eventTypes:nil
                                                             isRealtimeEvent:YES];
    channel.db = db;
    GrowingEventManager *manager = [GrowingEventManager new];
    [manager setValue:@[channel] forKey:@"allEventChannels"];
    RoutingNetworkStub.sharedInstance.holdResponses = YES;
    RoutingNetworkStub.sharedInstance.failedHost = @"a.example.com";
    [manager sendAllChannelEvents];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    [self completePendingUploads];
    XCTAssertFalse(channel.isUploading);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 2);
    XCTAssertEqual(db.countOfEvents, 1);
    XCTAssertEqual([db getEventsByCount:10 limitSize:100000 policy:~0UL dataSourceId:@"A"].count, 1);
    XCTAssertEqual([db getEventsByCount:10 limitSize:100000 policy:~0UL dataSourceId:@"B"].count, 0);
    RoutingNetworkStub.sharedInstance.failedHost = nil;
    [manager sendAllChannelEvents];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 3);
    XCTAssertEqualObjects([RoutingNetworkStub.sharedInstance.requests.lastObject absoluteURL].host, @"a.example.com");
    XCTAssertEqual(db.countOfEvents, 0);
}
- (void)testSizeLimitedBatchesContinueUploading {
    GrowingEventDatabase *db = [self databaseWithSources:@[]];
    NSString *payload = [@"x" stringByPaddingToLength:700000 withString:@"x" startingAtIndex:0];
    for (NSUInteger i = 0; i < 3; i++) {
        GrowingBaseEvent *event = GrowingCustomEvent.builder.setEventName(@"large")
                                      .setDataSourceId(@"A")
                                      .setSdkVersion(@"4.13.0")
                                      .setAttributes(@{@"payload": payload})
                                      .build;
        NSString *uuid = NSUUID.UUID.UUIDString;
        [db setEvent:[db persistenceEventWithEvent:event uuid:uuid] forKey:uuid];
    }
    XCTAssertTrue([db flush]);
    GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                  eventTypes:nil
                                                             isRealtimeEvent:YES];
    channel.db = db;
    GrowingEventManager *manager = [GrowingEventManager new];
    [manager setValue:@[channel] forKey:@"allEventChannels"];
    RoutingNetworkStub.sharedInstance.holdResponses = YES;
    [manager sendAllChannelEvents];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 2);
    XCTAssertEqual(db.countOfEvents, 0);
    for (id<GrowingRequestProtocol> request in RoutingNetworkStub.sharedInstance.requests) {
        XCTAssertLessThanOrEqual(request.events.length, 2 * 1024 * 1024);
        XCTAssertEqualObjects(request.absoluteURL.host, @"a.example.com");
    }
}
- (void)testProtobufHistoryRoutesBySourceWithCurrentJSONEncoding {
    GrowingEventDatabase *db = [self databaseWithSources:@[@"A", @"B"] isProtobuf:YES];
    GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track-Protobuf"
                                                                  eventTypes:nil
                                                             isRealtimeEvent:YES];
    channel.persistenceType = GrowingEventPersistenceTypeProtobuf;
    channel.db = db;
    GrowingEventManager *manager = [GrowingEventManager new];
    [manager setValue:@[channel] forKey:@"allEventChannels"];
    RoutingNetworkStub.sharedInstance.holdResponses = YES;
    [manager sendAllChannelEvents];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 2);
    for (id<GrowingRequestProtocol> request in RoutingNetworkStub.sharedInstance.requests) {
        NSArray *events = [NSJSONSerialization JSONObjectWithData:request.events options:0 error:nil];
        XCTAssertEqual(events.count, 1);
        NSString *source = events.firstObject[@"dataSourceId"];
        NSString *host =
            [NSURL
                URLWithString:GrowingConfigurationManager.sharedInstance.trackConfiguration.serverHostMapping[source]]
                .host;
        XCTAssertEqualObjects(request.absoluteURL.host, host);
    }
    XCTAssertEqual(db.countOfEvents, 0);
}
- (void)testDataSourceSwitchKeepsWebCircleConnectedAndSending {
    GrowingWebCircle *circle = [GrowingWebCircle new];
    RoutingWebSocketStub *socket = [[RoutingWebSocketStub alloc]
        initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"wss://circle.example.com/session"]]];
    circle.webSocket = socket;
    socket.delegate = (id<GrowingWebSocketDelegate>)circle;
    [circle setValue:@YES forKey:@"isReady"];
    XCTestExpectation *done = [self expectationWithDescription:@"circle survives source switch"];
    [GrowingEventManager.sharedInstance updateDataSourceId:@"B"
                                  dataCollectionServerHost:nil
                                                completion:^(NSError *error) {
                                                    XCTAssertNil(error);
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [done fulfill];
                                                    });
                                                }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId, @"B");
    XCTAssertEqual(circle.webSocket, socket);
    XCTAssertEqual(socket.delegate, circle);
    XCTAssertTrue(circle.isRunning);
    XCTAssertEqual(socket.closeCount, 0);
    [circle sendJson:@{@"msgType": @"refreshScreenshot", @"screenshot": @"existing-circle-session"}];
    XCTAssertEqual(socket.messages.count, 1);
    NSDictionary *message =
        [NSJSONSerialization JSONObjectWithData:[socket.messages.lastObject dataUsingEncoding:NSUTF8StringEncoding]
                                        options:0
                                          error:nil];
    XCTAssertEqualObjects(message[@"msgType"], @"refreshScreenshot");
}
- (GrowingPage *)prepareCurrentPage {
    GrowingPageManager *pages = GrowingPageManager.sharedInstance;
    [pages start];
    self.autotracker = [GrowingRealAutotracker new];
    [self.autotracker setValue:GrowingConfigurationManager.sharedInstance.trackConfiguration forKey:@"configuration"];
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
    [self.autotracker updateDataSourceId:@"B"
                dataCollectionServerHost:nil
                              completion:^(NSError *error) {
                                  XCTAssertNil(error);
                                  [done fulfill];
                              }];
    [GrowingEventManager.sharedInstance postEventBuilder:GrowingCustomEvent.builder.setEventName(@"afterB")];
    [self.autotracker updateDataSourceId:@"B"
                dataCollectionServerHost:nil
                              completion:^(NSError *error) {
                                  XCTAssertNil(error);
                                  [done fulfill];
                              }];
    [self.autotracker updateDataSourceId:@"A"
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
    [self.autotracker updateDataSourceId:@"B"
                dataCollectionServerHost:nil
                              completion:^(NSError *error) {
                                  XCTAssertNil(error);
                                  [hidden fulfill];
                              }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 3);
}
- (void)testPageReplayFromWorker {
    [self prepareCurrentPage];
    XCTestExpectation *done = [self expectationWithDescription:@"worker switch"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self.autotracker
                  updateDataSourceId:@"B"
            dataCollectionServerHost:nil
                          completion:^(NSError *error) {
                              XCTAssertNil(error);
                              XCTAssertTrue(NSThread.isMainThread);
                              [GrowingEventManager.sharedInstance
                                  postEventBuilder:GrowingCustomEvent.builder.setEventName(@"workerAfterSwitch")];
                              [done fulfill];
                          }];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    XCTAssertEqualObjects(events.firstObject.dataSourceId, @"B");
    XCTAssertEqualObjects(events.firstObject.sessionId, GrowingSession.currentSession.sessionId);
    GrowingBaseEvent *custom = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom].firstObject;
    XCTAssertEqualObjects(custom.dataSourceId, @"B");
    XCTAssertEqualObjects(custom.sessionId, events.firstObject.sessionId);
}
- (void)testPageReplayAfterReturningToRetainedPage {
    GrowingPage *page = [self prepareCurrentPage];
    UIViewController *first = page.carrier;
    UIViewController *second = [UIViewController new];
    second.growingPageAlias = @"second-page";
    self.pageWindow.rootViewController = second;
    [GrowingPageManager.sharedInstance viewControllerDidAppear:second];
    self.pageWindow.rootViewController = first;
    [GrowingPageManager.sharedInstance viewControllerDidAppear:first];
    [MockEventQueue.sharedQueue cleanQueue];

    XCTestExpectation *done = [self expectationWithDescription:@"returning page replay"];
    [self.autotracker updateDataSourceId:@"B"
                dataCollectionServerHost:nil
                              completion:^(NSError *error) {
                                  XCTAssertNil(error);
                                  [done fulfill];
                              }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    NSArray<GrowingPageEvent *> *events = (id)[MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    XCTAssertEqualObjects(events.firstObject.path, @"/same-page");
    XCTAssertEqualObjects(events.firstObject.dataSourceId, @"B");
}
- (void)testTrackerSwitchDoesNotReplayPage {
    [self prepareCurrentPage];
    GrowingRealTracker *tracker = [GrowingRealTracker new];
    XCTestExpectation *done = [self expectationWithDescription:@"switch without page replay"];
    [tracker updateDataSourceId:@"B"
        dataCollectionServerHost:nil
                      completion:^(NSError *error) {
                          XCTAssertNil(error);
                          ((GrowingAutotrackConfiguration *)
                               GrowingConfigurationManager.sharedInstance.trackConfiguration)
                              .autotrackEnabled = NO;
                          [self.autotracker updateDataSourceId:@"A"
                                      dataCollectionServerHost:nil
                                                    completion:^(NSError *error) {
                                                        XCTAssertNil(error);
                                                        [done fulfill];
                                                    }];
                      }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 0);
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 2);
}
- (void)testRejectedAutotrackerSwitchDoesNotReplayPage {
    [self prepareCurrentPage];
    NSString *session = GrowingSession.currentSession.sessionId;
    XCTestExpectation *done = [self expectationWithDescription:@"rejected autotracker switches"];
    done.expectedFulfillmentCount = 2;
    [self.autotracker updateDataSourceId:@"A"
                dataCollectionServerHost:@"https://different.example.com"
                              completion:^(NSError *error) {
                                  XCTAssertNotNil(error);
                                  [done fulfill];
                              }];
    [self.autotracker updateDataSourceId:@"B"
                dataCollectionServerHost:@"file:///tmp/events"
                              completion:^(NSError *error) {
                                  XCTAssertNotNil(error);
                                  [done fulfill];
                              }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqualObjects(GrowingSession.currentSession.sessionId, session);
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 0);
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 0);
}

@end
