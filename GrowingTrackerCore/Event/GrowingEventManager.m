//
//  GrowingEventManager.m
//  GrowingTracker
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


#import <UIKit/UIKit.h>
#import "GrowingEventPersistence.h"
#import "GrowingEventManager.h"
#import "GrowingDeviceInfo.h"
#import "NSString+GrowingHelper.h"
#import "GrowingNetworkInterfaceManager.h"
#import "GrowingDispatchManager.h"
#import "GrowingDataTraffic.h"
#import "GrowingFileStorage.h"
#import "GrowingEventOptions.h"
#import "GrowingEventChannel.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingEventPVRequest.h"
#import "GrowingEventCstmRequest.h"
#import "GrowingEventOtherRequest.h"
#import "GrowingNetworkManager.h"
#import "GrowingBaseEvent+SendPolicy.h"
#import "GrowingConfigurationManager.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingSession.h"
#import "NSDictionary+GrowingHelper.h"

static NSUInteger const kGrowingMaxQueueSize = 10000; // default: max event queue size there are 10000 events
static NSUInteger const kGrowingFillQueueSize = 1000; // default: determine when event queue is filled from DB
static NSUInteger const kGrowingMaxDBCacheSize = 100; // default: write to DB as soon as there are 300 events
static NSUInteger const kGrowingMaxBatchSize = 500; // default: send no more than 500 events in every batch;

static const NSUInteger kGrowingUnit_MB                 = 1024*1024;

@interface GrowingEventManager()

@property (nonatomic, strong) NSHashTable *allInterceptor;
@property (nonatomic, strong) NSLock *interceptorLock;

@property (nonatomic, strong)   NSMutableArray<GrowingEventPersistence *> * eventQueue;
@property (nonatomic, readonly, strong)   NSArray<GrowingEventChannel *> * allEventChannels;
@property (nonatomic, readonly, strong)   NSDictionary<NSString *, GrowingEventChannel *> * eventChannelDict;
@property (nonatomic, readonly, strong)   GrowingEventChannel * otherEventChannel;
@property (nonatomic, readonly) dispatch_queue_t  eventDispatch;
@property (nonatomic, strong)   dispatch_source_t reportTimer;

@property (nonatomic, strong) GrowingEventDataBase *timingEventDB;
@property (nonatomic, strong) GrowingEventDataBase *realtimeEventDB;

@property (nonatomic, assign) unsigned long long uploadEventSize;
@property (nonatomic, assign) unsigned long long uploadLimitOfCellular;

@property (nonatomic, copy) NSString *projectId;
@property (nonatomic, assign) NSUInteger packageNum;

@property (nonatomic, strong) GrowingEventOptions *eventOptions;
@property (nonatomic, strong) NSMutableArray *cacheArray;

@end

@implementation GrowingEventManager

- (void)addInterceptor:(NSObject<GrowingEventInterceptor>* _Nonnull)interceptor {
    if (!interceptor) {
        return;
    }
    [self.interceptorLock lock];
    [self.allInterceptor addObject:interceptor];
    [self.interceptorLock unlock];
}

- (void)removeInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor {
    if (!interceptor) {
        return;
    }
    [self.interceptorLock lock];
    [self.allInterceptor removeObject:interceptor];
    [self.interceptorLock unlock];
}

static GrowingEventManager *shareinstance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareinstance = [[self alloc] initWithName:@"growing"];
    });
    return shareinstance;
}

- (instancetype)initWithName:(NSString *)name {
    
    if (self = [super init]) {
        _allInterceptor = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _interceptorLock = [[NSLock alloc] init];
        _packageNum = kGrowingMaxBatchSize;
        _cacheArray = [[NSMutableArray alloc] init];
        [GrowingDispatchManager dispatchInLowThread:^{
            // db
            self.timingEventDB = [GrowingEventDataBase databaseWithPath:[GrowingFileStorage getTimingDatabasePath]
                                                                name:[name stringByAppendingString:@"timingevent"]];
            self.timingEventDB.autoFlushCount = kGrowingMaxDBCacheSize;
            
            self.realtimeEventDB = [GrowingEventDataBase databaseWithPath:[GrowingFileStorage getRealtimeDatabasePath]
                                                                   name:[name stringByAppendingString:@"realtimevent"]];
            
            [self.timingEventDB vacuum];
            
            [self cleanExpiredData_unsafe];
        }];

        // timer
        self.reportTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.eventDispatch);
//        CGFloat configInterval = [GrowingInstance sharedInstance].configuration.dataUploadInterval;
        CGFloat configInterval = 0;
        CGFloat dataUploadInterval = configInterval >= 5 ? configInterval : 5; // at least 5 seconds
        dispatch_source_set_timer(self.reportTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5), // first upload
                                  NSEC_PER_SEC * dataUploadInterval,
                                  NSEC_PER_SEC * 1);
        dispatch_source_set_event_handler(self.reportTimer, ^{
            [self timerSendEvent];
        });
        dispatch_resume(_reportTimer);
        
        [GrowingDispatchManager dispatchInLowThread:^{
            // load eventQueue for the first time
            [self reloadFromDB_unsafe];
        }];
        _allEventChannels = [GrowingEventChannel buildAllEventChannels];
        
        _eventChannelDict = [GrowingEventChannel eventChannelMapFromAllChannels:_allEventChannels];
        // all other events got to this category
        _otherEventChannel = [GrowingEventChannel otherEventChannelFromAllChannels:_allEventChannels];
        _eventOptions = [[GrowingEventOptions alloc] init];
        [_eventOptions readEventOptions];
        
    }
    return self;
}

