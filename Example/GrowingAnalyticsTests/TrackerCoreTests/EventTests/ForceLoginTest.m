//
//  ForceLoginTest.m
//  GrowingAnalytics
//
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingEventNetworkService.h"
#import "GrowingServiceManager.h"
#import "GrowingTracker.h"
#import "GrowingTrackerCore/Database/GrowingEventDatabase.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingForceLogin.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "Services/Protobuf/Proto/GrowingEvent.pbobjc.h"

@interface ForceLoginNetworkStub : NSObject <GrowingEventNetworkService>
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSMutableArray<id<GrowingRequestProtocol>> *requests;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *pendingResponses;
@property (nonatomic, assign) BOOL holdResponses;
@property (nonatomic, assign) BOOL shouldFail;
@end

@implementation ForceLoginNetworkStub
+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static ForceLoginNetworkStub *instance;
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
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.absoluteURL
                                                              statusCode:self.shouldFail ? 503 : 200
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

@interface ForceLoginDatabaseSpy : GrowingEventDatabase
@property (nonatomic, assign) NSUInteger readCount;
@end

@implementation ForceLoginDatabaseSpy
- (NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsByCount:(NSUInteger)count
                                                         limitSize:(NSUInteger)limitSize
                                                            policy:(NSUInteger)mask {
    self.readCount++;
    return @[];
}
- (NSUInteger)countOfEvents {
    return 0;
}
@end

@interface ForceLoginSentEventInterceptor : NSObject <GrowingEventInterceptor>
@property (nonatomic, strong) NSArray<id<GrowingEventPersistenceProtocol>> *sentEvents;
@end

@implementation ForceLoginSentEventInterceptor
- (void)growingEventManagerEventsDidSend:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
                                 request:(id<GrowingRequestProtocol>)request
                                 channel:(GrowingEventChannel *)channel {
    self.sentEvents = events;
}
@end

@interface ForceLoginTest : XCTestCase
@property (nonatomic, strong) GrowingTrackConfiguration *savedConfiguration;
@property (nonatomic, copy) NSString *savedIdentifyDeviceId;
@property (nonatomic, assign) Class savedNetworkClass;
@property (nonatomic, strong) id savedNetworkInstance;
@end

@implementation ForceLoginTest

- (void)setUp {
    [self installNetworkStub];
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            self.savedConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
            self.savedIdentifyDeviceId = [GrowingPersistenceDataProvider sharedInstance].identifyDeviceId;
            [[GrowingPersistenceDataProvider sharedInstance] setIdentifyDeviceId:nil];
            GrowingTrackConfiguration *config =
                [GrowingTrackConfiguration configurationWithAccountId:@"force-login-test"];
            config.dataSourceId = @"test";
            config.dataCollectionServerHost = @"https://force-login.example.com";
            config.useProtobuf = NO;
            config.dataCollectionEnabled = YES;
            GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
            [GrowingForceLogin setup];
            [GrowingSession startSession];
            [ForceLoginNetworkStub.sharedInstance.requests removeAllObjects];
            [ForceLoginNetworkStub.sharedInstance.pendingResponses removeAllObjects];
            ForceLoginNetworkStub.sharedInstance.holdResponses = NO;
            ForceLoginNetworkStub.sharedInstance.shouldFail = NO;
        }
                  waitUntilDone:YES];
    [GrowingEventManager.sharedInstance configManager];
    [self waitForEventThread];
}

- (void)tearDown {
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [GrowingEventManager.sharedInstance flushDB];
            GrowingConfigurationManager.sharedInstance.trackConfiguration = self.savedConfiguration;
            [[GrowingPersistenceDataProvider sharedInstance] setIdentifyDeviceId:self.savedIdentifyDeviceId];
            [GrowingForceLogin setup];
        }
                  waitUntilDone:YES];
    [self restoreNetworkService];
}

