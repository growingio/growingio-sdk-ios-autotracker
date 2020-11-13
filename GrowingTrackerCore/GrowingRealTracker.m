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
#import "GrowingGlobal.h"
#import "GrowingDispatchManager.h"
#import "GrowingCustomField.h"
#import "NSString+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingBroadcaster.h"
#import "GrowingDeviceInfo.h"
#import "GrowingVisitEvent.h"
#import "GrowingSession.h"
#import "GrowingConfigurationManager.h"

NSString *const GrowingTrackerVersionName = @"3.0.0";
const int GrowingTrackerVersionCode = 300;

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

- (void)trackCustomEvent:(NSString *)eventName {
    if (![eventName isKindOfClass:[NSString class]]) {
        GIOLogError(parameterKeyErrorLog);
        return;
    }
    if (![eventName isValidKey]) {
        GIOLogError(parameterValueErrorLog);
        return;
    }

    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{

        [[GrowingCustomField shareInstance] sendCustomTrackEventWithName:eventName andVariable:nil];

    }];
}

- (void)trackCustomEvent:(NSString *)eventName withAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if (![eventName isKindOfClass:[NSString class]]) {
        GIOLogError(parameterKeyErrorLog);
        return;
    }
    if (![attributes isKindOfClass:NSDictionary.class]) {
        GIOLogError(parameterValueErrorLog);
        return;
    }

    if (attributes.count > 100) {
        GIOLogError(parameterValueErrorLog);
        return;
    }
    if (![eventName isValidKey] || ![attributes isValidDictVariable]) {
        return;
    }

    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [[GrowingCustomField shareInstance] sendCustomTrackEventWithName:eventName andVariable:attributes];
    }];
}

- (void)setLoginUserAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if (![attributes isKindOfClass:NSDictionary.class]) {
        GIOLogError(parameterValueErrorLog);
        return;
    }

    for (NSString *key in attributes) {
        if (![key isKindOfClass:NSString.class] || ![key isValidKey]) {
            GIOLogError(parameterValueErrorLog);
            return;
        }

        NSString *stringValue = attributes[key];

        if (![stringValue isKindOfClass:NSString.class]) {
            GIOLogError(parameterValueErrorLog);
            return;;
        }

        if (stringValue.length > 1000 || stringValue.length == 0) {
            GIOLogError(parameterValueErrorLog);
            return;
        }
    }

    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{

        [[GrowingCustomField shareInstance] sendPeopleEvent:attributes];
    }];
}

- (void)setVisitorAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{

        [[GrowingCustomField shareInstance] sendVisitorEvent:attributes];
        //  GrowingBroadcaster 传入 GTouch
        NSDictionary *variable = [GrowingCustomField shareInstance].growingVistorVar ?: @{};
    }];
}

- (void)setConversionVariables:(NSDictionary<NSString *, NSString *> *)variables {
    if (variables == nil || ![variables isKindOfClass:NSDictionary.class]) {
        GIOLogError(parameterKeyErrorLog);
        return;
    }

    for (NSString *key in variables) {
        if (![key isKindOfClass:NSString.class] || ![key isValidKey]) {
            GIOLogError(parameterValueErrorLog);
            return;
        }

        NSString *stringValue = variables[key];

        if (![stringValue isKindOfClass:NSString.class]) {
            GIOLogError(parameterValueErrorLog);
            return;;
        }

        if (stringValue.length > 1000 || stringValue.length == 0) {
            GIOLogError(parameterValueErrorLog);
            return;
        }
    }

    [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
        [[GrowingCustomField shareInstance] sendEvarEvent:variables];
    }];
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
        [self setUserIdValue:@""];
    }];
}

- (void)setDataCollectionEnabled:(BOOL)enabled {

}

- (NSString *)getDeviceId {
    return [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
}

- (void)resetSessionIdWhileUserIdChangedFrom:(NSString *)oldValue toNewValue:(NSString *)newValue {
    // lastUserId 记录的是上一个有值的 CS1
    static NSString *kGrowinglastUserId = nil;

    // 保持 lastUserId 为最近有值的值
    if (oldValue.length > 0) {
        kGrowinglastUserId = oldValue;
    }

    // 如果 lastUserId 有值，并且新设置 CS1 也有值，当两个不同的时候，启用新的 Session 并发送 visit
    if (kGrowinglastUserId.length > 0 && newValue.length > 0 && ![kGrowinglastUserId isEqualToString:newValue]) {
        [[GrowingDeviceInfo currentDeviceInfo] resetSessionID];

        //重置session, 发 Visitor 事件
        if ([[GrowingCustomField shareInstance] growingVistorVar]) {
            [[GrowingCustomField shareInstance] sendVisitorEvent:[[GrowingCustomField shareInstance] growingVistorVar]];
        }
    }
}

- (void)setUserIdValue:(nonnull NSString *)value {
    NSString *oldValue = [GrowingCustomField shareInstance].userId;

    if ([value isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber *) value stringValue];
    }

    if (![value isKindOfClass:[NSString class]] || value.length == 0) {
        [GrowingCustomField shareInstance].userId = nil;
    } else {
        [GrowingCustomField shareInstance].userId = value;
    }

    NSString *newValue = [GrowingCustomField shareInstance].userId;

    [self resetSessionIdWhileUserIdChangedFrom:oldValue toNewValue:newValue];

    // Notify userId changed
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingUserIdChangedMeessage)
                                          usingBlock:^(id <GrowingMessageProtocol> _Nonnull obj) {
                                              if ([obj respondsToSelector:@selector(userIdDidChangedFrom:to:)]) {
                                                  id <GrowingUserIdChangedMeessage> message = (id <GrowingUserIdChangedMeessage>) obj;
                                                  [message userIdDidChangedFrom:oldValue to:newValue];
                                              }
                                          }];
}

@end