- (void)cleanExpiredData_unsafe {
    [self.timingEventDB cleanExpiredDataIfNeeded];
    [self.realtimeEventDB cleanExpiredDataIfNeeded];
}

- (void)reloadFromDB_unsafe {
    self.eventQueue = nil;
    [self loadFromDB_unsafe];
}

- (unsigned long long)uploadEventSize {
    return [GrowingDataTraffic cellularNetworkUploadEventSize];
}

- (void)setUploadEventSize:(unsigned long long)uploadEventSize {
    [GrowingDataTraffic cellularNetworkStorgeEventSize:uploadEventSize];
}

- (void)dbErrorWithError:(NSError*)error {
    if (!error) {  return; }
    GIOLogError(@"dbError: %@", error.localizedDescription);
}

- (void)loadFromDB_unsafe {
    NSInteger keyCount = self.timingEventDB.countOfEvents;
    NSInteger qCount = self.eventQueue.count;
    
    if (self.eventQueue && qCount == keyCount) {
        return;
    }
    
    self.eventQueue = [[NSMutableArray alloc] init];
    
    NSError *error1 = [self.timingEventDB enumerateKeysAndValuesUsingBlock:^(NSString *key, NSString *value, NSString *type, BOOL *stop) {
        
        GrowingEventPersistence *event = [[GrowingEventPersistence alloc] initWithUUID:key eventType:type jsonString:value];
        [self.eventQueue addObject:event];
        
        if (self.eventQueue.count >= kGrowingMaxQueueSize) {
            *stop = YES;
        }
    }];
    [self.timingEventDB handleDatabaseError:error1];
}

- (void)timerSendEvent {
    [self sendAllChannelEvents];
}

- (void)postEventBuidler:(GrowingBaseBuilder* _Nullable)builder {
    
    if (![GrowingSession currentSession].createdSession) {
        [[GrowingSession currentSession] forceReissueVisit];
    }
    
    [GrowingDispatchManager dispatchInMainThread:^{
        
        [builder readPropertyInMainThread];
        
        for (NSObject<GrowingEventInterceptor> * obj in self.allInterceptor) {
            if ([obj respondsToSelector:@selector(growingEventManagerEventWillBuild:)]) {
                [obj growingEventManagerEventWillBuild:builder];
            }
        }
        //TODO: active在page事件之后的情况处理,添加一个interceptor
        GrowingBaseEvent *event = builder.build;
        
        for (NSObject<GrowingEventInterceptor> * obj in self.allInterceptor) {
            if ([obj respondsToSelector:@selector(growingEventManagerEventDidBuild:)]) {
                [obj growingEventManagerEventDidBuild:event];
            }
        }
        [self writeToDatabaseWithEvent:event];
    }];
}

