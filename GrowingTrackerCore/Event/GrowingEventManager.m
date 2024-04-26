//
//  GrowingEventManager.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/11/19.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingDataTraffic.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/FileStorage/GrowingFileStorage.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Network/GrowingNetworkInterfaceManager.h"
#import "GrowingTrackerCore/Network/GrowingNetworkPreflight.h"
#import "GrowingTrackerCore/Network/Request/GrowingEventRequest.h"
#import "GrowingTrackerCore/Public/GrowingBaseEvent.h"
#import "GrowingTrackerCore/Public/GrowingEventFilter.h"
#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

static const NSUInteger kGrowingMaxDBCacheSize = 100;  // default: write to DB as soon as there are 100 events
static const NSUInteger kGrowingMaxBatchSize = 500;    // default: send no more than 500 events in every batch
static const NSUInteger kGrowingUnit_MB = 1024 * 1024;

@interface GrowingEventManager ()

@property (nonatomic, strong) NSHashTable *allInterceptor;

@property (nonatomic, strong, readonly) NSArray<GrowingEventChannel *> *allEventChannels;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, GrowingEventChannel *> *currentEventChannelMap;
@property (nonatomic, strong) dispatch_source_t reportTimer;

@property (nonatomic, strong) GrowingEventDatabase *timingEventDB;
@property (nonatomic, strong) GrowingEventDatabase *realtimeEventDB;
@property (nonatomic, strong) GrowingEventDatabase *timingEventDB_PB;
@property (nonatomic, strong) GrowingEventDatabase *realtimeEventDB_PB;

@property (nonatomic, assign) unsigned long long uploadEventSize;
@property (nonatomic, assign) unsigned long long uploadLimitOfCellular;

@end

@implementation GrowingEventManager

#pragma mark - Init

static GrowingEventManager *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _allInterceptor = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark - Configure Manager

- (void)configManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [GrowingDispatchManager dispatchInGrowingThread:^{
            // default is 10MB
            self->_uploadLimitOfCellular =
                [GrowingConfigurationManager sharedInstance].trackConfiguration.cellularDataLimit * kGrowingUnit_MB;

            self->_timingEventDB = [GrowingEventDatabase databaseWithPath:[GrowingFileStorage getTimingDatabasePath]
                                                               isProtobuf:NO];
            self->_timingEventDB_PB = [GrowingEventDatabase databaseWithPath:[GrowingFileStorage getTimingDatabasePath]
                                                                  isProtobuf:YES];
            self->_timingEventDB.autoFlushCount = kGrowingMaxDBCacheSize;
            self->_timingEventDB_PB.autoFlushCount = kGrowingMaxDBCacheSize;
            self->_realtimeEventDB = [GrowingEventDatabase databaseWithPath:[GrowingFileStorage getRealtimeDatabasePath]
                                                                 isProtobuf:NO];
            self->_realtimeEventDB_PB =
                [GrowingEventDatabase databaseWithPath:[GrowingFileStorage getRealtimeDatabasePath] isProtobuf:YES];

            NSMutableArray *eventChannels = [GrowingEventChannel eventChannels];
            // 发送通道的eventTypes不能修改，并与数据库一一对应
            for (GrowingEventChannel *ec in eventChannels) {
                if (ec.isRealtimeEvent) {
                    if (ec.persistenceType == GrowingEventPersistenceTypeProtobuf) {
                        ec.db = self.realtimeEventDB_PB;
                    } else {
                        ec.db = self.realtimeEventDB;
                    }
                } else {
                    if (ec.persistenceType == GrowingEventPersistenceTypeProtobuf) {
                        ec.db = self.timingEventDB_PB;
                    } else {
                        ec.db = self.timingEventDB;
                    }
                }
            }
            self->_allEventChannels = eventChannels;

            GrowingTrackConfiguration *trackConfiguration =
                GrowingConfigurationManager.sharedInstance.trackConfiguration;
            GrowingEventPersistenceType currentType =
                trackConfiguration.useProtobuf ? GrowingEventPersistenceTypeProtobuf : GrowingEventPersistenceTypeJSON;
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            for (GrowingEventChannel *ec in eventChannels) {
                if (ec.persistenceType != currentType) {
                    continue;
                }
                for (NSString *key in ec.eventTypes) {
                    [dictM setObject:ec forKey:key];
                }
            }
            self->_currentEventChannelMap = dictM;
        }];
    });
}

