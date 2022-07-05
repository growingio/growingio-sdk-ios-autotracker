//
//  GrowingGAAdapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/17.
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

#import "Modules/GAAdapter/GrowingGAAdapter.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Swizzle/GrowingSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

GrowingMod(GrowingGAAdapter)

static NSString *const kFIRParameterItems = @"items";

static NSString *const kFIRAPersistedConfigPlistName =
    @"com.google.gmp.measurement";
static NSString *const kFIRAPersistedConfigMeasurementEnabledStateKey =
    @"/google/measurement/measurement_enabled_state";
static NSString *const kFIRAPersistedConfigDefaultEventParametersKey =
    @"/google/measurement/default_event_parameters";

static NSString *const kFIRAppInstanceID = @"app_instance_id";

typedef NS_ENUM(int64_t, FIRAnalyticsEnabledState) {
  // 0 is the default value for keys not found stored in persisted config, so it cannot represent
  // kFIRAnalyticsEnabledStateSetNo. It must represent kFIRAnalyticsEnabledStateNotSet.
  kFIRAnalyticsEnabledStateNotSet = 0,
  kFIRAnalyticsEnabledStateSetYes = 1,
  kFIRAnalyticsEnabledStateSetNo = 2,
};

@interface GrowingGAAdapter () <GrowingEventInterceptor>

@property (nonatomic, assign, getter=isAnalyticsCollectionEnabled) BOOL analyticsCollectionEnabled;
@property (nonatomic, strong) NSMutableDictionary *defaultParameters;
@property (nonatomic, copy) NSString *appInstanceID;

@property (nonatomic, assign) int64_t kFIRAnalyticsEnabledState;
@property (nonatomic, assign) NSDictionary *kFIRAnalyticsDefaultEventParameters;
@property (nonatomic, assign) BOOL isAdapterOnly;
@property (nonatomic, assign, getter=isSentAppInstanceID) BOOL sentAppInstanceID;

@end

@implementation GrowingGAAdapter

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {    
    [GrowingGAAdapter.sharedInstance addAdapterSwizzles];
    [[GrowingEventManager sharedInstance] addInterceptor:self];
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *)event {
    if ([event.eventType isEqualToString:GrowingEventTypeLoginUserAttributes]) {
        GrowingLoginUserAttributesEvent *e = (GrowingLoginUserAttributesEvent *)event;
        // 当前正在上报appInstanceID
        if (e.attributes.count > 0 && e.attributes[kFIRAppInstanceID]) {
            GrowingGAAdapter.sharedInstance.sentAppInstanceID = YES;
            
            // 清除事件拦截器
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GrowingEventManager sharedInstance] removeInterceptor:self];
            });
            
            return;
        }
    }
    
    if ([event.eventType isEqualToString:GrowingEventTypeVisit]) {
        // 初始化触发的首个VISIT事件
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            BOOL enabled = self.kFIRAnalyticsEnabledState != kFIRAnalyticsEnabledStateSetNo;
            growingga_adapter_setAnalyticsCollectionEnabled(enabled);
            growingga_adapter_setDefaultEventParameters(self.kFIRAnalyticsDefaultEventParameters);
            
            self.kFIRAnalyticsEnabledState = 0;
            self.kFIRAnalyticsDefaultEventParameters = nil;
        });
    }
    
    if (self.appInstanceID) {
        // 异步调用，保证在首个VISIT事件之后
        dispatch_async(dispatch_get_main_queue(), ^{
            growingga_adapter_logAppInstanceID(self.appInstanceID);
        });
    }
}

#pragma mark - Growing GA Adapter

