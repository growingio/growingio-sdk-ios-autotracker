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
#import "GrowingTrackerCore/Network/Request/GrowingEventRequest.h"
#import "GrowingTrackerCore/Public/GrowingBaseEvent.h"
#import "GrowingTrackerCore/Public/GrowingEventFilter.h"
#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Public/GrowingModuleManager.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingULTimeUtil.h"

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

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<GrowingEventChannel *> *> *routedChannels;
@property (nonatomic, assign) NSUInteger uploadCount;
@property (nonatomic, assign) NSUInteger nextSourceIndex;
@property (nonatomic, assign) BOOL processingEvent;
@property (nonatomic, assign) BOOL configured;
@property (nonatomic, assign) BOOL schedulePending;
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
        _routedChannels = [NSMutableDictionary dictionary];
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
            self.configured = YES;
        }];
    });
}

- (NSArray<GrowingEventChannel *> *)channelsForDataSourceId:(NSString *)dataSourceId {
    NSArray *existing = self.routedChannels[dataSourceId];
    if (existing) return existing;
    NSMutableArray *channels = [NSMutableArray array];
    for (GrowingEventChannel *template in self.allEventChannels) {
        if (!template.db) continue;
        GrowingEventChannel *channel = [GrowingEventChannel new];
        channel.name = template.name;
        channel.eventTypes = template.eventTypes;
        channel.persistenceType = template.persistenceType;
        channel.isRealtimeEvent = template.isRealtimeEvent;
        channel.db = template.db;
        channel.dataSourceId = dataSourceId;
        [channels addObject:channel];
    }
    self.routedChannels[dataSourceId] = channels;
    return channels;
}

- (void)updateDataSourceId:(NSString *)dataSourceId
    dataCollectionServerHost:(NSString *)serverHost
                  completion:(void (^)(NSError *))completion {
    NSString *source = [dataSourceId isKindOfClass:NSString.class] ? [dataSourceId copy] : nil;
    NSString *host = [serverHost copy];
    if (self.dataSourcePageBuilder && !NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDataSourceId:source dataCollectionServerHost:host completion:completion];
        });
        return;
    }
    GrowingBaseBuilder *pageBuilder = self.dataSourcePageBuilder ? self.dataSourcePageBuilder() : nil;
    [GrowingDispatchManager enqueueInGrowingThread:^{
        GrowingConfigurationManager *manager = GrowingConfigurationManager.sharedInstance;
        GrowingTrackConfiguration *config = manager.trackConfiguration;
        NSString *normalized = host ? [GrowingConfigurationManager normalizedServerHost:host] : nil;
        NSString *registered = source.length ? [manager serverHostForDataSourceId:source] : nil;
        NSString *reason = nil;
        if (!self.configured || !config) {
            reason = @"SDK is not initialized";
        } else if (!source.length || (host && !normalized) || (!registered && !normalized)) {
            reason = @"Invalid data source or collection URL";
        } else if (registered && normalized && ![registered isEqualToString:normalized]) {
            reason = @"The data source already has a different collection URL";
        } else if (![source isEqualToString:config.dataSourceId]) {
            for (GrowingEventChannel *channel in self.allEventChannels) {
                BOOL required = config.useProtobuf == (channel.persistenceType == GrowingEventPersistenceTypeProtobuf);
                if ((required && !channel.db) || (channel.db && !channel.db.supportsDataSourceRouting)) {
                    reason = @"Database service does not support data source routing";
                    break;
                }
            }
        }
        if (reason) {
            NSError *error = [NSError errorWithDomain:@"com.growing.routing"
                                                 code:2
                                             userInfo:@{NSLocalizedDescriptionKey: reason}];
            GIOLogError(@"Routing switch rejected source=%@ reason=%@", source, reason);
            if (completion)
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(error);
                });
            return;
        }
        if (![source isEqualToString:config.dataSourceId]) {
            NSDictionary *oldContext = manager.eventContext;
            NSMutableDictionary *mapping = config.serverHostMapping.mutableCopy;
            mapping[source] = registered ?: normalized;
            config.serverHostMapping = mapping;
            config.dataSourceId = source;
            config.dataCollectionServerHost = mapping[source];
            manager.routingSequence++;
            [GrowingSession.currentSession refreshSessionId];
            NSDictionary *newContext = manager.eventContext;
            [GrowingSession.currentSession generateVisit];
            if (pageBuilder) {
                pageBuilder.setTimestamp(GrowingULTimeUtil.currentTimeMillis);
                [self postEventBuilder:pageBuilder];
            }
            self.processingEvent = YES;
            [[GrowingModuleManager sharedInstance]
                   triggerEvent:GrowingMDataSourceChangedEvent
                withCustomParam:@{@"oldContext": oldContext, @"newContext": newContext}];
            self.processingEvent = NO;
            GIOLogInfo(@"Routing switch %@ -> %@ session=%@ sequence=%@",
                       oldContext[@"dataSourceId"],
                       source,
                       newContext[@"sessionId"],
                       newContext[@"sequence"]);
        }
        if (completion)
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
    }];
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
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (!trackConfiguration.dataCollectionEnabled) {
            GIOLogDebug(@"Data collection is disabled, event can not build");
            return;
        }

        if ([GrowingEventFilter isFilterEvent:builder.eventType]) {
            return;
        }

        if (!builder.eventContext && ![GrowingSession currentSession].isSentVisitAfterRefreshSessionId) {
            [[GrowingSession currentSession] generateVisit];
        }

        self.processingEvent = YES;
        for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
            if ([obj respondsToSelector:@selector(growingEventManagerEventTriggered:)]) {
                [obj growingEventManagerEventTriggered:builder.eventType];
            }
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
        self.processingEvent = NO;
    };
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (self.processingEvent) {
            [GrowingDispatchManager enqueueInGrowingThread:block];
        } else {
            block();
        }
    }];
}

