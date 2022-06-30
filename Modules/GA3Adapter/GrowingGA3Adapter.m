//
//  GrowingGA3Adapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/31.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/GA3Adapter/Public/GrowingGA3Adapter.h"
#import "Modules/GA3Adapter/Public/GrowingTrackConfiguration+GA3Tracker.h"
#import "Modules/GA3Adapter/GrowingGA3Injector.h"
#import "Modules/GA3Adapter/GrowingGA3TrackerInfo.h"
#import "Modules/GA3Adapter/GrowingGA3Event.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Hook/GrowingAppLifecycle.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

GrowingMod(GrowingGA3Adapter)

static NSString *const kGA3UserIdKey = @"&uid";
static NSString *const kGA3ClientIdKey = @"&cid";

@interface GrowingEventManager ()

// 声明内部函数
- (void)writeToDatabaseWithEvent:(GrowingBaseEvent *)event;

@end

@interface GrowingGA3Adapter () <GrowingEventInterceptor, GrowingAppLifecycleDelegate>

@property (nonatomic, strong) GrowingVisitEvent *lastVisitEvent;
@property (nonatomic, strong) GrowingPageEvent *lastPageEvent;
@property (nonatomic, assign, readonly) long long sessionInterval;
@property (nonatomic, assign) long long latestDidEnterBackgroundTime;
@property (nonatomic, strong) NSMutableDictionary<NSString *, GrowingGA3TrackerInfo *> *trackerInfos;

@end

@implementation GrowingGA3Adapter

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {
    [[GrowingEventManager sharedInstance] addInterceptor:self];
    [GrowingAppLifecycle.sharedInstance addAppLifecycleDelegate:self];
    
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    NSTimeInterval sessionInterval = trackConfiguration.sessionInterval;
    self->_sessionInterval = (long long)(sessionInterval * 1000LL);
    
    [GrowingGA3Injector.sharedInstance addAdapterSwizzles];
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *)event {
    if ([event isKindOfClass:GrowingVisitEvent.class]) {
        self.lastVisitEvent = (GrowingVisitEvent *)event;
    } else if ([event isKindOfClass:GrowingPageEvent.class]) {
        self.lastPageEvent = (GrowingPageEvent *)event;
    }
}

#pragma mark - GrowingAppLifecycleDelegate

- (void)applicationDidBecomeActive {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (self.latestDidEnterBackgroundTime == 0) {
            return;
        }
        long long now = GrowingTimeUtil.currentTimeMillis;
        if (now - self.latestDidEnterBackgroundTime >= self.sessionInterval) {
            // 更新所有GAITracker的sessionId，并补发相应VISIT事件
            for (NSString *key in self.trackerInfos.allKeys) {
                GrowingGA3TrackerInfo *info = self.trackerInfos[key];
                info.sessionId = NSUUID.UUID.UUIDString;
                info.sentVisitAfterRefreshSessionId = NO;
                generateVisit(info);
            }
        }
    }];
}

- (void)applicationWillResignActive {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        self.latestDidEnterBackgroundTime = GrowingTimeUtil.currentTimeMillis;
    }];
}

- (void)applicationDidEnterBackground {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        self.latestDidEnterBackgroundTime = GrowingTimeUtil.currentTimeMillis;
    }];
}

#pragma mark - Growing GA3 Adapter

+ (instancetype)sharedInstance {
    static GrowingGA3Adapter *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance.trackerInfos = NSMutableDictionary.dictionary;
        _sharedInstance.latestDidEnterBackgroundTime = 0;
    });

    return _sharedInstance;
}

- (void)setDataCollectionEnabled:(BOOL)enabled {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (enabled == trackConfiguration.dataCollectionEnabled) {
            return;
        }
        trackConfiguration.dataCollectionEnabled = enabled;
        if (enabled) {
            [[GrowingSession currentSession] generateVisit];
            
            // 所有GAITracker补发相应VISIT事件
            for (NSString *key in self.trackerInfos.allKeys) {
                GrowingGA3TrackerInfo *info = self.trackerInfos[key];
                generateVisit(info);
            }
        }
    }];
}