+ (instancetype)sharedInstance {
    static GrowingGAAdapter *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (NSMutableDictionary *)defaultParameters {
    if (!_defaultParameters) {
        _defaultParameters = NSMutableDictionary.dictionary;
    }
    return _defaultParameters;
}

- (void)addAdapterSwizzles {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"FIRAnalytics");
        if (!class) {
            @throw [NSException exceptionWithName:@"Google Analytics v4(FirebaseAnalytics)未集成"
                                           reason:@"请集成Google Analytics，再进行Growing GA Adapter适配"
                                         userInfo:nil];
        }
        
        {
            Class class = NSClassFromString(@"FIRApp");
            SEL selector = NSSelectorFromString(@"allApps");
            if ([class respondsToSelector:selector]) {
                NSDictionary *allApps = ((NSDictionary *(*)(id, SEL))objc_msgSend)(class, selector);
                if (allApps) {
                    @throw [NSException exceptionWithName:@"Google Analytics v4(FirebaseAnalytics)已初始化"
                                                   reason:@"GrowingAnalytics初始化必须在FirebaseAnalytics之前"
                                                 userInfo:nil];
                }
            }
        }
        
        {
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSNumber *analyticsEnabledState = [u objectForKey:kFIRAPersistedConfigMeasurementEnabledStateKey];
            self.kFIRAnalyticsEnabledState = analyticsEnabledState.intValue;
            
            NSUserDefaults *u2 = [[NSUserDefaults alloc] initWithSuiteName:kFIRAPersistedConfigPlistName];
            NSDictionary *parameters = [u2 objectForKey:kFIRAPersistedConfigDefaultEventParametersKey];
            self.kFIRAnalyticsDefaultEventParameters = parameters;
            
            // 仅使用GAAdapter时，GA配置的本地持久化由GAAdapter来完成
            self.isAdapterOnly = NSClassFromString(@"APMPersistedConfig") == nil;
        }
        
        {
            // Returns the unique ID for this instance of the application or
            // nil if ConsentType.analyticsStorage has been set to ConsentStatus.denied.
            SEL selector = NSSelectorFromString(@"appInstanceID");
            if ([class respondsToSelector:selector]) {
                self.appInstanceID = ((NSString *(*)(id, SEL))objc_msgSend)(class, selector);
                self.sentAppInstanceID = NO;
            }
        }
        
        {
            __block NSInvocation *invocation = nil;
            SEL selector = NSSelectorFromString(@"logEventWithName:parameters:");
            id block = ^(id analytics, NSString *name, NSDictionary<NSString *, id> * _Nullable parameters) {
                if (!invocation) {
                    return;
                }
                [invocation retainArguments];
                [invocation setArgument:&name atIndex:2];
                [invocation setArgument:&parameters atIndex:3];
                [invocation invoke];
                
                growingga_adapter_logEvent(name, parameters);
            };
            invocation = [class growing_swizzleClassMethod:selector withBlock:block error:nil];
        }
                
        {
            __block NSInvocation *invocation = nil;
            SEL selector = NSSelectorFromString(@"setUserPropertyString:forName:");
            id block = ^(id analytics, NSString * _Nullable value, NSString *name) {
                if (!invocation) {
                    return;
                }
                [invocation retainArguments];
                [invocation setArgument:&value atIndex:2];
                [invocation setArgument:&name atIndex:3];
                [invocation invoke];
                
                growingga_adapter_setUserPropertyString(value, name);
            };
            invocation = [class growing_swizzleClassMethod:selector withBlock:block error:nil];
        }
        
        {
            __block NSInvocation *invocation = nil;
            SEL selector = NSSelectorFromString(@"setUserID:");
            id block = ^(id analytics, NSString * _Nullable userID) {
                if (!invocation) {
                    return;
                }
                [invocation retainArguments];
                [invocation setArgument:&userID atIndex:2];
                [invocation invoke];
                
                growingga_adapter_setUserID(userID);
            };
            invocation = [class growing_swizzleClassMethod:selector withBlock:block error:nil];
        }
        
        {
            __block NSInvocation *invocation = nil;
            SEL selector = NSSelectorFromString(@"setAnalyticsCollectionEnabled:");
            id block = ^(id analytics, BOOL analyticsCollectionEnabled) {
                if (!invocation) {
                    return;
                }
                [invocation retainArguments];
                [invocation setArgument:&analyticsCollectionEnabled atIndex:2];
                [invocation invoke];
                
                growingga_adapter_setAnalyticsCollectionEnabled(analyticsCollectionEnabled);
            };
            invocation = [class growing_swizzleClassMethod:selector withBlock:block error:nil];
        }
        
        {
            __block NSInvocation *invocation = nil;
            SEL selector = NSSelectorFromString(@"setDefaultEventParameters:");
            id block = ^(id analytics, NSDictionary<NSString *, id> * _Nullable parameters) {
                if (!invocation) {
                    return;
                }
                [invocation retainArguments];
                [invocation setArgument:&parameters atIndex:2];
                [invocation invoke];
                
                growingga_adapter_setDefaultEventParameters(parameters);
            };
            invocation = [class growing_swizzleClassMethod:selector withBlock:block error:nil];
        }
    });
}

#pragma mark - Growing GA Adapter Hook

static id growingga_tracker(void) {
    Class class = NSClassFromString(@"GrowingAutotracker") ?: NSClassFromString(@"GrowingTracker");
    SEL selector = NSSelectorFromString(@"sharedInstance");
    if (![class respondsToSelector:selector]) {
        return nil;
    }
    
    return ((id (*)(id, SEL))objc_msgSend)(class, selector);
}

