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

#import "GrowingRealTracker.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingAppLifecycle.h"
#import "GrowingLogger.h"
#import "GrowingWSLoggerFormat.h"
#import "GrowingDispatchManager.h"
#import "NSString+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingDeviceInfo.h"
#import "GrowingVisitEvent.h"
#import "GrowingSession.h"
#import "GrowingConfigurationManager.h"
#import "GrowingEventGenerator.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingArgumentChecker.h"
#import "GrowingAppDelegateAutotracker.h"
#import "GrowingDeepLinkHandler.h"
#import "GrowingModuleManager.h"
#import "GrowingServiceManager.h"
#import "GrowingEventManager.h"

NSString *const GrowingTrackerVersionName = @"3.3.1-hotfix.2";
const int GrowingTrackerVersionCode = 30301;

@interface GrowingRealTracker ()

@property(nonatomic, copy, readonly) NSDictionary *launchOptions;
@property(nonatomic, strong, readonly) GrowingTrackConfiguration *configuration;

@end

@implementation GrowingRealTracker

- (instancetype)initWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    self = [super init];
    if (self) {
        _configuration = [configuration copyWithZone:nil];
        _launchOptions = [launchOptions copy];
        GrowingConfigurationManager.sharedInstance.trackConfiguration = self.configuration;
        if (configuration.urlScheme.length > 0) {
            [GrowingDeviceInfo configUrlScheme:configuration.urlScheme.copy];
        }
        
        [self loggerSetting];
        [GrowingAppLifecycle.sharedInstance setupAppStateNotification];
        [GrowingSession startSession];
        [GrowingAppDelegateAutotracker track];
        [[GrowingModuleManager sharedInstance] registedAllModules];
        [[GrowingServiceManager sharedInstance] loadLocalServices];
        [[GrowingModuleManager sharedInstance] triggerEvent:GrowingMInitEvent];
        // 各个Module初始化init之后再进行事件定时发送
        [[GrowingEventManager sharedInstance] configChannels];
        [[GrowingEventManager sharedInstance] startTimerSend];
        [self versionPrint];
        [self filterLogPrint];
    }

    return self;
}

+ (instancetype)trackerWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    return [[self alloc] initWithConfiguration:configuration launchOptions:launchOptions];
}

- (void)loggerSetting {
    GrowingLogLevel level = self.logLevel;
    if (@available(iOS 10.0, *)) {
        [GrowingLog addLogger:[GrowingOSLogger sharedInstance] withLevel:level];
    }else {
        [GrowingLog addLogger:[GrowingTTYLogger sharedInstance] withLevel:level];
        [GrowingLog addLogger:[GrowingASLLogger sharedInstance] withLevel:level];
    }
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
    NSString *versionStr = [NSString stringWithFormat:@"Thank you very much for using GrowingIO. We will do our best to provide you with the best service. GrowingIO version: %@",GrowingTrackerVersionName];
    GIOLogInfo(@"%@", versionStr);
    
#ifdef GROWING_ANALYSIS_ENABLE_ENCRYPTION
    GIOLogWarn(@"\n"
               @"╔═══════════════════════════════════════════════════════════════════════════════════════\n"
               @"║ \n"
               @"║ WARNING: pod ENABLE_ENCRYPTION is deprecated, please use -[GrowingTrackConfiguration setEncryptEnabled]\n"
               @"║ 警告: pod ENABLE_ENCRYPTION 已被废弃, 请使用 -[GrowingTrackConfiguration setEncryptEnabled] 进行配置\n"
               @"║ \n"
               @"╚═══════════════════════════════════════════════════════════════════════════════════════");
#endif
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
    if(GrowingConfigurationManager.sharedInstance.trackConfiguration.excludeEvent > 0) {
        GIOLogInfo(@"%@", [GrowingEventFilter getFilterEventLog]);
    }
    if(GrowingConfigurationManager.sharedInstance.trackConfiguration.ignoreField > 0) {
        GIOLogInfo(@"%@", [GrowingFieldsIgnore getIgnoreFieldsLog]);
    }
}

- (void)trackCustomEvent:(NSString *)eventName {
    if ([GrowingArgumentChecker isIllegalEventName:eventName]) {
        return;
    }
    [GrowingEventGenerator generateCustomEvent:eventName attributes:nil];
}

- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if ([GrowingArgumentChecker isIllegalEventName:eventName] || [GrowingArgumentChecker isIllegalAttributes:attributes]) {
        return;
    }
    [GrowingEventGenerator generateCustomEvent:eventName attributes:attributes];
}

- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if ([GrowingArgumentChecker isIllegalAttributes:attributes]) {
        return;
    }
    [GrowingEventGenerator generateLoginUserAttributesEvent:attributes];
}

- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if ([GrowingArgumentChecker isIllegalAttributes:attributes]) {
        return;
    }
    [GrowingEventGenerator generateVisitorAttributesEvent:attributes];
}

- (void)setConversionVariables:(NSDictionary<NSString *, NSString *> *)variables {
    if ([GrowingArgumentChecker isIllegalAttributes:variables]) {
        return;
    }
    [GrowingEventGenerator generateConversionAttributesEvent:variables];
}

- (void)setLoginUserId:(NSString *)userId {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [[GrowingSession currentSession] setLoginUserId:userId];
    }];
}

/// 支持设置userId的类型, 存储方式与userId保持一致, userKey默认为null
/// @param userId 用户ID
/// @param userKey 用户ID对应的key值
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
            [[GrowingSession currentSession] generateVisit];
        }
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
