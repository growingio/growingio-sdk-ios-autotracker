//
// Created by xiangyang on 2020/11/10.
//

#import "GrowingRealTracker.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingAppLifecycle.h"
#import "GrowingLog.h"
#import "GrowingTTYLogger.h"
#import "GrowingWSLogger.h"
#import "GrowingWSLoggerFormat.h"
#import "GrowingLogMacros.h"
#import "GrowingDispatchManager.h"
#import "NSString+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingLogger.h"
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
#import "GrowingEventManager.h"

NSString *const GrowingTrackerVersionName = @"3.2.1";
const int GrowingTrackerVersionCode = 30201;

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
        
        [self loggerSetting];
        GrowingConfigurationManager.sharedInstance.trackConfiguration = self.configuration;
        [GrowingAppLifecycle.sharedInstance setupAppStateNotification];
        [GrowingSession startSession];
        [GrowingAppDelegateAutotracker track];
        [[GrowingModuleManager sharedInstance] registedAllModules];
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
    [GrowingLog addLogger:[GrowingTTYLogger sharedInstance] withLevel:self.configuration.debugEnabled ? GrowingLogLevelDebug : GrowingLogLevelInfo];
    // flutter use this console
    [GrowingLog addLogger:[GrowingASLLogger sharedInstance] withLevel:self.configuration.debugEnabled ? GrowingLogLevelDebug : GrowingLogLevelInfo];
    [GrowingLog addLogger:[GrowingWSLogger sharedInstance] withLevel:GrowingLogLevelVerbose];
    [GrowingWSLogger sharedInstance].logFormatter = [GrowingWSLoggerFormat new];
}

- (void)versionPrint {
    NSString *versionStr = [NSString stringWithFormat:@"Thank you very much for using GrowingIO. We will do our best to provide you with the best service. GrowingIO version: %@",GrowingTrackerVersionName];
    GIOLogInfo(@"%@", versionStr);
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
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [[GrowingSession currentSession] setLoginUserId:userId];
    }];
}

/// 支持设置userId的类型, 存储方式与userId保持一致, userKey默认为null
/// @param userId 用户ID
/// @param userKey 用户ID对应的key值
- (void)setLoginUserId:(NSString *)userId userKey:(NSString *)userKey {
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [[GrowingSession currentSession] setLoginUserId:userId userKey:userKey];
    }];
}

- (void)cleanLoginUserId {
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [[GrowingSession currentSession] setLoginUserId:nil];
    }];
}

- (void)setDataCollectionEnabled:(BOOL)enabled {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled = enabled;
}

- (NSString *)getDeviceId {
    return [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
}

/// 设置经纬度坐标
/// @param latitude 纬度
/// @param longitude 经度
- (void)setLocation:(double)latitude longitude:(double)longitude {
    [[GrowingSession currentSession] setLocation:latitude longitude:longitude];
}

/// 清除地理位置
- (void)cleanLocation {
    [[GrowingSession currentSession] cleanLocation];
}


@end
