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
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "Services/Database/FMDB/GrowingFMDB.h"
#import "Services/JSON/GrowingEventJSONPersistence.h"
#import "Services/Protobuf/Proto/GrowingEvent.pbobjc.h"

@interface GrowingEventManager (ForceLoginTest)
- (void)writeToDatabaseWithEvent:(GrowingBaseEvent *)event;
@end

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
    NSString *generatedId = [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
    XCTAssertFalse([GrowingForceLogin canSend]);
    XCTAssertTrue([GrowingForceLogin isPending]);
    XCTAssertFalse([GrowingForceLogin identify:@""]);
    XCTAssertFalse([GrowingForceLogin canSend]);
    // 未解锁时事件使用自动生成的设备 ID
    XCTAssertEqualObjects([self builtDeviceId], generatedId);

    // 与 Web SDK 一致：不去除首尾空白，解锁后立即可上传
    XCTAssertTrue([GrowingForceLogin identify:@"  visitor-001  "]);
    XCTAssertTrue([GrowingForceLogin canSend]);
    XCTAssertFalse([GrowingForceLogin isPending]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"  visitor-001  ");
    XCTAssertEqualObjects([self builtDeviceId], @"  visitor-001  ");

    XCTAssertFalse([GrowingForceLogin identify:@"visitor-002"]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"  visitor-001  ");

    // 下次启动：重新锁定；getDeviceId 返回已持久化的访问用户 ID，但新事件写自动生成的设备 ID
    [GrowingForceLogin setup];
    XCTAssertFalse([GrowingForceLogin canSend]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"  visitor-001  ");
    XCTAssertEqualObjects([self builtDeviceId], generatedId);

    // 关闭 forceLogin：不阻塞，事件沿用已持久化的访问用户 ID
    config.forceLogin = NO;
    XCTAssertTrue([GrowingForceLogin canSend]);
    XCTAssertFalse([GrowingForceLogin identify:@"visitor-003"]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId], @"  visitor-001  ");
    XCTAssertEqualObjects([self builtDeviceId], @"  visitor-001  ");
}

