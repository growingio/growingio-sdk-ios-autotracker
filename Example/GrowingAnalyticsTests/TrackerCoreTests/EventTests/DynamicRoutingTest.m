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

#import "GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingEventNetworkService.h"
#import "GrowingServiceManager.h"
#import "GrowingTracker.h"
#import "GrowingTrackerCore/Database/GrowingEventDatabase.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Network/Request/GrowingEventRequest.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingWebSocketService.h"
#import "MockEventQueue.h"
#import "Modules/WebCircle/GrowingWebCircle.h"

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
@property (nonatomic, strong) NSMutableArray<id<GrowingRequestProtocol>> *requests;
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

#pragma mark - Lifecycle

- (void)setUp {
    [GrowingPageManager.sharedInstance start];
    [self installNetworkStub];
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
    [self waitForEventThread];
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
    [self restoreNetworkService];
}

#pragma mark - Configuration and Switching

- (void)testMappingValidationAndRequestSnapshot {
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    GrowingTrackConfiguration *input = [config copy];
    input.serverHostMapping = @{@"A": @"HTTPS://A.EXAMPLE.COM:443/base/"};
    XCTAssertEqualObjects([GrowingConfigurationManager validatedServerHostMappingForConfiguration:input
                                                                                            error:nil][@"A"],
                          @"HTTPS://A.EXAMPLE.COM:443/base/");
    for (id host in @[@"", @42, NSNull.null]) {
        input.serverHostMapping = @{@"A": host};
        XCTAssertNil([GrowingConfigurationManager validatedServerHostMappingForConfiguration:input error:nil]);
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
    XCTAssertNil([GrowingConfigurationManager validatedServerHostMappingForConfiguration:config error:nil]);
}

- (void)testServerHostMappingValidatesCollectionURLs {
    GrowingTrackConfiguration *input = [GrowingConfigurationManager.sharedInstance.trackConfiguration copy];
    input.dataSourceId = @"A";
    for (NSString *host in [self validCollectionURLs]) {
        input.serverHostMapping = @{@"A": host};
        XCTAssertEqualObjects([GrowingConfigurationManager validatedServerHostMappingForConfiguration:input
                                                                                                error:nil][@"A"], host);
    }
    for (NSString *host in [self invalidCollectionURLs]) {
        // 非当前数据源的地址同样要校验
        input.serverHostMapping = @{@"A": @"https://a.example.com", @"B": host};
        NSError *error = nil;
        XCTAssertNil([GrowingConfigurationManager validatedServerHostMappingForConfiguration:input error:&error],
                     @"%@",
                     host);
        XCTAssertEqual(error.code, GrowingRoutingErrorInvalidServerHostMapping);
    }
}
- (void)testRuntimeRegistrationValidatesCollectionURLs {
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            GrowingConfigurationManager *manager = GrowingConfigurationManager.sharedInstance;
            for (NSString *host in [self invalidCollectionURLs]) {
                NSError *error = nil;
                XCTAssertFalse([manager switchToDataSourceId:@"C" dataCollectionServerHost:host error:&error],
                               @"%@",
                               host);
                XCTAssertEqual(error.code, GrowingRoutingErrorInvalidServerHost);
                XCTAssertEqualObjects(manager.trackConfiguration.dataSourceId, @"A");
                XCTAssertNil([manager serverHostForDataSourceId:@"C"]);
            }
            for (NSString *host in [self validCollectionURLs]) {
                NSString *source = NSUUID.UUID.UUIDString;
                XCTAssertTrue([manager switchToDataSourceId:source dataCollectionServerHost:host error:nil],
                              @"%@",
                              host);
                XCTAssertEqualObjects(manager.trackConfiguration.dataSourceId, source);
                XCTAssertEqualObjects(manager.trackConfiguration.dataCollectionServerHost, host);
            }
        }
                  waitUntilDone:YES];
}
- (void)testLegacyServerHostKeepsExistingURLHandling {
    GrowingTrackConfiguration *input = [GrowingConfigurationManager.sharedInstance.trackConfiguration copy];
    input.serverHostMapping = nil;
    input.dataSourceId = @"A";
    input.dataCollectionServerHost = @"example.com/base";
    // 只配置 dataCollectionServerHost 的老用户不校验地址格式，避免升级后初始化抛异常
    XCTAssertEqualObjects([GrowingConfigurationManager validatedServerHostMappingForConfiguration:input
                                                                                            error:nil][@"A"],
                          @"example.com/base");
}