//- (void)handleEvent:(GrowingBaseEvent *)event {
//    GrowingBaseEvent *dbEvent = event;
//    // cstm按函数实际触发为标准
//    if ([event.eventType isEqualToString:GrowingEventTypeCustom] && [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
//        __weak GrowingEventManager *weakSelf = self;
//        [GrowingDispatchManager dispatchInLowThread:^{
//            GrowingEventManager *strongSelf = weakSelf;
//            [strongSelf writeToDatabaseWithEvent:dbEvent];
//        }];
//        return;
//    }
//
//    // 因为在app被kill之后,iOS有技术手段可以唤醒app(此时app会relaunched触发vc生命周期,但不会调用didBecomeActive)
//    // 所以在becomeActive之前 把产生的event缓存起来(因app唤醒后,再到用户打开之前,不确定app是否是被杀掉的),所以需要把之前缓存事件的tm ptm s字段改写,防止访问时长的问题
//    if (self.shouldCacheEvent) {
//
//        [self.cacheArray addObject:dbEvent];
//
//    } else {
//        static BOOL resetPagetm = NO;
//        //TODO:处理特别情况
////        if (!resetPagetm && [GrowingEventManager shareInstance].lastPageEvent) {
////            GrowingPageEvent *lastPageEvent = [GrowingEventManager shareInstance].lastPageEvent;
////            lastPageEvent.timestamp = event.timestamp;
////            lastPageEvent.sessionId = event.sessionId;
////        }
//        resetPagetm = YES;
//
//        __weak GrowingEventManager *weakSelf = self;
//        [GrowingDispatchManager dispatchInLowThread:^{
//            GrowingEventManager *strongSelf = weakSelf;
//            if (strongSelf.cacheArray.count) {
////                for (GrowingBaseEvent *cacheEvent in strongSelf.cacheArray) {
////                    cacheEvent.timestamp = dbEvent.timestamp;
////                    cacheEvent.sessionId = dbEvent.sessionId;
////
////                    [strongSelf writeToDatabaseWithEvent:cacheEvent];
////                }
//
//                [strongSelf.cacheArray removeAllObjects];
//            }
//            [strongSelf writeToDatabaseWithEvent:dbEvent];
//        }];
//    }
//}

- (void)writeToDatabaseWithEvent:(GrowingBaseEvent *)event {
    GIOLogDebug(@"save: event, type is %@\n%@", event.eventType, [event.toDictionary growingHelper_beautifulJsonString]);
    NSString *eventType = event.eventType;

    if (!event) {return;}

    
    GrowingEventChannel * eventChannel = self.eventChannelDict[eventType] ?: self.otherEventChannel;
    BOOL isCustomEvent = eventChannel.isCustomEvent;
    NSString *uuidString = [NSUUID UUID].UUIDString;
    GrowingEventPersistence *waitForPersist = [GrowingEventPersistence persistenceEventWithEvent:event uuid:uuidString];
    
    if (!isCustomEvent) // custom event never goes into self.eventQueue, event can not be nil
    {
        [self.eventQueue addObject:waitForPersist];
    }
    
    NSError *error = nil;
    
    GrowingEventDataBase *db = (isCustomEvent ? self.realtimeEventDB : self.timingEventDB);
    
    [db setEvent:waitForPersist forKey:uuidString error:&error];
    
    [db handleDatabaseError:error];
    
    if (GrowingEventSendPolicyInstant == event.sendPolicy) { // send event instantly
        [self sendEventsInstantWithChannel:eventChannel];
    }
}

- (void)flushDB {
    [self.timingEventDB flush];
}

- (void)removeEvents_unsafe:(NSArray<__kindof GrowingEventPersistence *>*)events forChannel:(GrowingEventChannel *)channel {
    
    if (channel.isCustomEvent) {
        
        for (NSInteger i = 0 ; i < events.count ; i++) {
            [self.realtimeEventDB setEvent:nil forKey:events[i].eventUUID];
        }
        
    } else {
        [self.eventQueue removeObjectsInArray:events];
        
        for (NSInteger i = 0 ; i < events.count; i++) {
            [self.timingEventDB setEvent:nil forKey:events[i].eventUUID];
        }
        
        if (self.eventQueue.count <= kGrowingFillQueueSize) {
            [self loadFromDB_unsafe];
        }
    }
}

// 外部调用
- (void)sendAllChannelEvents {
    [GrowingDispatchManager dispatchInLowThread:^{
        [self flushDB];
        for (GrowingEventChannel * channel in self.allEventChannels) {
            [self sendEventsOfChannel_unsafe:channel];
        }
    }];
}

- (void)sendEventsInstantWithChannel:(GrowingEventChannel *)channel {
    [GrowingDispatchManager dispatchInLowThread:^{
        [self flushDB];
        [self sendEventsOfChannel_unsafe:channel];
    }];
}

