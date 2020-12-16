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
#import "GrowingCocoaLumberjack.h"
#import "GrowingDeviceInfo.h"
#import "GrowingVisitEvent.h"
#import "GrowingSession.h"
#import "GrowingConfigurationManager.h"
#import "GrowingEventGenerator.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingArgumentChecker.h"
#import "GrowingAppDelegateAutotracker.h"

NSString *const GrowingTrackerVersionName = @"3.0.0";
const int GrowingTrackerVersionCode = 30000;

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
        [self versionPrint];
    }

    return self;
}

+ (instancetype)trackerWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    return [[self alloc] initWithConfiguration:configuration launchOptions:launchOptions];
}

- (void)loggerSetting {
    if (self.configuration.debugEnabled) {
        [GrowingLog addLogger:[GrowingTTYLogger sharedInstance] withLevel:GrowingLogLevelDebug];
    } else {
        [GrowingLog removeLogger:[GrowingTTYLogger sharedInstance]];
        [GrowingLog addLogger:[GrowingTTYLogger sharedInstance] withLevel:GrowingLogLevelError];
    }

    [GrowingLog addLogger:[GrowingWSLogger sharedInstance] withLevel:GrowingLogLevelVerbose];
    [GrowingWSLogger sharedInstance].logFormatter = [GrowingWSLoggerFormat new];
}

- (void)versionPrint {
    NSString *versionStr = [NSString stringWithFormat:@"Thank you very much for using GrowingIO. We will do our best to provide you with the best service. GrowingIO version: %@",GrowingTrackerVersionName];
    GIOLogError(@"%@",versionStr);
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
    [GrowingEventGenerator generateConversionVariablesEvent:variables];

    
}

- (void)setLoginUserId:(NSString *)userId {
    if (userId.length == 0 || userId.length > 1000) {
        return;
    }

    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [self setUserIdValue:userId];
    }];
}

- (void)cleanLoginUserId {
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [self setUserIdValue:nil];
    }];
}

- (void)setDataCollectionEnabled:(BOOL)enabled {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled = enabled;
}

- (NSString *)getDeviceId {
    return [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
}


- (void)setUserIdValue:(NSString *)value {
    [[GrowingSession currentSession] setLoginUserId:value];
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