- (void)testRoutingFieldsAreReadConsistentlyDuringConcurrentSwitches {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"routing-test"];
    NSMutableDictionary<NSString *, NSString *> *mapping = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < 8; i++) {
        mapping[[NSString stringWithFormat:@"S%lu", (unsigned long)i]] =
            [NSString stringWithFormat:@"https://s%lu.example.com", (unsigned long)i];
    }
    [config growing_updateDataSourceId:@"S0" serverHostMapping:mapping];

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        for (NSUInteger i = 0; i < 20000; i++) {
            NSString *source = [NSString stringWithFormat:@"S%lu", (unsigned long)(i % 8)];
            [config growing_updateDataSourceId:source serverHostMapping:mapping];
        }
    });

    __block NSUInteger inconsistent = 0;
    dispatch_apply(4, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        // 写线程结束前持续并发读取
        while (dispatch_group_wait(group, DISPATCH_TIME_NOW) != 0) {
            // copy 在同一把锁内读取三个字段，得到的快照必须一致
            GrowingTrackConfiguration *snapshot = [config copy];
            if (![snapshot.dataCollectionServerHost
                    isEqualToString:snapshot.serverHostMapping[snapshot.dataSourceId]]) {
                @synchronized(self) {
                    inconsistent++;
                }
            }
            // 单独读取各字段也不能崩溃
            XCTAssertNotNil(config.dataSourceId);
            XCTAssertNotNil(config.dataCollectionServerHost);
            XCTAssertEqual(config.serverHostMapping.count, 8);
        }
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    XCTAssertEqual(inconsistent, 0);
    XCTAssertEqualObjects(config.dataSourceId, @"S7");
    XCTAssertEqualObjects(config.dataCollectionServerHost, @"https://s7.example.com");
}
- (void)testOrderedSwitchAndDelayedBuilderUseCurrentConfiguration {
    NSString *oldSession = GrowingSession.currentSession.sessionId;
    GrowingBaseBuilder *late =
        GrowingCustomEvent.builder.setEventName(@"delayed").setDataSourceId(@"A").setSessionId(oldSession);
    [GrowingEventManager.sharedInstance switchToDataSourceId:@"B"];
    [GrowingEventManager.sharedInstance postEventBuilder:GrowingCustomEvent.builder.setEventName(@"afterB")];
    [GrowingEventManager.sharedInstance postEventBuilder:late];
    [GrowingEventManager.sharedInstance switchToDataSourceId:@"A"];
    [GrowingEventManager.sharedInstance postEventBuilder:GrowingCustomEvent.builder.setEventName(@"afterA")];
    [self waitForEventThread];
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
    NSString *host = GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionServerHost;
    [GrowingEventManager.sharedInstance switchToDataSourceId:nil];
    [GrowingEventManager.sharedInstance switchToDataSourceId:@"A"];
    [GrowingEventManager.sharedInstance switchToDataSourceId:@"B"
                                    dataCollectionServerHost:@"https://different.example.com"];
    [GrowingEventManager.sharedInstance switchToDataSourceId:@"B" dataCollectionServerHost:@"https://b.example.com/"];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects(session, GrowingSession.currentSession.sessionId);
        XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId, @"A");
        XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionServerHost,
                              host);
        XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.serverHostMapping[@"B"],
                              @"https://b.example.com");
        GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled = NO;
    }];
    [GrowingEventManager.sharedInstance switchToDataSourceId:@"B"];
    [self waitForEventThread];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 0);
    XCTAssertFalse(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled);
    XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId, @"B");
    XCTAssertNotEqualObjects(session, GrowingSession.currentSession.sessionId);
}

- (void)testRuntimeRegistrationAndFrozenBatchDestination {
    GrowingTracker *tracker = [[GrowingTracker alloc] initWithTarget:[GrowingRealTracker new]];
    [tracker switchToDataSourceId:@"C"];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
            XCTAssertEqualObjects(config.dataSourceId, @"A");
            XCTAssertNil(config.serverHostMapping[@"C"]);
        }
                  waitUntilDone:YES];
    [tracker switchToDataSourceId:@"C" dataCollectionServerHost:@"https://c.example.com/api/"];
    [tracker switchToDataSourceId:@"A"];
    [tracker switchToDataSourceId:@"C"];
    [self waitForEventThread];
    XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.serverHostMapping[@"C"],
                          @"https://c.example.com/api/");
    XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId, @"C");
    [GrowingEventManager.sharedInstance sendAllChannelEvents];
    [self waitForEventThread];
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