#pragma mark - Start Timer

- (void)startTimerSend {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat configInterval = GrowingConfigurationManager.sharedInstance.trackConfiguration.dataUploadInterval;
        CGFloat dataUploadInterval = MAX(configInterval, 5);  // at least 5 seconds

        dispatch_queue_t queue = dispatch_queue_create("io.growing", NULL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        self.reportTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.reportTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5),  // first upload
                                  NSEC_PER_SEC * dataUploadInterval,
                                  NSEC_PER_SEC * 1);
        dispatch_source_set_event_handler(self.reportTimer, ^{
            [self sendAllChannelEvents];
        });
        dispatch_resume(_reportTimer);
    });
}

#pragma mark - Event
#pragma mark Event Send

- (void)postEventBuilder:(GrowingBaseBuilder *_Nullable)builder {
    dispatch_block_t block = ^{
        for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
            if ([obj respondsToSelector:@selector(growingEventManagerEventTriggered:)]) {
                [obj growingEventManagerEventTriggered:builder.eventType];
            }
        }

        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (!trackConfiguration.dataCollectionEnabled) {
            GIOLogDebug(@"Data collection is disabled, event can not build");
            return;
        }

        if ([GrowingEventFilter isFilterEvent:builder.eventType]) {
            return;
        }

        if (![GrowingSession currentSession].isSentVisitAfterRefreshSessionId) {
            [[GrowingSession currentSession] generateVisit];
        }

        [builder readPropertyInTrackThread];

        for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
            if ([obj respondsToSelector:@selector(growingEventManagerEventWillBuild:)]) {
                [obj growingEventManagerEventWillBuild:builder];
            }
        }

        GrowingBaseEvent *event = builder.build;

        for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
            if ([obj respondsToSelector:@selector(growingEventManagerEventDidBuild:)]) {
                [obj growingEventManagerEventDidBuild:event];
            }
        }

        [self writeToDatabaseWithEvent:event];

        for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
            if ([obj respondsToSelector:@selector(growingEventManagerEventDidWrite:)]) {
                [obj growingEventManagerEventDidWrite:event];
            }
        }
    };
    [GrowingDispatchManager dispatchInGrowingThread:block];
}

- (void)sendAllChannelEvents {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self flushDB];
        for (GrowingEventChannel *channel in self.allEventChannels) {
            [self sendEventsOfChannel_unsafe:channel];
        }
    }];
}

- (void)sendEventsInstantWithChannel:(GrowingEventChannel *)channel {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self flushDB];
        [self sendEventsOfChannel_unsafe:channel];
    }];
}