- (void)testValidationPersistenceAndEventDeviceId {
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    config.forceLogin = YES;
    [GrowingForceLogin setup];
    XCTAssertFalse([GrowingForceLogin canSend]);
    XCTAssertFalse([GrowingForceLogin identify:@""]);
    XCTAssertFalse([GrowingForceLogin identify:@"  \n  "]);
    NSString *overlongId = [@"" stringByPaddingToLength:1001 withString:@"x" startingAtIndex:0];
    XCTAssertFalse([GrowingForceLogin identify:overlongId]);
    XCTAssertFalse([GrowingForceLogin canSend]);

    XCTAssertTrue([GrowingForceLogin identify:@"  visitor-001  "]);
    XCTAssertTrue([GrowingForceLogin canSend]);
    XCTAssertEqualObjects([GrowingForceLogin deviceIdWithGeneratedDeviceId:@"generated"], @"visitor-001");
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"visitor-001");
    GrowingBaseBuilder *builder = GrowingCustomEvent.builder.setEventName(@"forced");
    [builder readPropertyInTrackThread];
    XCTAssertEqualObjects(builder.build.deviceId, @"visitor-001");

    XCTAssertFalse([GrowingForceLogin identify:@"visitor-002"]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"visitor-001");
    [GrowingForceLogin setup];
    XCTAssertFalse([GrowingForceLogin canSend]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"visitor-001");

    config.forceLogin = NO;
    XCTAssertTrue([GrowingForceLogin canSend]);
    XCTAssertFalse([GrowingForceLogin identify:@"visitor-003"]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"visitor-001");
}

- (void)testLockedModeBlocksBatchReadAndNetwork {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.forceLogin = YES;
    [GrowingForceLogin setup];
    ForceLoginDatabaseSpy *db = [ForceLoginDatabaseSpy new];
    GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                  eventTypes:nil
                                                             isRealtimeEvent:YES];
    channel.db = db;
    GrowingEventManager *manager = [GrowingEventManager new];
    [manager setValue:@[channel] forKey:@"allEventChannels"];

    [manager sendAllChannelEvents];
    [self waitForEventThread];
    XCTAssertEqual(db.readCount, 0);
    XCTAssertEqual(ForceLoginNetworkStub.sharedInstance.requests.count, 0);
    XCTAssertFalse(channel.isUploading);
}

- (void)testIdentifyUploadsAndRetriesWithReplacementForJSONAndProtobuf {
    for (NSNumber *useProtobuf in @[@NO, @YES]) {
        BOOL isProtobuf = useProtobuf.boolValue;
        NSString *visitorId = isProtobuf ? @"visitor-protobuf" : @"visitor-json";
        [GrowingDispatchManager
            dispatchInGrowingThread:^{
                GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
                config.forceLogin = YES;
                config.dataCollectionEnabled = NO;
                config.useProtobuf = isProtobuf;
                [GrowingForceLogin setup];
                [ForceLoginNetworkStub.sharedInstance.requests removeAllObjects];
                [ForceLoginNetworkStub.sharedInstance.pendingResponses removeAllObjects];
                ForceLoginNetworkStub.sharedInstance.holdResponses = YES;
                ForceLoginNetworkStub.sharedInstance.shouldFail = YES;
            }
                      waitUntilDone:YES];

        GrowingEventDatabase *db = [self databaseWithEventIsProtobuf:isProtobuf];
        GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                      eventTypes:nil
                                                                 isRealtimeEvent:YES];
        channel.persistenceType = isProtobuf ? GrowingEventPersistenceTypeProtobuf : GrowingEventPersistenceTypeJSON;
        channel.db = db;
        GrowingEventManager *manager = GrowingEventManager.sharedInstance;
        NSArray *savedChannels = [manager valueForKey:@"allEventChannels"];
        [manager setValue:@[channel] forKey:@"allEventChannels"];
        ForceLoginSentEventInterceptor *interceptor = [ForceLoginSentEventInterceptor new];
        [manager addInterceptor:interceptor];

        [manager sendAllChannelEvents];
        [self waitForEventThread];
        XCTAssertEqual(ForceLoginNetworkStub.sharedInstance.requests.count, 0);
        XCTAssertEqual(db.countOfEvents, 1);

        GrowingTracker *tracker = [[GrowingTracker alloc] initWithTarget:[GrowingRealTracker new]];
        [tracker identify:[NSString stringWithFormat:@"  %@  ", visitorId]];
        [self waitForEventThread];
        [self completePendingUploads];
        XCTAssertEqual(ForceLoginNetworkStub.sharedInstance.requests.count, 1);
        XCTAssertEqual(db.countOfEvents, 1);
        XCTAssertNil(interceptor.sentEvents);
        [self assertRequest:ForceLoginNetworkStub.sharedInstance.requests.firstObject deviceId:visitorId];

        NSArray<id<GrowingEventPersistenceProtocol>> *remaining = [db getEventsByCount:10 limitSize:100000 policy:~0UL];
        XCTAssertEqual(remaining.count, 1);
        XCTAssertEqualObjects([remaining.firstObject toJSONObject][@"deviceId"], @"generated-device");
        NSString *eventUUID = remaining.firstObject.eventUUID;

        ForceLoginNetworkStub.sharedInstance.shouldFail = NO;
        [manager sendAllChannelEvents];
        [self waitForEventThread];
        [self completePendingUploads];
        XCTAssertEqual(ForceLoginNetworkStub.sharedInstance.requests.count, 2);
        XCTAssertEqual(db.countOfEvents, 0);
        [self assertRequest:ForceLoginNetworkStub.sharedInstance.requests.lastObject deviceId:visitorId];
        XCTAssertEqual(interceptor.sentEvents.count, 1);
        XCTAssertEqualObjects([interceptor.sentEvents.firstObject toJSONObject][@"deviceId"], visitorId);
        XCTAssertEqualObjects(interceptor.sentEvents.firstObject.eventUUID, eventUUID);

        [manager removeInterceptor:interceptor];
        [manager setValue:savedChannels forKey:@"allEventChannels"];
    }
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
    instances[NSStringFromProtocol(@protocol(GrowingEventNetworkService))] = ForceLoginNetworkStub.sharedInstance;
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventNetworkService)
                                                implClass:ForceLoginNetworkStub.class];
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