#pragma mark - Uploads

- (void)testInstantUploadUsesOriginalChannelAndKeepsBatchDestination {
    GrowingEventDatabase *trackDB = [self databaseWithSources:@[@"A", @"B", @"A", @"outside"]];
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
    [self waitForEventThread];
    XCTAssertTrue(track.isUploading);
    XCTAssertFalse(autotrack.isUploading);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    [manager sendEventsInstantWithChannel:track];
    [self waitForEventThread];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId = @"B";
        }
                  waitUntilDone:YES];
    dispatch_block_t firstResponse = RoutingNetworkStub.sharedInstance.pendingResponses.firstObject;
    [RoutingNetworkStub.sharedInstance.pendingResponses removeObjectAtIndex:0];
    firstResponse();
    [self waitForEventThread];
    XCTAssertTrue(track.isUploading);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 2);
    // "outside" 查不到上报地址，已被挂起，不计入待发送数量
    XCTAssertEqual(trackDB.countOfEvents, 1);
    [manager sendEventsInstantWithChannel:track];
    [self waitForEventThread];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 2);
    [self completePendingUploads];
    XCTAssertFalse(track.isUploading);
    XCTAssertEqual(trackDB.countOfEvents, 0);
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
    XCTAssertEqual(sent, 3);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 2);
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [RoutingNetworkStub.sharedInstance.requests removeAllObjects];
        }
                  waitUntilDone:YES];
    [manager sendAllChannelEvents];
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    XCTAssertEqual(autotrackDB.countOfEvents, 0);
    XCTAssertEqual(trackDB.countOfEvents, 0);
    // 挂起的事件仍保留在数据库中
    XCTAssertTrue([trackDB resumeAllSuspendedEvents]);
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
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertFalse(channel.isUploading);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 2);
    XCTAssertEqual(db.countOfEvents, 1);
    NSArray *remaining = [db getEventsByCount:10 limitSize:100000 policy:~0UL];
    XCTAssertEqual(remaining.count, 1);
    XCTAssertEqualObjects([remaining.firstObject toJSONObject][@"dataSourceId"], @"A");
    RoutingNetworkStub.sharedInstance.failedHost = nil;
    [manager sendAllChannelEvents];
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 3);
    XCTAssertEqualObjects([RoutingNetworkStub.sharedInstance.requests.lastObject absoluteURL].host, @"a.example.com");
    XCTAssertEqual(db.countOfEvents, 0);
}

- (void)testBatchLimitAndFailedSourceUseOriginalUploadTriggers {
    NSMutableArray *sources = [NSMutableArray array];
    for (NSUInteger i = 0; i < 1000; i++) [sources addObject:@"A"];
    [sources addObject:@"B"];
    GrowingEventDatabase *db = [self databaseWithSources:sources];
    GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                  eventTypes:nil
                                                             isRealtimeEvent:YES];
    channel.db = db;
    GrowingEventManager *manager = [GrowingEventManager new];
    [manager setValue:@[channel] forKey:@"allEventChannels"];
    RoutingNetworkStub.sharedInstance.holdResponses = YES;
    RoutingNetworkStub.sharedInstance.failedHost = @"a.example.com";
    [manager sendAllChannelEvents];
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertFalse(channel.isUploading);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    XCTAssertEqual(db.countOfEvents, 1001);

    RoutingNetworkStub.sharedInstance.failedHost = nil;
    [manager sendAllChannelEvents];
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 3);
    XCTAssertEqual(db.countOfEvents, 1);
    for (id<GrowingRequestProtocol> request in RoutingNetworkStub.sharedInstance.requests) {
        NSArray *events = [NSJSONSerialization JSONObjectWithData:request.events options:0 error:nil];
        XCTAssertEqual(events.count, 500);
        XCTAssertEqualObjects(request.absoluteURL.host, @"a.example.com");
    }

    [manager sendAllChannelEvents];
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 4);
    XCTAssertEqualObjects([RoutingNetworkStub.sharedInstance.requests.lastObject absoluteURL].host, @"b.example.com");
    XCTAssertEqual(db.countOfEvents, 0);
}