static void growingga_adapter_logAppInstanceID(NSString *appInstanceID) {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (GrowingGAAdapter.sharedInstance.isSentAppInstanceID) {
            return;
        }
        
        if (!GrowingGAAdapter.sharedInstance.isAnalyticsCollectionEnabled) {
            return;
        }
        
        id tracker = growingga_tracker();
        if (!tracker) {
            return;
        }
        
        SEL selector = NSSelectorFromString(@"setLoginUserAttributes:");
        if (![tracker respondsToSelector:selector]) {
            return;
        }
        ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(tracker, selector, @{kFIRAppInstanceID : appInstanceID});
    }];
}

static void growingga_adapter_logEvent(NSString *name,
                                       NSDictionary<NSString *, id> * _Nullable parameters) {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (!GrowingGAAdapter.sharedInstance.isAnalyticsCollectionEnabled) {
            return;
        }
        
        if (!growingga_validator_isValidEventName(name)) {
            return;
        }
        
        id tracker = growingga_tracker();
        if (!tracker) {
            return;
        }
        
        NSMutableDictionary *finalParameters = GrowingGAAdapter.sharedInstance.defaultParameters.mutableCopy;
        
        if (parameters && parameters.count > 0) {
            NSMutableDictionary *attr = NSMutableDictionary.dictionary;
            for (NSString *key in parameters.allKeys) {
                if (!growingga_validator_isValidEventParameterName(key)) {
                    continue;
                }
                
                // DefaultEventParameters are of lower precedence than event parameters, so if an event parameter and
                // a parameter set using setDefaultEventParameters: API have the same name, the value of the event
                // parameter will be used.
                [finalParameters removeObjectForKey:key];
                
                id value = parameters[key];
                if ([value isKindOfClass:NSArray.class] && [key isEqualToString:kFIRParameterItems]) {
                    // @{
                    // kFIRParameterItems : @[
                    // @{kFIRParameterItemName : name0, kFIRParameterItemCategory : category0, ...}, /* item0 */
                    // @{kFIRParameterItemName : name1, kFIRParameterItemCategory : category1, ...}, /* item1 */
                    // ...
                    // ]
                    // }
                    //
                    // map as:
                    //
                    // @{
                    // kFIRParameterItems_0_kFIRParameterItemName : name0,
                    // kFIRParameterItems_0_kFIRParameterItemCategory : category0,
                    // kFIRParameterItems_1_kFIRParameterItemName : name1,
                    // kFIRParameterItems_1_kFIRParameterItemCategory : category1,
                    // ...
                    // }
                    NSArray *items = (NSArray *)value;
                    for (int i = 0; i < items.count; i++) {
                        NSDictionary<NSString *, id> *item = items[i];
                        for (NSString *itemKey in item.allKeys) {
                            id itemValue = item[itemKey];
                            NSString *separator = @"_";
                            NSString *itemKeyMap = [NSString stringWithFormat:@"%@%@%d%@%@",
                                                    kFIRParameterItems,
                                                    separator,
                                                    i,
                                                    separator,
                                                    itemKey];
                            if ([itemValue isKindOfClass:NSString.class]) {
                                [attr setObject:itemValue forKey:itemKeyMap];
                            } else if ([itemValue isKindOfClass:NSNumber.class]) {
                                double multiplier = pow(10, 15);
                                double roundedValue = round(((NSNumber *)itemValue).doubleValue * multiplier) / multiplier;
                                [attr setObject:@(roundedValue) forKey:itemKeyMap];
                            }
                        }
                    }
                } else {
                    if (!growingga_validator_isValidEventParameterValue(value)) {
                        continue;
                    }
                    
                    if ([value isKindOfClass:NSString.class]) {
                        [attr setObject:value forKey:key];
                    } else if ([value isKindOfClass:NSNumber.class]) {
                        double multiplier = pow(10, 15);
                        double roundedValue = round(((NSNumber *)value).doubleValue * multiplier) / multiplier;
                        [attr setObject:@(roundedValue) forKey:key];
                    }
                }
            }

            [finalParameters addEntriesFromDictionary:attr];
        }
        
        if (finalParameters.count > 0) {
            for (NSString *key in finalParameters.allKeys) {
                id value = finalParameters[key];
                if ([value isKindOfClass:NSNumber.class]) {
                    [finalParameters setObject:[NSString stringWithFormat:@"%@", value] forKey:key];
                }
            }
            
            SEL selector = NSSelectorFromString(@"trackCustomEvent:withAttributes:");
            if (![tracker respondsToSelector:selector]) {
                return;
            }
            ((void (*)(id, SEL, NSString *, NSDictionary *))objc_msgSend)(tracker, selector, name, finalParameters);
        } else {
            SEL selector = NSSelectorFromString(@"trackCustomEvent:");
            if (![tracker respondsToSelector:selector]) {
                return;
            }
            ((void (*)(id, SEL, NSString *))objc_msgSend)(tracker, selector, name);
        }
        
        GIOLogDebug(@"[GrowingGAAdapter] logEvent name: %@ parameters: %@", name, parameters.description);
    }];
}