- (void)waitForEventThread {
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
        }
                  waitUntilDone:YES];
}

- (GrowingEventDatabase *)databaseWithEventIsProtobuf:(BOOL)isProtobuf {
    NSString *path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSString stringWithFormat:@"force-login-upload-%@/events.sqlite",
                                                                  NSUUID.UUID.UUIDString]];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:nil]);
    GrowingEventDatabase *db = [GrowingEventDatabase databaseWithPath:path isProtobuf:isProtobuf];
    db.autoFlushCount = NSUIntegerMax;
    GrowingBaseEvent *event = GrowingCustomEvent.builder.setEventName(@"cached")
                                  .setDataSourceId(@"test")
                                  .setDeviceId(@"generated-device")
                                  .setSessionId(@"test-session")
                                  .setSdkVersion(@"4.14.0")
                                  .build;
    NSString *uuid = NSUUID.UUID.UUIDString;
    [db setEvent:[db persistenceEventWithEvent:event uuid:uuid] forKey:uuid];
    XCTAssertTrue([db flush]);
    return db;
}

- (void)assertRequest:(id<GrowingRequestProtocol>)request deviceId:(NSString *)deviceId {
    if (GrowingConfigurationManager.sharedInstance.trackConfiguration.useProtobuf) {
        GrowingPBEventV3List *list = [GrowingPBEventV3List parseFromData:request.events error:nil];
        XCTAssertNotNil(list);
        XCTAssertEqual(list.valuesArray_Count, 1);
        GrowingPBEventV3Dto *event = list.valuesArray.firstObject;
        XCTAssertEqualObjects(event.deviceId, deviceId);
        XCTAssertEqualObjects(event.eventName, @"cached");
        XCTAssertEqualObjects(event.sessionId, @"test-session");
    } else {
        NSArray *events = [NSJSONSerialization JSONObjectWithData:request.events options:0 error:nil];
        XCTAssertEqual(events.count, 1);
        NSDictionary *event = events.firstObject;
        XCTAssertEqualObjects(event[@"deviceId"], deviceId);
        XCTAssertEqualObjects(event[@"eventName"], @"cached");
        XCTAssertEqualObjects(event[@"sessionId"], @"test-session");
    }
}

- (void)completePendingUploads {
    while (ForceLoginNetworkStub.sharedInstance.pendingResponses.count) {
        dispatch_block_t response = ForceLoginNetworkStub.sharedInstance.pendingResponses.firstObject;
        [ForceLoginNetworkStub.sharedInstance.pendingResponses removeObjectAtIndex:0];
        response();
        [self waitForEventThread];
    }
}

@end