// 非安全 发送日志
- (void)sendEventsOfChannel_unsafe:(GrowingEventChannel *)channel {
    if (![GrowingNetworkPreflight isSucceed]) {
        return;
    }
    if (channel.isUploading) {
        return;
    }

    GrowingNetworkReachabilityStatus reachabilityStatus =
        [[GrowingNetworkInterfaceManager sharedInstance] currentStatus];
    BOOL isViaCellular = NO;
    // 没网络 直接返回
    if (reachabilityStatus == GrowingNetworkReachabilityNotReachable) {
#if !Growing_OS_WATCH
        // https://forums.developer.apple.com/forums/thread/729568
        GIOLogDebug(@"No available Internet connection, delay upload (channel = %@).", channel.name);
        return;
#endif
    }
    NSUInteger policyMask =
        GrowingEventSendPolicyInstant | GrowingEventSendPolicyMobileData | GrowingEventSendPolicyWiFi;
    if (reachabilityStatus == GrowingNetworkReachabilityReachableViaWiFi ||
        reachabilityStatus == GrowingNetworkReachabilityReachableViaEthernet) {
        policyMask = GrowingEventSendPolicyInstant | GrowingEventSendPolicyMobileData | GrowingEventSendPolicyWiFi;

    } else if (reachabilityStatus == GrowingNetworkReachabilityReachableViaWWAN) {
        if (self.uploadEventSize < self.uploadLimitOfCellular) {
            GIOLogDebug(@"Upload key data with mobile network (channel = %@).", channel.name);
            policyMask = GrowingEventSendPolicyInstant | GrowingEventSendPolicyMobileData;
            isViaCellular = YES;
        } else {
            GIOLogDebug(@"Mobile network is forbidden. upload later (channel = %@).", channel.name);
            // 实时发送策略无视流量限制
            policyMask = GrowingEventSendPolicyInstant;
        }
    }

    NSArray<id<GrowingEventPersistenceProtocol>> *events = [self getEventsToBeUploadUnsafe:channel policy:policyMask];

    // 过滤3.x的无埋点事件
    NSMutableArray *removeV3AutotrackEvents = [NSMutableArray arrayWithArray:events];
    for (id<GrowingEventPersistenceProtocol> e in events) {
        if ([e.sdkVersion hasPrefix:@"4."]) {
            continue;
        }
        if ([e.eventType isEqualToString:@"PAGE"] || [e.eventType isEqualToString:@"VIEW_CLICK"] ||
            [e.eventType isEqualToString:@"VIEW_CHANGE"] || [e.eventType isEqualToString:@"FORM_SUBMIT"] ||
            [e.eventType isEqualToString:@"APP_CLOSED"]) {
            [removeV3AutotrackEvents removeObject:e];
        }
    }
    events = removeV3AutotrackEvents.copy;

    for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
        if ([obj respondsToSelector:@selector(growingEventManagerEventsWillSend:channel:)]) {
            events = [obj growingEventManagerEventsWillSend:events channel:channel];
        }
    }

    if (events.count == 0) {
        return;
    }

#ifdef DEBUG
    [self prettyLogForEvents:events withChannel:channel];
#endif

    NSData *rawEvents = nil;
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if ((channel.persistenceType == GrowingEventPersistenceTypeJSON && trackConfiguration.useProtobuf) ||
        (channel.persistenceType == GrowingEventPersistenceTypeProtobuf && !trackConfiguration.useProtobuf)) {
        // 该channel的持久化数据格式与配置不同，需要转换为配置的数据格式
        // 先转成jsonObject，再转成对应格式
        Class<GrowingEventDatabaseService> dbClass = nil;
        if (trackConfiguration.useProtobuf) {
            dbClass =
                [[GrowingServiceManager sharedInstance] serviceImplClass:@protocol(GrowingPBEventDatabaseService)];
        } else {
            dbClass = [[GrowingServiceManager sharedInstance] serviceImplClass:@protocol(GrowingEventDatabaseService)];
        }
        if (!dbClass) {
            GIOLogError(@"-sendEventsOfChannel_unsafe: error : no event database service support");
            return;
        }
        NSMutableArray *jsonObjects = [NSMutableArray array];
        for (id<GrowingEventPersistenceProtocol> e in events) {
            id jsonObject = e.toJSONObject;
            if (jsonObject) {
                [jsonObjects addObject:jsonObject];
            }
        }

        rawEvents = [dbClass buildRawEventsFromJsonObjects:jsonObjects];
    } else {
        // 该channel的持久化数据格式与配置相同
        rawEvents = [channel.db buildRawEventsFromEvents:events];
    }

    if (!rawEvents) {
        GIOLogError(@"-sendEventsOfChannel_unsafe: error : fail to build raw events");
        return;
    }

    id<GrowingEventNetworkService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
    if (!service) {
        GIOLogError(@"-sendEventsOfChannel_unsafe: error : no network service support");
        return;
    }

    channel.isUploading = YES;
    NSObject<GrowingRequestProtocol> *eventRequest = [[GrowingEventRequest alloc] initWithEvents:rawEvents];
    [service sendRequest:eventRequest completion:^(NSHTTPURLResponse *_Nonnull httpResponse, NSData *_Nonnull data, NSError *_Nonnull error) {
        [GrowingDispatchManager dispatchInGrowingThread:^{
            channel.isUploading = NO;
            
            if (error) {
                return;
            }
            
            if ((httpResponse.statusCode >= 200 && httpResponse.statusCode < 400) || httpResponse.statusCode == 413) {
                if (isViaCellular) {
                    if ([eventRequest respondsToSelector:@selector(outsize)]) {
                        self.uploadEventSize += eventRequest.outsize;
                    }
                }
                
                if (httpResponse.statusCode != 413) {
                    for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
                        if ([obj respondsToSelector:@selector(growingEventManagerEventsDidSend:
                                                              request:channel:)]) {
                            [obj growingEventManagerEventsDidSend:events request:eventRequest channel:channel];
                        }
                    }
                }
                
                [self removeEvents_unsafe:events forChannel:channel];
                
                // 如果剩余数量 大于单包数量  则直接发送
                if (channel.db.countOfEvents >= kGrowingMaxBatchSize) {
                    [self sendEventsInstantWithChannel:channel];
                }
            } else if (httpResponse.statusCode == 403) {
                [GrowingNetworkPreflight sendPreflight];
            }
        }];
    }];
}