- (void)sendAllChannelEvents {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self flushDB];
        NSString *currentSource = GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId;
        NSMutableSet *sources = [NSMutableSet set];
        if (currentSource.length) [sources addObject:currentSource];
        for (GrowingEventChannel *channel in self.allEventChannels) {
            [channel.db cleanExpiredDataIfNeeded];
            NSDictionary *counts = channel.db.eventCountsByDataSourceId;
            if (counts.count) GIOLogDebug(@"Pending cache channel=%@ counts=%@", channel.name, counts);
            [sources addObjectsFromArray:channel.db.dataSourceIds ?: @[]];
        }
        for (NSString *source in self.routedChannels.allKeys) {
            if ([sources containsObject:source]) continue;
            BOOL uploading = NO;
            for (GrowingEventChannel *channel in self.routedChannels[source]) uploading |= channel.isUploading;
            if (!uploading) [self.routedChannels removeObjectForKey:source];
        }
        NSArray *ordered = [sources.allObjects sortedArrayUsingSelector:@selector(compare:)];
        if (!ordered.count) return;
        NSUInteger start = self.nextSourceIndex % ordered.count;
        self.nextSourceIndex = (start + 1) % ordered.count;
        // Visit every source once per pass, at most two in-flight requests per source.
        for (NSUInteger i = 0; i < ordered.count; i++) {
            NSString *source = ordered[(start + i) % ordered.count];
            if (![GrowingConfigurationManager.sharedInstance serverHostForDataSourceId:source]) {
                GIOLogDebug(@"Cached source %@ is not registered; upload paused until expiry", source);
                continue;
            }
            for (GrowingEventChannel *channel in [self channelsForDataSourceId:source]) {
                [self sendEventsOfChannel_unsafe:channel];
            }
        }
        for (GrowingEventChannel *channel in self.allEventChannels) [channel.db releaseIdleDatabase];
    }];
}

