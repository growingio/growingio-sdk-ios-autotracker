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
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

static const NSUInteger kGrowingMaxDBCacheSize = 100;  // default: write to DB as soon as there are 100 events
static const NSUInteger kGrowingMaxBatchSize = 500;    // default: send no more than 500 events in every batch
static const NSUInteger kGrowingUnit_MB = 1024 * 1024;

/// 读取事件所属的数据源：优先使用持久化对象直接提供的字段，未实现时才转换整条事件
static NSString *GrowingDataSourceIdOfEvent(id<GrowingEventPersistenceProtocol> event) {
    id dataSourceId = nil;
    if ([(id)event respondsToSelector:@selector(dataSourceId)]) {
        dataSourceId = event.dataSourceId;
    } else {
        NSDictionary *jsonObject = [event toJSONObject];
        dataSourceId = [jsonObject isKindOfClass:NSDictionary.class] ? jsonObject[@"dataSourceId"] : nil;
    }
    return [dataSourceId isKindOfClass:NSString.class] && [dataSourceId length] > 0 ? dataSourceId : nil;
}

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
            // 上次运行中查不到上报地址而被挂起的事件，在本次启动的映射下重新判断
            [self resumeSuspendedEvents_unsafe];

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

- (void)switchToAccountId:(NSString *)accountId dataSourceId:(NSString *)dataSourceId {
    NSString *account = [accountId copy];
    NSString *source = [dataSourceId copy];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self switchToAccountId_unsafe:account dataSourceId:source dataCollectionServerHost:nil];
    }];
}

- (void)switchToAccountId:(NSString *)accountId
                dataSourceId:(NSString *)dataSourceId
    dataCollectionServerHost:(NSString *)serverHost {
    NSString *account = [accountId copy];
    NSString *source = [dataSourceId copy];
    NSString *host = [serverHost copy];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self switchToAccountId_unsafe:account dataSourceId:source dataCollectionServerHost:host];
    }];
}

- (BOOL)switchToAccountId_unsafe:(NSString *)accountId
                    dataSourceId:(NSString *)dataSourceId
        dataCollectionServerHost:(NSString *)serverHost {
    GrowingConfigurationManager *manager = GrowingConfigurationManager.sharedInstance;
    if (!self.allEventChannels.count || !manager.trackConfiguration) {
        GIOLogError(@"Routing switch rejected account=%@ source=%@ reason=SDK is not initialized",
                    accountId,
                    dataSourceId);
        return NO;
    }
    NSString *previousAccountId = manager.trackConfiguration.accountId;
    NSString *previousDataSourceId = manager.trackConfiguration.dataSourceId;
    BOOL wasRegistered = [manager routeForDataSourceId:dataSourceId] != nil;
    NSError *error = nil;
    BOOL changed = [manager switchToAccountId:accountId
                                 dataSourceId:dataSourceId
                     dataCollectionServerHost:serverHost
                                        error:&error];
    if (!changed) {
        if (error) {
            GIOLogError(@"Routing switch rejected account=%@ source=%@ reason=%@",
                        accountId,
                        dataSourceId,
                        error.localizedDescription);
        }
        return NO;
    }

    NSString *currentAccountId = manager.trackConfiguration.accountId;
    if (![currentAccountId isEqualToString:previousAccountId]) {
        // 登录用户属于原项目，切换项目时清除；须在生成 VISIT 之前，避免新会话带上原项目的用户
        [GrowingSession.currentSession setLoginUserId:nil];
    }
    [GrowingSession.currentSession refreshSessionId];
    [GrowingSession.currentSession generateVisit];
    GIOLogInfo(@"Routing switch %@/%@ -> %@/%@ session=%@",
               previousAccountId,
               previousDataSourceId,
               currentAccountId,
               dataSourceId,
               GrowingSession.currentSession.sessionId);
    if (!wasRegistered) {
        // 新注册了路由：恢复可能已可发送的事件，沿用原有上传触发时机。
        [self resumeSuspendedEvents_unsafe];
    }
    return YES;
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

    NSMutableDictionary<NSString *, NSMutableArray<id<GrowingEventPersistenceProtocol>> *> *eventsBySource =
        [NSMutableDictionary dictionary];
    NSMutableArray<NSArray<id<GrowingEventPersistenceProtocol>> *> *groups = [NSMutableArray array];
    NSMutableArray<NSString *> *unroutableKeys = [NSMutableArray array];
    NSMutableSet<NSString *> *unroutableSources = [NSMutableSet set];
    for (id<GrowingEventPersistenceProtocol> event in events) {
        NSString *source = GrowingDataSourceIdOfEvent(event);
        if (!source || ![GrowingConfigurationManager.sharedInstance routeForDataSourceId:source]) {
            if (event.eventUUID.length) {
                [unroutableKeys addObject:event.eventUUID];
            }
            [unroutableSources addObject:source ?: @"(none)"];
            continue;
        }
        NSMutableArray *group = eventsBySource[source];
        if (!group) {
            group = [NSMutableArray array];
            eventsBySource[source] = group;
            [groups addObject:group];
        }
        [group addObject:event];
    }
    if (unroutableKeys.count) {
        // 查不到路由的事件挂起保留，不再占用发送名额；注册对应路由或下次启动时恢复，过期后照常清理
        GIOLogWarn(@"Suspend %lu events without collection URL (channel = %@, sources = %@)",
                   (unsigned long)unroutableKeys.count,
                   channel.name,
                   unroutableSources.allObjects);
        [channel.db suspendEventsForKeys:unroutableKeys];
    }
    if (!groups.count) return;

    channel.isUploading = YES;
    [self sendEventGroups_unsafe:groups channel:channel isViaCellular:isViaCellular allSucceeded:YES];
}

