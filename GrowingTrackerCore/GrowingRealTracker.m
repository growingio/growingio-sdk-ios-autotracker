//
//  GrowingRealTracker.m
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/11/10.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTargetConditionals.h"
#import "GrowingTrackerCore/DeepLink/GrowingAppDelegateAutotracker.h"
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingGeneralProps.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/LogFormat/GrowingWSLoggerFormat.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Network/GrowingNetworkInterfaceManager.h"
#import "GrowingTrackerCore/Public/GrowingAttributesBuilder.h"
#import "GrowingTrackerCore/Public/GrowingModuleManager.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Timer/GrowingEventTimer.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingULAppLifecycle.h"

NSString *const GrowingTrackerVersionName = @"4.3.1";
const int GrowingTrackerVersionCode = 40301;

@interface GrowingRealTracker ()

@property (nonatomic, copy, readonly) NSDictionary *launchOptions;
@property (nonatomic, strong, readonly) GrowingTrackConfiguration *configuration;

@end

@implementation GrowingRealTracker

- (instancetype)initWithConfiguration:(GrowingTrackConfiguration *)configuration
                        launchOptions:(NSDictionary *)launchOptions {
    self = [super init];
    if (self) {
        _configuration = [configuration copyWithZone:nil];
        _launchOptions = [launchOptions copy];
        GrowingConfigurationManager.sharedInstance.trackConfiguration = _configuration;

        [self loggerSetting];
        [GrowingDeviceInfo setup];
        [GrowingNetworkInterfaceManager startMonitor];
        [GrowingULAppLifecycle setup];
        [GrowingSession startSession];
#if Growing_OS_IOS
        [GrowingAppDelegateAutotracker track];
#endif
        [[GrowingModuleManager sharedInstance] registerAllModules];
        [[GrowingServiceManager sharedInstance] registerAllServices];
        [[GrowingModuleManager sharedInstance] triggerEvent:GrowingMInitEvent];
        // 各个Module初始化init之后再进行事件定时发送
        [[GrowingEventManager sharedInstance] configManager];
        [[GrowingEventManager sharedInstance] startTimerSend];
        [self versionPrint];
        [self filterLogPrint];
    }

    return self;
}

+ (instancetype)trackerWithConfiguration:(GrowingTrackConfiguration *)configuration
                           launchOptions:(NSDictionary *)launchOptions {
    return [[self alloc] initWithConfiguration:configuration launchOptions:launchOptions];
}

- (void)loggerSetting {
    GrowingLogLevel level = self.logLevel;
    [GrowingLog addLogger:[GrowingOSLogger sharedInstance] withLevel:level];
    [GrowingLog addLogger:[GrowingWSLogger sharedInstance] withLevel:GrowingLogLevelVerbose];
    [GrowingWSLogger sharedInstance].logFormatter = [GrowingWSLoggerFormat new];
}

- (GrowingLogLevel)logLevel {
    GrowingLogLevel level = GrowingLogLevelOff;
#if defined(DEBUG) && DEBUG
    BOOL debugEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.debugEnabled;
    level = debugEnabled ? GrowingLogLevelDebug : GrowingLogLevelInfo;
#endif
    return level;
}

- (void)versionPrint {
    NSString *versionStr = [NSString stringWithFormat:
                                         @"Thank you very much for using GrowingIO. We will do our best to provide you "
                                         @"with the best service. GrowingIO version: %@",
                                         GrowingTrackerVersionName];
    GIOLogInfo(@"%@", versionStr);
}

+ (NSString *)versionName {
    // give support to GrowingToolsKit
    return [NSString stringWithFormat:@"%@", GrowingTrackerVersionName];
}

+ (NSString *)versionCode {
    // give support to GrowingToolsKit
    return [NSString stringWithFormat:@"%d", GrowingTrackerVersionCode];
}

- (void)filterLogPrint {
    if (GrowingConfigurationManager.sharedInstance.trackConfiguration.excludeEvent > 0) {
        GIOLogInfo(@"%@", [GrowingEventFilter getFilterEventLog]);
    }
    if (GrowingConfigurationManager.sharedInstance.trackConfiguration.ignoreField > 0) {
        GIOLogInfo(@"%@", [GrowingFieldsIgnore getIgnoreFieldsLog]);
    }
}