- (void)testSizeLimitedBatchWaitsForNextUploadTrigger {
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
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertFalse(channel.isUploading);
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    XCTAssertEqual(db.countOfEvents, 1);
    [manager sendAllChannelEvents];
    [self waitForEventThread];
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
    [self waitForEventThread];
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

- (void)testPersistenceProvidesDataSourceId {
    for (NSNumber *isProtobuf in @[@NO, @YES]) {
        GrowingEventDatabase *db = [self databaseWithSources:@[@"A", @""] isProtobuf:isProtobuf.boolValue];
        NSArray<id<GrowingEventPersistenceProtocol>> *events = [db getEventsByCount:10 limitSize:100000 policy:~0UL];
        XCTAssertEqual(events.count, 2);
        // 内置存储都直接提供该字段，分组时不必转换整条事件
        XCTAssertTrue([(id)events[0] respondsToSelector:@selector(dataSourceId)]);
        XCTAssertEqualObjects(events[0].dataSourceId, @"A");
        XCTAssertEqualObjects(events[0].dataSourceId, [events[0] toJSONObject][@"dataSourceId"]);
        XCTAssertNil(events[1].dataSourceId);
    }
}
- (void)testUnroutableEventsAreSuspendedAndDoNotBlockUpload {
    for (NSNumber *isProtobuf in @[@NO, @YES]) {
        [GrowingDispatchManager
            dispatchInGrowingThread:^{
                [RoutingNetworkStub.sharedInstance.requests removeAllObjects];
            }
                      waitUntilDone:YES];
        // 一整批（500 条）都查不到上报地址，排在可正常发送的事件前面
        NSMutableArray *sources = [NSMutableArray array];
        for (NSUInteger i = 0; i < 500; i++) [sources addObject:@"outside"];
        [sources addObject:@"A"];
        GrowingEventDatabase *db = [self databaseWithSources:sources isProtobuf:isProtobuf.boolValue];
        GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                      eventTypes:nil
                                                                 isRealtimeEvent:YES];
        channel.persistenceType =
            isProtobuf.boolValue ? GrowingEventPersistenceTypeProtobuf : GrowingEventPersistenceTypeJSON;
        channel.db = db;
        GrowingEventManager *manager = [GrowingEventManager new];
        [manager setValue:@[channel] forKey:@"allEventChannels"];
        RoutingNetworkStub.sharedInstance.holdResponses = YES;

        // 第一次上传：整批被挂起，没有请求
        [manager sendAllChannelEvents];
        [self waitForEventThread];
        [self completePendingUploads];
        XCTAssertFalse(channel.isUploading);
        XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 0);
        XCTAssertEqual(db.countOfEvents, 1);
        XCTAssertEqual([db getEventsByCount:1000 limitSize:100000000 policy:~0UL].count, 1);

        // 第二次上传：挂起的事件不再占用名额，正常事件被发送
        [manager sendAllChannelEvents];
        [self waitForEventThread];
        [self completePendingUploads];
        XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
        XCTAssertEqualObjects([RoutingNetworkStub.sharedInstance.requests.lastObject absoluteURL].host,
                              @"a.example.com");
        XCTAssertEqual(db.countOfEvents, 0);

        // 挂起的事件没有被删除，恢复后数量还原
        XCTAssertTrue([db resumeAllSuspendedEvents]);
        XCTAssertEqual(db.countOfEvents, 500);
    }
}

- (void)testSuspendIsIdempotentAndResumeRestoresPolicy {
    GrowingEventDatabase *db = [self databaseWithSources:@[@"A", @"A"]];
    NSArray<id<GrowingEventPersistenceProtocol>> *events = [db getEventsByCount:10 limitSize:100000 policy:~0UL];
    XCTAssertEqual(events.count, 2);
    GrowingEventSendPolicy policy = events.firstObject.policy;
    NSArray *keys = @[events.firstObject.eventUUID];
    XCTAssertTrue([db suspendEventsForKeys:keys]);
    XCTAssertTrue([db suspendEventsForKeys:keys]);
    XCTAssertEqual(db.countOfEvents, 1);
    XCTAssertEqual([db getEventsByCount:10 limitSize:100000 policy:~0UL].count, 1);
    XCTAssertTrue([db resumeAllSuspendedEvents]);
    XCTAssertTrue([db resumeAllSuspendedEvents]);
    NSArray<id<GrowingEventPersistenceProtocol>> *restored = [db getEventsByCount:10 limitSize:100000 policy:~0UL];
    XCTAssertEqual(restored.count, 2);
    for (id<GrowingEventPersistenceProtocol> event in restored) XCTAssertEqual(event.policy, policy);
}