static void growingga_adapter_setUserPropertyString(NSString * _Nullable value,
                                                    NSString *name) {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (!GrowingGAAdapter.sharedInstance.isAnalyticsCollectionEnabled) {
            return;
        }
        
        if (!growingga_validator_isValidUserPropertyValue(value)
            || !growingga_validator_isValidUserPropertyName(name)) {
            return;
        }

        id tracker = growingga_tracker();
        if (!tracker) {
            return;
        }
        
        NSDictionary *attr = @{name : (value ?: @"")};
        SEL selector = NSSelectorFromString(@"setLoginUserAttributes:");
        if (![tracker respondsToSelector:selector]) {
            return;
        }
        ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(tracker, selector, attr);
        
        GIOLogDebug(@"[GrowingGAAdapter] setUserPropertyString: %@ name: %@", value, name);
    }];
}

static void growingga_adapter_setUserID(NSString * _Nullable userID) {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (!GrowingGAAdapter.sharedInstance.isAnalyticsCollectionEnabled) {
            return;
        }
        
        if (!growingga_validator_isValidUserID(userID)) {
            return;
        }

        id tracker = growingga_tracker();
        if (!tracker) {
            return;
        }
        
        if (userID) {
            SEL selector = NSSelectorFromString(@"setLoginUserId:");
            if (![tracker respondsToSelector:selector]) {
                return;
            }
            ((void (*)(id, SEL, NSString *))objc_msgSend)(tracker, selector, userID);
        } else {
            SEL selector = NSSelectorFromString(@"cleanLoginUserId");
            if (![tracker respondsToSelector:selector]) {
                return;
            }
            ((void (*)(id, SEL))objc_msgSend)(tracker, selector);
        }
        
        GIOLogDebug(@"[GrowingGAAdapter] setUserID: %@", userID);
    }];
}

static void growingga_adapter_setAnalyticsCollectionEnabled(BOOL analyticsCollectionEnabled) {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        id tracker = growingga_tracker();
        if (!tracker) {
            return;
        }
        
        SEL selector = NSSelectorFromString(@"setDataCollectionEnabled:");
        if (![tracker respondsToSelector:selector]) {
            return;
        }
        ((void (*)(id, SEL, BOOL))objc_msgSend)(tracker, selector, analyticsCollectionEnabled);
        
        GrowingGAAdapter.sharedInstance.analyticsCollectionEnabled = analyticsCollectionEnabled;
        
        if (GrowingGAAdapter.sharedInstance.isAdapterOnly) {
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            [u setObject:analyticsCollectionEnabled ? @1 : @2 forKey:kFIRAPersistedConfigMeasurementEnabledStateKey];
            [u synchronize];
        }
        
        GIOLogDebug(@"[GrowingGAAdapter] setAnalyticsCollectionEnabled: %@", analyticsCollectionEnabled ? @"YES" : @"NO");
    }];
}

static void growingga_adapter_setDefaultEventParameters(NSDictionary<NSString *, id> * _Nullable parameters) {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (!GrowingGAAdapter.sharedInstance.isAnalyticsCollectionEnabled) {
            return;
        }
        
        NSMutableDictionary *attr = GrowingGAAdapter.sharedInstance.defaultParameters.mutableCopy;
        if (parameters) {
            for (NSString *key in parameters.allKeys) {
                if (!growingga_validator_isValidEventParameterName(key)) {
                    continue;
                }
                id value = parameters[key];
                if ([value isKindOfClass:NSNull.class]) {
                    [attr removeObjectForKey:key];
                } else {
                    if (!growingga_validator_isValidEventParameterValue(value)) {
                        continue;
                    }
                    if ([value isKindOfClass:NSString.class]) {
                        [attr setObject:value forKey:key];
                    } else if ([value isKindOfClass:NSNumber.class]) {
                        double multiplier = pow(10, 15);
                        double roundedValue = round(((NSNumber *)value).doubleValue * multiplier) / multiplier;
                        [attr setObject:@(roundedValue) forKey:key];
                    }
                }
            }
        } else {
            attr = nil;
        }
        
        GrowingGAAdapter.sharedInstance.defaultParameters = attr;
        
        if (GrowingGAAdapter.sharedInstance.isAdapterOnly) {
            NSUserDefaults *u = [[NSUserDefaults alloc] initWithSuiteName:kFIRAPersistedConfigPlistName];
            [u setObject:attr forKey:kFIRAPersistedConfigDefaultEventParametersKey];
            [u synchronize];
        }
        
        GIOLogDebug(@"[GrowingGAAdapter] setDefaultEventParameters: %@", parameters.description);
        GIOLogDebug(@"[GrowingGAAdapter] DefaultEventParameters: %@", attr.description);
    }];
}