// 非安全 发送日志
- (void)sendEventsOfChannel_unsafe:(GrowingEventChannel *)channel {
    if (self.ai.length == 0) {
        GIOLogError(@"No valid ProjectId (channel = %zd).", [self.allEventChannels indexOfObject:channel]);
        return;
    }
    
    if (!channel.isCustomEvent && self.eventQueue.count == 0) {
        return;
    }
    
    if (channel.isUploading) {
        return;
    }
    
    [[GrowingNetworkInterfaceManager sharedInstance] updateInterfaceInfo];

    BOOL isViaCellular = NO;
    // 没网络 直接返回
    if (![GrowingNetworkInterfaceManager sharedInstance].isReachable) {
        // 没网络 直接返回
        GIOLogDebug(@"No availabel Internet connection, delay upload (channel = %zd).", [self.allEventChannels indexOfObject:channel]);
        return;
    }
    
    if (!GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled) {
        GIOLogDebug(@"Data upload disabled, if you want upload event data, please setting dataUploadEnabled to YES!");
        return;
    }
    
    if ([GrowingNetworkInterfaceManager sharedInstance].WiFiValid) {
        // do nothing
    } else if (self.uploadEventSize < self.uploadLimitOfCellular) {
        GIOLogDebug(@"Upload key data with mobile network (channel = %zd).", [self.allEventChannels indexOfObject:channel]);
        isViaCellular = YES;
    } else {
        GIOLogDebug(@"Mobile network is forbidden. upload later (channel = %zd).", [self.allEventChannels indexOfObject:channel]);
        return;
    }
    
    NSArray <GrowingEventPersistence *> *events = [self getEventsToBeUploadUnsafe:channel];
    if (events.count == 0) { return; }
    
    channel.isUploading = YES;
    
    NSArray <NSString *> *rawEvents = [GrowingEventPersistence buildRawEventsFromEvents:events];
    
#ifdef DEBUG
    [self prettyLogForEvents:rawEvents withChannel:channel];
#endif
    
    GrowingEventRequest *eventRequest = nil;
    if (channel.isCustomEvent) {
        eventRequest = [[GrowingEventCstmRequest alloc] initWithEvents:rawEvents];
    } else if (!channel.isCustomEvent && channel != self.otherEventChannel) {
        eventRequest = [[GrowingEventPVRequest alloc] initWithEvents:rawEvents];
    } else {
        eventRequest = [[GrowingEventOtherRequest alloc] initWithEvents:rawEvents];
    }
    
    [[GrowingNetworkManager shareManager] sendRequest:eventRequest
                                              success:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data) {
        
        [GrowingDispatchManager dispatchInLowThread:^{
            
            if (isViaCellular) {
                self.uploadEventSize += eventRequest.outsize;
            }
            [self removeEvents_unsafe:events forChannel:channel];
            channel.isUploading = NO;
            
            // 如果剩余数量 大于单包数量  则直接发送
            if (channel.isCustomEvent && self.realtimeEventDB.countOfEvents >= self.packageNum) {
                [self sendAllChannelEvents];
            }
            
            if (!channel.isCustomEvent && self.eventQueue.count >= self.packageNum) {
                [self sendAllChannelEvents];
            }
        }];
        
    } failure:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data, NSError * _Nonnull error) {
        [GrowingDispatchManager dispatchInLowThread:^{
            channel.isUploading = NO;
        }];
    }];
}

- (void)prettyLogForEvents:(NSArray <NSString *> *)events withChannel:(GrowingEventChannel *)channel {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSString *rawEvent in events) {
        [arrayM addObject:[rawEvent growingHelper_jsonObject]];
    }
    GIOLogDebug(@"(channel = %@, events = %@)\n", channel.urlTemplate, arrayM);
}

- (NSArray<GrowingEventPersistence *> *)getEventsToBeUploadUnsafe:(GrowingEventChannel *)channel {
   
    if (channel.isCustomEvent) {
        return [self.realtimeEventDB getEventsWithPackageNum:self.packageNum];
    } else {
        NSMutableArray<GrowingEventPersistence *> * events = [[NSMutableArray alloc] initWithCapacity:self.eventQueue.count];
        NSArray<NSString *> * eventTypes = channel.eventTypes;
        const NSUInteger eventTypesCount = eventTypes.count;
        NSUInteger count = 0;
        for (GrowingEventPersistence * e in self.eventQueue) {
            NSString *type = e.eventType;
            // 反向匹配（排除法）event of other type not match eventChannelDict`s all t
            if (   (eventTypesCount == 0 && self.eventChannelDict[type] == nil)
                || (eventTypesCount > 0 && [eventTypes indexOfObject:type] != NSNotFound)) // 正向匹配
            {
                [events addObject:e];
                count++;
                if (count >= self.packageNum) {
                    break;
                }
            }
        }
        return events;
    }
}

- (void)clearAllEvents {
    self.eventQueue = [[NSMutableArray alloc] init];
    [GrowingDispatchManager dispatchInLowThread:^() {
        [self.timingEventDB clearAllItems];
        [self.realtimeEventDB clearAllItems];
    }];
}

- (NSString *)ai {
    return GrowingConfigurationManager.sharedInstance.trackConfiguration.projectId;
}

- (dispatch_queue_t)eventDispatch {
    static dispatch_queue_t  _eventDispatch = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _eventDispatch = dispatch_queue_create("io.growing", NULL);
        dispatch_set_target_queue(_eventDispatch,
                                  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    });
    
    return _eventDispatch;
}

@end