- (NSData *)buildRawEventsFromEvents:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
                             channel:(GrowingEventChannel *)channel {
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
            GIOLogError(@"%s error : no event database service support", __func__);
            return nil;
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

    return rawEvents;
}

- (void)sendEventGroups_unsafe:(NSArray<NSArray<id<GrowingEventPersistenceProtocol>> *> *)groups
                       channel:(GrowingEventChannel *)channel
                 isViaCellular:(BOOL)isViaCellular
                  allSucceeded:(BOOL)allSucceeded {
    if (!groups.count) {
        channel.isUploading = NO;
        // 沿用原来的续传条件；失败批次等待下一次上传触发。
        if (allSucceeded && channel.db.countOfEvents >= kGrowingMaxBatchSize) {
            [self sendEventsInstantWithChannel:channel];
        }
        return;
    }
    NSArray<id<GrowingEventPersistenceProtocol>> *events = groups.firstObject;
    NSArray *remainingGroups = [groups subarrayWithRange:NSMakeRange(1, groups.count - 1)];
    NSString *source = GrowingDataSourceIdOfEvent(events.firstObject);
    // 路由只增不减，分组时能查到的路由在发送时仍然存在
    GrowingDataSourceRoute *route = [GrowingConfigurationManager.sharedInstance routeForDataSourceId:source];

#ifdef DEBUG
    [self prettyLogForEvents:events withChannel:channel];
#endif

    NSData *rawEvents = [self buildRawEventsFromEvents:events channel:channel];
    if (!rawEvents) {
        GIOLogError(@"%s error : fail to build raw events", __func__);
        channel.isUploading = NO;
        return;
    }

    id<GrowingEventNetworkService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
    if (!service) {
        GIOLogError(@"%s error : no network service support", __func__);
        channel.isUploading = NO;
        return;
    }

    // 按事件所属数据源的路由确定项目和采集地址，而不是当前的项目和数据源
    NSObject<GrowingRequestProtocol> *eventRequest =
        [[GrowingEventRequest alloc] initWithEvents:rawEvents
                                         serverHost:route.dataCollectionServerHost
                                          accountId:route.accountId];
    GIOLogDebug(@"Upload source=%@ channel=%@ url=%@", source, channel.name, eventRequest.absoluteURL);
    __block BOOL completed = NO;
    [service
        sendRequest:eventRequest
         completion:^(NSHTTPURLResponse *httpResponse, NSData *data, NSError *error) {
             [GrowingDispatchManager dispatchInGrowingThread:^{
                 if (completed) return;
                 completed = YES;
                 BOOL success = !error && httpResponse.statusCode >= 200 && httpResponse.statusCode < 300;
                 if (success) {
                     if (isViaCellular && [eventRequest respondsToSelector:@selector(outsize)]) {
                         self.uploadEventSize += eventRequest.outsize;
                     }
                     for (NSObject<GrowingEventInterceptor> *obj in self.allInterceptor) {
                         if ([obj respondsToSelector:@selector(growingEventManagerEventsDidSend:request:channel:)]) {
                             [obj growingEventManagerEventsDidSend:events request:eventRequest channel:channel];
                         }
                     }
                     [self removeEvents_unsafe:events forChannel:channel];
                 } else {
                     GIOLogDebug(@"Upload failed source=%@ url=%@ error=%@ status=%ld",
                                 source,
                                 eventRequest.absoluteURL,
                                 error,
                                 (long)httpResponse.statusCode);
                 }
                 [self sendEventGroups_unsafe:remainingGroups
                                      channel:channel
                                isViaCellular:isViaCellular
                                 allSucceeded:allSucceeded && success];
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

- (void)resumeSuspendedEvents_unsafe {
    // 多个通道可能共用同一个数据库，每个数据库只恢复一次
    NSHashTable<GrowingEventDatabase *> *databases = [NSHashTable weakObjectsHashTable];
    for (GrowingEventChannel *channel in self.allEventChannels) {
        if (channel.db && ![databases containsObject:channel.db]) {
            [databases addObject:channel.db];
            [channel.db resumeAllSuspendedEvents];
        }
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