#pragma mark - Growing GA Adapter Validator

static BOOL growingga_validator_isValidString(NSString * _Nullable string, int minLength, int maxLength) {
    if (!string) {
        return NO;
    }
    
    if (string.length < minLength || string.length > maxLength) {
        return NO;
    }
    
    return YES;
}

static BOOL growingga_validator_isValidName(NSString * _Nullable name) {
    NSString *regex = @"^[a-zA-Z][a-zA-Z0-9_]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:name]) {
        return NO;
    }
    
    return YES;
}

static BOOL growingga_validator_hasReservedPrefixes(NSString *string) {
    if ([string hasPrefix:@"firebase_"]
        || [string hasPrefix:@"google_"]
        || [string hasPrefix:@"ga_"]) {
        return YES;
    }
    
    return NO;
}

/// The name of the event. Should contain 1 to 40 alphanumeric characters or
/// underscores. The name must start with an alphabetic character. Some event names are
/// reserved. See FIREventNames.h for the list of reserved event names. The "firebase_",
/// "google_", and "ga_" prefixes are reserved and should not be used. Note that event names are
/// case-sensitive and that logging two events whose names differ only in case will result in
/// two distinct events. To manually log screen view events, use the `screen_view` event name.
static BOOL growingga_validator_isValidEventName(NSString *name) {
    if (!growingga_validator_isValidString(name, 1, 40)) {
        return NO;
    }
    
    if (!growingga_validator_isValidName(name)) {
        return NO;
    }

    if (growingga_validator_hasReservedPrefixes(name)) {
        return NO;
    }
    
    return YES;
}

/// Parameter names can be up to 40 characters long and must start with an alphabetic character
/// and contain only alphanumeric characters and underscores. The "firebase_", "google_", and "ga_"
/// prefixes are reserved and should not be used for parameter names.
static BOOL growingga_validator_isValidEventParameterName(NSString *name) {
    if (!growingga_validator_isValidString(name, 1, 40)) {
        return NO;
    }
    
    if (!growingga_validator_isValidName(name)) {
        return NO;
    }

    if (growingga_validator_hasReservedPrefixes(name)) {
        return NO;
    }
    
    return YES;
}

/// Only String, Int, and Double parameter types are supported. String parameter values can be
/// up to 100 characters long.
static BOOL growingga_validator_isValidEventParameterValue(id value) {
    if ([value isKindOfClass:NSString.class]) {
        if (!growingga_validator_isValidString(value, 1, 100)) {
            return NO;
        }
    } else if ([value isKindOfClass:NSNumber.class]) {

    } else {
        return NO;
    }
    
    return YES;
}

/// The name of the user property to set. Should contain 1 to 24 alphanumeric characters
/// or underscores and must start with an alphabetic character. The "firebase_", "google_", and
/// "ga_" prefixes are reserved and should not be used for user property names.
static BOOL growingga_validator_isValidUserPropertyName(NSString *name) {
    if (!growingga_validator_isValidString(name, 1, 24)) {
        return NO;
    }
    
    if (!growingga_validator_isValidName(name)) {
        return NO;
    }

    if (growingga_validator_hasReservedPrefixes(name)) {
        return NO;
    }
    
    return YES;
}

/// The value of the user property. Values can be up to 36 characters long. Setting the
/// value to `nil` removes the user property.
static BOOL growingga_validator_isValidUserPropertyValue(NSString * _Nullable value) {
    if (!value) {
        return YES;
    }
    if (!growingga_validator_isValidString(value, 1, 36)) {
        return NO;
    }

    return YES;
}

/// The user ID to ascribe to the user of this app on this device, which must be
/// non-empty and no more than 256 characters long. Setting userID to `nil` removes the user ID.
static BOOL growingga_validator_isValidUserID(NSString * _Nullable userID) {
    if (!userID) {
        return YES;
    }
    if (!growingga_validator_isValidString(userID, 1, 256)) {
        return NO;
    }
    return YES;
}

@end