- (void)testSuspendedEventsResumeAfterRegistration {
    GrowingEventDatabase *db = [self databaseWithSources:@[@"D"]];
    GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                  eventTypes:nil
                                                             isRealtimeEvent:YES];
    channel.db = db;
    GrowingEventManager *manager = [GrowingEventManager new];
    [manager setValue:@[channel] forKey:@"allEventChannels"];
    RoutingNetworkStub.sharedInstance.holdResponses = YES;
    [manager sendAllChannelEvents];
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 0);
    XCTAssertEqual(db.countOfEvents, 0);

    // 切换到已注册的数据源不会恢复
    [manager switchToDataSourceId:@"B"];
    [self waitForEventThread];
    XCTAssertEqual(db.countOfEvents, 0);

    // 注册新数据源后恢复，并发送到新注册的地址
    [manager switchToDataSourceId:@"D" dataCollectionServerHost:@"https://d.example.com"];
    [self waitForEventThread];
    XCTAssertEqual(db.countOfEvents, 1);
    // 切换产生的 VISIT 由全局通道上传，先完成这些请求，再单独统计测试通道的缓存上传。
    [self completePendingUploads];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [RoutingNetworkStub.sharedInstance.requests removeAllObjects];
        }
                  waitUntilDone:YES];
    [manager sendAllChannelEvents];
    [self waitForEventThread];
    [self completePendingUploads];
    XCTAssertEqual(RoutingNetworkStub.sharedInstance.requests.count, 1);
    XCTAssertEqualObjects([RoutingNetworkStub.sharedInstance.requests.lastObject absoluteURL].host, @"d.example.com");
    XCTAssertEqual(db.countOfEvents, 0);
}

#pragma mark - Module Compatibility

- (void)testDataSourceSwitchKeepsWebCircleConnectedAndSending {
    GrowingWebCircle *circle = [GrowingWebCircle new];
    RoutingWebSocketStub *socket = [[RoutingWebSocketStub alloc]
        initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"wss://circle.example.com/session"]]];
    circle.webSocket = socket;
    socket.delegate = (id<GrowingWebSocketDelegate>)circle;
    [circle setValue:@YES forKey:@"isReady"];
    [GrowingEventManager.sharedInstance switchToDataSourceId:@"B"];
    [self waitForEventThread];
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

#pragma mark - Page Replay

- (void)testPageReplayReusesCurrentPageAcrossSwitches {
    GrowingPage *page = [self prepareCurrentPage];
    [self.autotracker switchToDataSourceId:@"B"];
    XCTAssertEqual(page.showTimestamp, 123);
    [self.autotracker trackCustomEvent:@"afterB"];
    [self waitForEventThread];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 0);
    NSArray<GrowingBaseEvent *> *customs = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    XCTAssertEqual(customs.count, 1);
    XCTAssertEqualObjects(customs.firstObject.dataSourceId, @"B");
    [self waitForRoutingWork];
    long long firstShowTimestamp = page.showTimestamp;
    XCTAssertGreaterThan(firstShowTimestamp, 123);
    [self.autotracker switchToDataSourceId:@"B" dataCollectionServerHost:@"https://b.example.com"];
    [self waitForRoutingWork];
    XCTAssertEqual(page.showTimestamp, firstShowTimestamp);
    [self.autotracker switchToDataSourceId:@"A"];
    [self waitForRoutingWork];
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
    XCTAssertEqual(page.showTimestamp, events.lastObject.timestamp);
    GrowingBaseEvent *custom = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom].firstObject;
    XCTAssertEqualObjects(custom.sessionId, events.firstObject.sessionId);

    // Normal page appearances keep their existing PAGE behavior.
    [GrowingPageManager.sharedInstance viewControllerDidAppear:page.carrier];
    [self waitForRoutingWork];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 3);

    // A page that has left the window must not be replayed.
    self.pageWindow.rootViewController = [UIViewController new];
    [self.autotracker switchToDataSourceId:@"B"];
    [self waitForRoutingWork];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 3);
}