- (void)scheduleSend {
    if (self.schedulePending) return;
    self.schedulePending = YES;
    [GrowingDispatchManager enqueueInGrowingThread:^{
        self.schedulePending = NO;
        [self sendAllChannelEvents];
    }];
}

- (void)sendEventsInstantWithChannel:(GrowingEventChannel *)channel {
    [self scheduleSend];
}

// 非安全 发送日志
- (void)sendEventsOfChannel_unsafe:(GrowingEventChannel *)channel {
    if (channel.isUploading || self.uploadCount >= 4 || channel.nextRetryTime > NSDate.date.timeIntervalSince1970) {
        return;
    }
    NSUInteger sourceUploads = 0;
    for (GrowingEventChannel *other in self.routedChannels[channel.dataSourceId]) {
        if (other.isUploading) sourceUploads++;
    }
    if (sourceUploads >= 2) return;
    NSString *serverHost = [GrowingConfigurationManager.sharedInstance serverHostForDataSourceId:channel.dataSourceId];
    if (!serverHost.length) return;

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
    self.uploadCount++;
    NSObject<GrowingRequestProtocol> *eventRequest =
        [[GrowingEventRequest alloc] initWithEvents:rawEvents
                                         serverHost:serverHost
                                          accountId:trackConfiguration.accountId];
    GIOLogDebug(@"Upload source=%@ channel=%@ url=%@", channel.dataSourceId, channel.name, eventRequest.absoluteURL);
    __block BOOL completed = NO;
    [service
        sendRequest:eventRequest
         completion:^(NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {
             [GrowingDispatchManager enqueueInGrowingThread:^{
                 if (completed) return;
                 completed = YES;
                 channel.isUploading = NO;
                 self.uploadCount--;
                 if (!error && httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                     if (isViaCellular && [eventRequest respondsToSelector:@selector(outsize)]) {
                         self.uploadEventSize += eventRequest.outsize;
                     }
                     for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
                         if ([obj respondsToSelector:@selector(growingEventManagerEventsDidSend:request:channel:)]) {
                             [obj growingEventManagerEventsDidSend:events request:eventRequest channel:channel];
                         }
                     }
                     [self removeEvents_unsafe:events forChannel:channel];
                     channel.failureCount = 0;
                     channel.nextRetryTime = 0;
                 } else {
                     channel.failureCount = MIN(channel.failureCount + 1, 6);
                     channel.nextRetryTime =
                         NSDate.date.timeIntervalSince1970 + MIN(300, 5 * (1 << channel.failureCount));
                     GIOLogDebug(@"Upload failed source=%@ url=%@ error=%@ status=%ld",
                                 channel.dataSourceId,
                                 eventRequest.absoluteURL,
                                 error,
                                 (long)httpResponse.statusCode);
                 }
                 [self scheduleSend];
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

    GrowingEventChannel *eventChannel = nil;
    GrowingEventChannel *template = self.currentEventChannelMap[eventType];
    for (GrowingEventChannel *candidate in [self channelsForDataSourceId:event.dataSourceId ?: @""]) {
        if ([candidate.name isEqualToString:template.name]) {
            eventChannel = candidate;
            break;
        }
    }
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
    for (GrowingEventChannel *channel in self.allEventChannels) {
        [channel.db flush];
    }
}

- (void)removeEvents_unsafe:(NSArray<__kindof id<GrowingEventPersistenceProtocol>> *)events
                 forChannel:(GrowingEventChannel *)channel {
    for (NSInteger i = 0; i < events.count; i++) {
        [channel.db setEvent:nil forKey:events[i].eventUUID];
    }
}

- (NSArray<id<GrowingEventPersistenceProtocol>> *)getEventsToBeUploadUnsafe:(GrowingEventChannel *)channel
                                                                     policy:(NSUInteger)mask {
    return [channel.db getEventsByCount:kGrowingMaxBatchSize
                              limitSize:2 * kGrowingUnit_MB
                                 policy:mask
                           dataSourceId:channel.dataSourceId];
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