- (void)testIdentifyTruncatesOverlongIdOnCharacterBoundary {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.forceLogin = YES;
    [GrowingForceLogin setup];
    NSString *overlongId = [@"" stringByPaddingToLength:1001 withString:@"x" startingAtIndex:0];
    XCTAssertTrue([GrowingForceLogin identify:overlongId]);
    XCTAssertEqual([[GrowingRealTracker new] getDeviceId].length, 1000);

    // 第 1000 个 UTF-16 单元落在 emoji 代理对中间时，在 emoji 之前截断
    [GrowingForceLogin setup];
    NSString *emojiId =
        [[@"" stringByPaddingToLength:999 withString:@"x" startingAtIndex:0] stringByAppendingString:@"😀y"];
    XCTAssertTrue([GrowingForceLogin identify:emojiId]);
    XCTAssertEqualObjects([[GrowingRealTracker new] getDeviceId],
                          [@"" stringByPaddingToLength:999 withString:@"x" startingAtIndex:0]);
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

- (void)testPendingEventsArePersistedAndReplacedOnUploadForJSONAndProtobuf {
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

        // 老版本或此前启动已确认身份的事件，不带待替换标志
        GrowingEventDatabase *db = [self databaseWithCachedEventIsProtobuf:isProtobuf];
        GrowingBaseEvent *pendingEvent = [self eventWithName:@"pending" deviceId:@"generated-device"];
        GrowingEventChannel *channel = [GrowingEventChannel eventChannelWithName:@"Track"
                                                                      eventTypes:@[pendingEvent.eventType]
                                                                 isRealtimeEvent:YES];
        channel.persistenceType = isProtobuf ? GrowingEventPersistenceTypeProtobuf : GrowingEventPersistenceTypeJSON;
        channel.db = db;
        GrowingEventManager *manager = GrowingEventManager.sharedInstance;
        NSArray *savedChannels = [manager valueForKey:@"allEventChannels"];
        NSDictionary *savedChannelMap = [manager valueForKey:@"currentEventChannelMap"];
        [manager setValue:@[channel] forKey:@"allEventChannels"];
        [manager setValue:@{pendingEvent.eventType: channel} forKey:@"currentEventChannelMap"];

        // identify 前：事件照常入库并带待替换标志，但不上传
        [GrowingDispatchManager
            dispatchInGrowingThread:^{
                [manager writeToDatabaseWithEvent:pendingEvent];
            }
                      waitUntilDone:YES];
        [manager sendAllChannelEvents];
        [self waitForEventThread];
        XCTAssertEqual(ForceLoginNetworkStub.sharedInstance.requests.count, 0);
        XCTAssertEqual(db.countOfEvents, 2);
        NSDictionary *stored = @{@"cached": @"previous-visitor", @"pending": @"generated-device"};
        XCTAssertEqualObjects([self deviceIdsInDatabase:db], stored);
        XCTAssertEqualObjects([self pendingFlagsInDatabase:db], (@{@"cached": @NO, @"pending": @YES}));

        GrowingTracker *tracker = [[GrowingTracker alloc] initWithTarget:[GrowingRealTracker new]];
        [tracker identify:visitorId];
        [self waitForEventThread];
        [self completePendingUploads];

        // 只替换带待替换标志的事件；数据库原文不变
        NSDictionary *expected = @{@"cached": @"previous-visitor", @"pending": visitorId};
        XCTAssertEqual(ForceLoginNetworkStub.sharedInstance.requests.count, 1);
        XCTAssertEqualObjects([self deviceIdsInRequest:ForceLoginNetworkStub.sharedInstance.requests.firstObject],
                              expected);
        XCTAssertEqualObjects([self deviceIdsInDatabase:db], stored);

        // 上传失败后重试，再次替换
        ForceLoginNetworkStub.sharedInstance.shouldFail = NO;
        [manager sendAllChannelEvents];
        [self waitForEventThread];
        [self completePendingUploads];
        XCTAssertEqual(ForceLoginNetworkStub.sharedInstance.requests.count, 2);
        XCTAssertEqualObjects([self deviceIdsInRequest:ForceLoginNetworkStub.sharedInstance.requests.lastObject],
                              expected);
        XCTAssertEqual(db.countOfEvents, 0);

        [manager setValue:savedChannels forKey:@"allEventChannels"];
        [manager setValue:savedChannelMap forKey:@"currentEventChannelMap"];
    }
}

- (void)testOldTableGetsForceLoginPendingColumn {
    NSString *path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSString stringWithFormat:@"force-login-migration-%@/events.sqlite",
                                                                  NSUUID.UUID.UUIDString]];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:nil]);
    // 老版本 SDK 创建的表：没有 forceLoginPending 列
    GrowingFMDatabase *oldDB = [GrowingFMDatabase databaseWithPath:path];
    XCTAssertTrue([oldDB open]);
    XCTAssertTrue([oldDB executeUpdate:@"CREATE TABLE namedcachetable(id INTEGER PRIMARY KEY, name TEXT, key TEXT, "
                                       @"value TEXT, createAt INTEGER NOT NULL, type TEXT, sdkVersion TEXT, "
                                       @"policy INTEGER);"]);
    GrowingBaseEvent *event = [self eventWithName:@"legacy" deviceId:@"legacy-device"];
    id<GrowingEventPersistenceProtocol> legacy = [GrowingEventJSONPersistence persistenceEventWithEvent:event
                                                                                                  uuid:@"legacy"];
    XCTAssertTrue([oldDB executeUpdate:@"INSERT INTO namedcachetable(key,value,createAt,type,sdkVersion,policy) "
                                       @"values(?,?,?,?,?,?)",
                                       legacy.eventUUID,
                                       legacy.data,
                                       @((long long)([NSDate date].timeIntervalSince1970 * 1000)),
                                       legacy.eventType,
                                       legacy.sdkVersion,
                                       @(legacy.policy)]);
    XCTAssertFalse([oldDB columnExists:@"forceLoginPending" inTableWithName:@"namedcachetable"]);
    [oldDB close];

    GrowingEventDatabase *db = [GrowingEventDatabase databaseWithPath:path isProtobuf:NO];
    XCTAssertEqualObjects([self pendingFlagsInDatabase:db], @{@"legacy": @NO});
    GrowingFMDatabase *checkDB = [GrowingFMDatabase databaseWithPath:path];
    XCTAssertTrue([checkDB open]);
    XCTAssertTrue([checkDB columnExists:@"forceLoginPending" inTableWithName:@"namedcachetable"]);
    [checkDB close];
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