#pragma mark Event Persist

- (void)writeToDatabaseWithEvent:(GrowingBaseEvent *)event {
#if defined(DEBUG) && DEBUG
    GIOLogDebug(@"save: event, type is %@\n%@",
                event.eventType,
                [event.toDictionary growingHelper_beautifulJsonString]);
#endif
    NSString *eventType = event.eventType;

    if (!event) {
        return;
    }

    GrowingEventChannel *eventChannel = self.currentEventChannelMap[eventType];
    NSString *uuidString = [NSUUID UUID].UUIDString;
    id<GrowingEventPersistenceProtocol> waitForPersist = [eventChannel.db persistenceEventWithEvent:event
                                                                                               uuid:uuidString];
    [eventChannel.db setEvent:waitForPersist forKey:uuidString];

    if (GrowingEventSendPolicyInstant & event.sendPolicy) {
        [self sendEventsInstantWithChannel:eventChannel];
#if defined(DEBUG) && DEBUG
    } else {
        BOOL debugEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.debugEnabled;
        if (debugEnabled) {
            [self sendEventsInstantWithChannel:eventChannel];
        }
#endif
    }
}

- (void)flushDB {
    [self.timingEventDB flush];
    [self.timingEventDB_PB flush];
}

- (void)removeEvents_unsafe:(NSArray<__kindof id<GrowingEventPersistenceProtocol>> *)events
                 forChannel:(GrowingEventChannel *)channel {
    for (NSInteger i = 0; i < events.count; i++) {
        [channel.db setEvent:nil forKey:events[i].eventUUID];
    }
}

- (NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsToBeUploadUnsafe:(GrowingEventChannel *)channel
                                                                     policy:(NSUInteger)mask {
    return [channel.db getEventsByCount:kGrowingMaxBatchSize limitSize:2 * kGrowingUnit_MB policy:mask];
}

#pragma mark Event Log

- (void)prettyLogForEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
               withChannel:(GrowingEventChannel *)channel {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (id<GrowingEventPersistenceProtocol> event in events) {
        [arrayM addObject:event.toJSONObject];
    }
    GIOLogVerbose(@"(channel = %@, events = %@)\n", channel.name, arrayM);
}

#pragma mark - Interceptor

- (void)addInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor {
    if (!interceptor) {
        return;
    }
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.allInterceptor addObject:interceptor];
    }];
}

- (void)removeInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor {
    if (!interceptor) {
        return;
    }
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.allInterceptor removeObject:interceptor];
    }];
}

#pragma mark - Setter & Getter

- (unsigned long long)uploadEventSize {
    return [GrowingDataTraffic cellularNetworkUploadEventSize];
}

- (void)setUploadEventSize:(unsigned long long)uploadEventSize {
    [GrowingDataTraffic cellularNetworkStorageEventSize:uploadEventSize];
}

@end