- (void)trackCustomEvent:(NSString *)eventName {
    if ([GrowingArgumentChecker isIllegalEventName:eventName]) {
        return;
    }
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [GrowingEventGenerator generateCustomEvent:eventName attributes:nil];
    }];
}

- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *, id> *)attributes {
    if ([GrowingArgumentChecker isIllegalEventName:eventName] ||
        [GrowingArgumentChecker isIllegalAttributes:attributes]) {
        return;
    }
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [GrowingEventGenerator generateCustomEvent:eventName attributes:[attributes copy]];
    }];
}

- (void)setLoginUserAttributes:(NSDictionary<NSString *, id> *)attributes {
    if ([GrowingArgumentChecker isIllegalAttributes:attributes]) {
        return;
    }
    [GrowingEventGenerator generateLoginUserAttributesEvent:attributes];
}

- (nullable NSString *)trackTimerStart:(NSString *)eventName {
    if ([GrowingArgumentChecker isIllegalEventName:eventName]) {
        return nil;
    }
    return [GrowingEventTimer trackTimerStart:eventName];
}

- (void)trackTimerPause:(NSString *)timerId {
    if ([GrowingArgumentChecker isIllegalEventName:timerId]) {
        return;
    }
    [GrowingEventTimer trackTimerPause:timerId];
}

- (void)trackTimerResume:(NSString *)timerId {
    if ([GrowingArgumentChecker isIllegalEventName:timerId]) {
        return;
    }
    [GrowingEventTimer trackTimerResume:timerId];
}

- (void)trackTimerEnd:(NSString *)timerId {
    if ([GrowingArgumentChecker isIllegalEventName:timerId]) {
        return;
    }
    [GrowingEventTimer trackTimerEnd:timerId withAttributes:nil];
}

- (void)trackTimerEnd:(NSString *)timerId withAttributes:(NSDictionary<NSString *, id> *)attributes {
    if ([GrowingArgumentChecker isIllegalEventName:timerId] ||
        [GrowingArgumentChecker isIllegalAttributes:attributes]) {
        return;
    }
    [GrowingEventTimer trackTimerEnd:timerId withAttributes:attributes];
}

- (void)removeTimer:(NSString *)timerId {
    if ([GrowingArgumentChecker isIllegalEventName:timerId]) {
        return;
    }
    [GrowingEventTimer removeTimer:timerId];
}

- (void)clearTrackTimer {
    [GrowingEventTimer clearAllTimers];
}

- (void)setGeneralProps:(NSDictionary<NSString *, id> *)props {
    [[GrowingGeneralProps sharedInstance] setGeneralProps:props];
}

- (void)removeGeneralProps:(NSArray<NSString *> *)keys {
    [[GrowingGeneralProps sharedInstance] removeGeneralProps:keys];
}

- (void)clearGeneralProps {
    [[GrowingGeneralProps sharedInstance] clearGeneralProps];
}

- (void)setLoginUserId:(NSString *)userId {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [[GrowingSession currentSession] setLoginUserId:userId];
    }];
}

- (void)setLoginUserId:(NSString *)userId userKey:(NSString *)userKey {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [[GrowingSession currentSession] setLoginUserId:userId userKey:userKey];
    }];
}

- (void)cleanLoginUserId {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [[GrowingSession currentSession] setLoginUserId:nil];
    }];
}

- (void)setDataCollectionEnabled:(BOOL)enabled {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (enabled == trackConfiguration.dataCollectionEnabled) {
            return;
        }
        trackConfiguration.dataCollectionEnabled = enabled;
        if (enabled) {
            [[GrowingSession currentSession] refreshSessionId];
            [[GrowingSession currentSession] generateVisit];
        } else {
            [GrowingEventTimer clearAllTimers];
        }

        [[GrowingModuleManager sharedInstance] triggerEvent:GrowingMSetDataCollectionEnabledEvent
                                            withCustomParam:@{
                                                @"dataCollectionEnabled": @(enabled)
                                            }];
    }];
}

- (NSString *)getDeviceId {
    return [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
}

- (void)setLocation:(double)latitude longitude:(double)longitude {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [[GrowingSession currentSession] setLocation:latitude longitude:longitude];
    }];
}

- (void)cleanLocation {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [[GrowingSession currentSession] cleanLocation];
    }];
}

@end