- (GrowingBaseEvent *)eventWithName:(NSString *)eventName deviceId:(NSString *)deviceId {
    return GrowingCustomEvent.builder.setEventName(eventName)
        .setDataSourceId(@"test")
        .setDeviceId(deviceId)
        .setSessionId(@"test-session")
        .setSdkVersion(@"4.14.0")
        .build;
}

- (GrowingEventDatabase *)databaseWithCachedEventIsProtobuf:(BOOL)isProtobuf {
    NSString *path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSString stringWithFormat:@"force-login-upload-%@/events.sqlite",
                                                                  NSUUID.UUID.UUIDString]];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:nil]);
    GrowingEventDatabase *db = [GrowingEventDatabase databaseWithPath:path isProtobuf:isProtobuf];
    db.autoFlushCount = NSUIntegerMax;
    GrowingBaseEvent *event = [self eventWithName:@"cached" deviceId:@"previous-visitor"];
    NSString *uuid = NSUUID.UUID.UUIDString;
    [db setEvent:[db persistenceEventWithEvent:event uuid:uuid] forKey:uuid];
    XCTAssertTrue([db flush]);
    return db;
}

/// eventName -> deviceId
- (NSDictionary<NSString *, NSString *> *)deviceIdsInRequest:(id<GrowingRequestProtocol>)request {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (GrowingConfigurationManager.sharedInstance.trackConfiguration.useProtobuf) {
        GrowingPBEventV3List *list = [GrowingPBEventV3List parseFromData:request.events error:nil];
        XCTAssertNotNil(list);
        for (GrowingPBEventV3Dto *event in list.valuesArray) {
            XCTAssertEqualObjects(event.sessionId, @"test-session");
            result[event.eventName] = event.deviceId;
        }
    } else {
        NSArray *events = [NSJSONSerialization JSONObjectWithData:request.events options:0 error:nil];
        for (NSDictionary *event in events) {
            XCTAssertEqualObjects(event[@"sessionId"], @"test-session");
            result[event[@"eventName"]] = event[@"deviceId"];
        }
    }
    return result;
}

- (NSString *)builtDeviceId {
    GrowingBaseBuilder *builder = GrowingCustomEvent.builder.setEventName(@"forced");
    [builder readPropertyInTrackThread];
    return builder.build.deviceId;
}

/// eventName -> forceLoginPending
- (NSDictionary<NSString *, NSNumber *> *)pendingFlagsInDatabase:(GrowingEventDatabase *)db {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id<GrowingEventPersistenceProtocol> event in [db getEventsByCount:10 limitSize:100000 policy:~0UL]) {
        NSDictionary *jsonObject = event.toJSONObject;
        result[jsonObject[@"eventName"]] = @(event.forceLoginPending);
    }
    return result;
}

/// eventName -> deviceId
- (NSDictionary<NSString *, NSString *> *)deviceIdsInDatabase:(GrowingEventDatabase *)db {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id<GrowingEventPersistenceProtocol> event in [db getEventsByCount:10 limitSize:100000 policy:~0UL]) {
        NSDictionary *jsonObject = event.toJSONObject;
        result[jsonObject[@"eventName"]] = jsonObject[@"deviceId"];
    }
    return result;
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