- (void)testPageReplayFromWorker {
    [self prepareCurrentPage];
    GrowingAutotracker *tracker = [[GrowingAutotracker alloc] initWithTarget:self.autotracker];
    XCTestExpectation *done = [self expectationWithDescription:@"worker switch"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [tracker switchToDataSourceId:@"C" dataCollectionServerHost:@"https://c.example.com"];
        [tracker trackCustomEvent:@"workerAfterSwitch"];
        [done fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
    [self waitForRoutingWork];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    XCTAssertEqualObjects(events.firstObject.dataSourceId, @"C");
    XCTAssertEqualObjects(events.firstObject.sessionId, GrowingSession.currentSession.sessionId);
    GrowingBaseEvent *custom = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom].firstObject;
    XCTAssertEqualObjects(custom.dataSourceId, @"C");
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

    [self.autotracker switchToDataSourceId:@"B"];
    [self waitForRoutingWork];
    NSArray<GrowingPageEvent *> *events = (id)[MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    XCTAssertEqualObjects(events.firstObject.path, @"/same-page");
    XCTAssertEqualObjects(events.firstObject.dataSourceId, @"B");
}

- (void)testTrackerSwitchDoesNotReplayPage {
    [self prepareCurrentPage];
    GrowingRealTracker *tracker = [GrowingRealTracker new];
    [tracker switchToDataSourceId:@"B"];
    ((GrowingAutotrackConfiguration *)GrowingConfigurationManager.sharedInstance.trackConfiguration).autotrackEnabled =
        NO;
    [self.autotracker switchToDataSourceId:@"A"];
    [self waitForRoutingWork];
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 0);
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 2);
}

- (void)testRejectedAutotrackerSwitchDoesNotReplayPage {
    GrowingPage *page = [self prepareCurrentPage];
    NSString *session = GrowingSession.currentSession.sessionId;
    [self.autotracker switchToDataSourceId:@"A" dataCollectionServerHost:@"https://different.example.com"];
    [self.autotracker switchToDataSourceId:@"B" dataCollectionServerHost:@""];
    [self waitForRoutingWork];
    XCTAssertEqualObjects(GrowingSession.currentSession.sessionId, session);
    XCTAssertEqual(page.showTimestamp, 123);
    XCTAssertEqualObjects(GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId, @"A");
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 0);
    XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage].count, 0);
}

#pragma mark - Helpers

- (NSArray<NSString *> *)validCollectionURLs {
    return @[
        @"https://example.com",
        @"https://example.com/base/",
        @"http://192.168.1.10:8080/collect",
        @"HTTPS://EXAMPLE.COM:443/base",
    ];
}

- (NSArray<NSString *> *)invalidCollectionURLs {
    return @[
        @"example.com/base",
        @"file:///tmp/events",
        @"ftp://example.com",
        @"https://",
        @"https:///base",
        @"https://example.com:0",
        @"https://example.com:99999",
        @"https://user:password@example.com/base/",
        @"https://example.com/base?query=1",
        @"https://example.com/base#fragment",
        @"https://exa mple.com",
    ];
}

- (NSMutableDictionary *)cachedServiceInstances {
    return [GrowingServiceManager.sharedInstance valueForKey:@"allServiceInstanceDict"];
}

- (void)installNetworkStub {
    [GrowingServiceManager.sharedInstance registerAllServices];
    self.savedNetworkClass =
        [GrowingServiceManager.sharedInstance serviceImplClass:@protocol(GrowingEventNetworkService)];
    NSMutableDictionary *instances = [self cachedServiceInstances];
    self.savedNetworkInstance = instances[NSStringFromProtocol(@protocol(GrowingEventNetworkService))];
    instances[NSStringFromProtocol(@protocol(GrowingEventNetworkService))] = RoutingNetworkStub.sharedInstance;
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventNetworkService)
                                                implClass:RoutingNetworkStub.class];
}

- (void)restoreNetworkService {
    NSMutableDictionary *instances = [self cachedServiceInstances];
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

// 只等待此前排入事件线程的任务；PAGE 补发需要使用 waitForRoutingWork 等待完整链路。
- (void)waitForEventThread {
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
}

- (GrowingEventDatabase *)databaseWithSources:(NSArray<NSString *> *)sources {
    return [self databaseWithSources:sources isProtobuf:NO];
}

- (GrowingEventDatabase *)databaseWithSources:(NSArray<NSString *> *)sources isProtobuf:(BOOL)isProtobuf {
    NSString *path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSString stringWithFormat:@"routing-upload-%@/events.sqlite",
                                                                  NSUUID.UUID.UUIDString]];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:nil]);
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
        [self waitForEventThread];
    }
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

- (void)waitForRoutingWork {
    XCTestExpectation *done = [self expectationWithDescription:@"asynchronous page replay"];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [GrowingDispatchManager dispatchInGrowingThread:^{
                [done fulfill];
            }];
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