#pragma mark - Growing GA3 Injector

- (void)trackerInit:(id)tracker name:(NSString *)name trackingId:(NSString *)trackingId {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        NSString *dataSourceId = configuration.dataSourceIds[trackingId];
        if (!dataSourceId || dataSourceId.length == 0) {
            GIOLogWarn(@"[GrowingGA3Adapter] 请在初始化SDK时通过configuration.dataSourceIds配置当前trackingId(%@)对应的dataSourceId", trackingId);
            return;
        }
        
        if ([self.trackerInfos.allKeys containsObject:name]) {
            return;
        }
        
        GrowingGA3TrackerInfo *info = [[GrowingGA3TrackerInfo alloc] initWithTracker:tracker
                                                                        dataSourceId:dataSourceId
                                                                           sessionId:NSUUID.UUID.UUIDString
                                                                 transformEventBlock:^(GrowingBaseEvent * _Nonnull event,
                                                                                       GrowingGA3TrackerInfo * _Nonnull info) {
            if ([event.eventType isEqualToString:GrowingEventTypeVisit]
                || [event.eventType isEqualToString:GrowingEventTypeCustom]
                || [event.eventType isEqualToString:GrowingEventTypeLoginUserAttributes]
                || [event.eventType isEqualToString:GrowingEventTypeConversionVariables]
                || [event.eventType isEqualToString:GrowingEventTypeVisitorAttributes]) {
                return;
            }
            
            // 转发所有无埋点事件(不含VISIT)
            [GrowingDispatchManager dispatchInGrowingThread:^{
                transformToGA3Event(event, info, 0LL);
            }];
        }];
        
        // 增加对应GAITracker拦截器
        [[GrowingEventManager sharedInstance] addInterceptor:(id <GrowingEventInterceptor>)info];
        
        // 初始化补发VISIT、PAGE、LOGIN_USER_ATTRIBUTES
        generateVisit(info);
        
        self.trackerInfos[name] = info;
    }];
}

- (void)tracker:(id)tracker set:(NSString *)parameterName value:(NSString *)value {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingGA3TrackerInfo *info = self.trackerInfos[getTrackerName(tracker)];
        if (!info) {
            return;
        }
        if ([parameterName isEqualToString:kGA3UserIdKey]) {
            [self setUserId:value info:info];
            return;
        }
        [info addParameter:parameterName value:value];
    }];
}

- (void)tracker:(id)tracker send:(NSDictionary *)parameters {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingGA3TrackerInfo *info = self.trackerInfos[getTrackerName(tracker)];
        if (!info) {
            return;
        }
        GrowingBaseBuilder *builder = GrowingCustomEvent.builder.setEventName(@"GAEvent").setAttributes(parameters);
        sendGA3Event(builder, info);
    }];
}

- (void)removeTrackerByName:(NSString *)name {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        self.trackerInfos[name] = nil;
    }];
}

- (void)setUserId:(NSString *)userId info:(GrowingGA3TrackerInfo *)info {
    if (!userId || userId.length == 0) {
        // A -> nil
        info.userId = nil;
        return;
    }
    
    if ([userId isEqualToString:info.userId]) {
        // A -> A
        return;
    }
    
    BOOL sendVisit = NO;
    if (!info.lastUserId || info.lastUserId.length == 0) {
        // nil -> A(不包括 A -> nil -> A)
        sendVisit = YES;
    } else if (![userId isEqualToString:info.lastUserId]) {
        // A -> B
        info.sessionId = NSUUID.UUID.UUIDString;
        info.sentVisitAfterRefreshSessionId = NO;
        sendVisit = YES;
    }
    
    info.userId = userId;
    info.lastUserId = userId;
    
    if (sendVisit) {
        generateVisit(info);
    }
}

#pragma mark - Growing GA3 Event

static void generateVisit(GrowingGA3TrackerInfo *info) {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!trackConfiguration.dataCollectionEnabled) {
        return;
    }
    
    if (info.isSentFirstVisit) {
        info.sentVisitAfterRefreshSessionId = YES;
        sendGA3Event(GrowingVisitEvent.builder, info);
    } else {
        // GAITracker初始化补发VISIT、PAGE，更新时间为GAITracker创建时间
        if (GrowingGA3Adapter.sharedInstance.lastVisitEvent) {
            info.sentFirstVisit = YES;
            info.sentVisitAfterRefreshSessionId = YES;
            transformToGA3Event(GrowingGA3Adapter.sharedInstance.lastVisitEvent, info, GrowingTimeUtil.currentTimeMillis);
        }
        if (GrowingGA3Adapter.sharedInstance.lastPageEvent) {
            transformToGA3Event(GrowingGA3Adapter.sharedInstance.lastPageEvent, info, GrowingTimeUtil.currentTimeMillis);
        }
        
        // 发送LOGIN_USER_ATTRIBUTES事件，用于关联历史数据
        id tracker = info.tracker;
        NSString *clientId = getClientId(tracker);
        if (clientId && clientId.length > 0) {
            NSDictionary *attributes = @{kGA3ClientIdKey : clientId};
            GrowingBaseBuilder *builder = GrowingLoginUserAttributesEvent.builder.setAttributes(attributes);
            sendGA3Event(builder, info);
        }
    }
}

static void writeToDatabaseWithEvent(GrowingBaseEvent *ga3Event) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // 因为无依赖关系，动态调用增加到MobileDebugger队列中，方便MobileDebugger查看
    Class class = NSClassFromString(@"GrowingDebuggerEventQueue");
    SEL selector = NSSelectorFromString(@"currentQueue");
    if (class && [class respondsToSelector:selector]) {
        id sharedInstance = [class performSelector:selector];
        selector = NSSelectorFromString(@"enqueue:");
        if (sharedInstance && [sharedInstance respondsToSelector:selector]) {
            [sharedInstance performSelector:selector withObject:ga3Event.toDictionary];
        }
    }
#pragma clang diagnostic pop
    
    [GrowingEventManager.sharedInstance writeToDatabaseWithEvent:ga3Event];
}

// 主动构造的事件需要执行readPropertyInTrackThread读取通用参数
static void sendGA3Event(GrowingBaseBuilder *builder, GrowingGA3TrackerInfo *info) {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!trackConfiguration.dataCollectionEnabled) {
        return;
    }
    
    if (!info.isSentVisitAfterRefreshSessionId) {
        generateVisit(info);
    }
    
    [builder readPropertyInTrackThread];
    GrowingBaseEvent *e = GrowingGA3Event.builder.setBaseEvent(builder.build).setTrackerInfo(info).build;
    writeToDatabaseWithEvent(e);
}

// 转发事件已经执行过readPropertyInTrackThread
static void transformToGA3Event(GrowingBaseEvent *event, GrowingGA3TrackerInfo *info, long long timestamp) {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!trackConfiguration.dataCollectionEnabled) {
        return;
    }
    
    if (!info.isSentVisitAfterRefreshSessionId) {
        generateVisit(info);
    }

    GrowingBaseEvent *e = GrowingGA3Event.builder.setBaseEvent(event).setTrackerInfo(info).setTimestamp(timestamp).build;
    writeToDatabaseWithEvent(e);
}

#pragma mark - Growing GA3 GAITrackerImpl

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
static NSString *getTrackerName(id tracker) {
    SEL selector = @selector(name);
    if ([tracker respondsToSelector:selector]) {
        return (NSString *)[tracker performSelector:selector];
    }
    return @"";
}

static NSString *getClientId(id tracker) {
    SEL selector = @selector(get:);
    if ([tracker respondsToSelector:selector]) {
        return (NSString *)[tracker performSelector:selector withObject:kGA3ClientIdKey];
    }
    return @"";
}
#pragma clang diagnostic pop

@end
