//
//  GrowingCoreKit.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/6/26.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/V2AdapterTrackOnly/Public/GrowingCoreKit.h"
#import "Modules/V2AdapterTrackOnly/Public/GrowingV2Adapter.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

static id growing_getTracker(void) {
    Class class = NSClassFromString(@"GrowingAutotracker") ?: NSClassFromString(@"GrowingTracker");
    SEL selector = NSSelectorFromString(@"sharedInstance");
    if (![class respondsToSelector:selector]) {
        return nil;
    }

    return ((id(*)(id, SEL))objc_msgSend)(class, selector);
}

@implementation Growing

#pragma mark Adapter

+ (NSString *)sdkVersion {
    return GrowingTrackerVersionName;
}

+ (NSString *)getDeviceId {
    return [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
}

+ (NSString *)getVisitUserId {
    return [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
}

+ (NSString *)getSessionId {
    return [GrowingSession currentSession].sessionId;
}

+ (void)disableDataCollect {
    id tracker = growing_getTracker();
    if (!tracker) {
        return;
    }

    SEL selector = NSSelectorFromString(@"setDataCollectionEnabled:");
    if (![tracker respondsToSelector:selector]) {
        return;
    }
    ((void (*)(id, SEL, BOOL))objc_msgSend)(tracker, selector, NO);
}

+ (void)enableDataCollect {
    id tracker = growing_getTracker();
    if (!tracker) {
        return;
    }

    SEL selector = NSSelectorFromString(@"setDataCollectionEnabled:");
    if (![tracker respondsToSelector:selector]) {
        return;
    }
    ((void (*)(id, SEL, BOOL))objc_msgSend)(tracker, selector, YES);
}

+ (void)track:(NSString *)eventId {
    id tracker = growing_getTracker();
    if (!tracker) {
        return;
    }

    SEL selector = NSSelectorFromString(@"trackCustomEvent:");
    if (![tracker respondsToSelector:selector]) {
        return;
    }
    ((void (*)(id, SEL, NSString *))objc_msgSend)(tracker, selector, eventId);
}

+ (void)track:(NSString *)eventId withNumber:(NSNumber *)number {
    [self track:eventId];
}

+ (void)track:(NSString *)eventId withVariable:(NSDictionary<NSString *, NSObject *> *)variable {
    variable = [GrowingV2Adapter fit3xDictionary:variable];
    id tracker = growing_getTracker();
    if (!tracker) {
        return;
    }

    SEL selector = NSSelectorFromString(@"trackCustomEvent:withAttributes:");
    if (![tracker respondsToSelector:selector]) {
        return;
    }
    ((void (*)(id, SEL, NSString *, NSDictionary *))objc_msgSend)(tracker, selector, eventId, variable);
}

+ (void)track:(NSString *)eventId
     withNumber:(NSNumber *)number
  andVariable:(NSDictionary<NSString *, id> *)variable {
    [self track:eventId withVariable:variable];
}

+ (void)setUserId:(NSString *)userId {
    id tracker = growing_getTracker();
    if (!tracker) {
        return;
    }

    SEL selector = NSSelectorFromString(@"setLoginUserId:");
    if (![tracker respondsToSelector:selector]) {
        return;
    }
    ((void (*)(id, SEL, NSString *))objc_msgSend)(tracker, selector, userId);
}

+ (void)clearUserId {
    id tracker = growing_getTracker();
    if (!tracker) {
        return;
    }

    SEL selector = NSSelectorFromString(@"cleanLoginUserId");
    if (![tracker respondsToSelector:selector]) {
        return;
    }
    ((void (*)(id, SEL))objc_msgSend)(tracker, selector);
}

+ (void)setPeopleVariable:(NSDictionary<NSString *, NSObject *> *)variable {
    variable = [GrowingV2Adapter fit3xDictionary:variable];
    id tracker = growing_getTracker();
    if (!tracker) {
        return;
    }

    SEL selector = NSSelectorFromString(@"setLoginUserAttributes:");
    if (![tracker respondsToSelector:selector]) {
        return;
    }
    ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(tracker, selector, variable);
}

+ (void)setPeopleVariableWithKey:(NSString *)key andStringValue:(NSString *)stringValue {
    if (![key isKindOfClass:[NSString class]] || ![stringValue isKindOfClass:[NSString class]]) {
        return;
    }
    [self setPeopleVariable:@{key: stringValue}];
}

+ (void)setPeopleVariableWithKey:(NSString *)key andNumberValue:(NSNumber *)numberValue {
    if (![key isKindOfClass:[NSString class]] || ![numberValue isKindOfClass:[NSNumber class]]) {
        return;
    }
    [self setPeopleVariable:@{key: numberValue.stringValue}];
}

+ (void)setUserAttributes:(NSDictionary<NSString *, id>*)attributes {
    [self setPeopleVariable:attributes];
}

#pragma mark - Configuration

+ (void)setUrlScheme:(NSString *)urlScheme {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置urlScheme", __FUNCTION__);
}

+ (NSString *)getUrlScheme {
    return [GrowingConfigurationManager sharedInstance].trackConfiguration.urlScheme;
}

+ (void)setEnableLog:(BOOL)enableLog {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置debugEnabled", __FUNCTION__);
}

+ (BOOL)getEnableLog {
    return [GrowingConfigurationManager sharedInstance].trackConfiguration.debugEnabled;
}

+ (void)setFlushInterval:(NSTimeInterval)interval {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置dataUploadInterval", __FUNCTION__);
}

+ (NSTimeInterval)getFlushInterval {
    return [GrowingConfigurationManager sharedInstance].trackConfiguration.dataUploadInterval;
}

+ (void)setSessionInterval:(NSTimeInterval)interval {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置sessionInterval", __FUNCTION__);
}

+ (NSTimeInterval)getSessionInterval {
    return [GrowingConfigurationManager sharedInstance].trackConfiguration.sessionInterval;
}

+ (void)setDailyDataLimit:(NSUInteger)numberOfKiloByte {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置cellularDataLimit，单位MB", __FUNCTION__);
}

+ (NSUInteger)getDailyDataLimit {
    return [GrowingConfigurationManager sharedInstance].trackConfiguration.cellularDataLimit;
}

+ (void)setTrackerHost:(NSString *)host {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置dataCollectionServerHost", __FUNCTION__);
}

#pragma mark - Modules
#pragma mark Hybrid Module

+ (void)bridgeForWKWebView:(WKWebView *)webView {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，若集成无埋点SDK，将自动bridge；集成埋点SDK，则需要额外集成H5混合模块",
                __FUNCTION__);
}

#pragma mark Advertising Module

+ (void)setReadClipBoardEnable:(BOOL)enabled {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置readClipboardEnabled，需要额外集成广告模块", __FUNCTION__);
}

+ (void)setAsaEnabled:(BOOL)asaEnabled {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置ASAEnabled，需要额外集成广告模块", __FUNCTION__);
}

+ (void)registerDeeplinkHandler:(void (^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))handler {
    GIOLogDebug(@"[V2Adapter] %s 请通过初始化配置deepLinkCallback，需要额外集成广告模块", __FUNCTION__);
}

+ (BOOL)handleUrl:(NSURL *)aUrl {
    GIOLogDebug(@"[V2Adapter] %s 自动适配，无需手动调用", __FUNCTION__);
    return NO;
}

+ (BOOL)isDeeplinkUrl:(NSURL *)url {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return NO;
}

+ (BOOL)doDeeplinkByUrl:(NSURL *)url
               callback:(void (^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))callback {
    GIOLogDebug(@"[V2Adapter] %s 请使用-[GrowingAdvertising doDeeplinkByUrl:callback:]替代，需要额外集成广告模块",
                __FUNCTION__);
    return NO;
}

#pragma mark APM Module

+ (void)setUploadExceptionEnable:(BOOL)uploadExceptionEnable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃，如需上报崩溃异常，请额外集成APM模块", __FUNCTION__);
}

#pragma mark - Deprecated

+ (void)setAspectMode:(GrowingAspectMode)aspectMode {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (GrowingAspectMode)getAspectMode {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return GrowingAspectModeDynamicSwizzling;
}

+ (void)setBundleId:(NSString *)bundleId {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (NSString *)getBundleId {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return @"";
}

+ (void)setEnableDiagnose:(BOOL)enable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)disablePushTrack:(BOOL)disable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (BOOL)getDisablePushTrack {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return NO;
}

+ (void)setEnableLocationTrack:(BOOL)enable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (BOOL)getEnableLocationTrack {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
    return NO;
}

+ (void)setEncryptStringBlock:(NSString * (^)(NSString *string))block {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)disable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setDataHost:(NSString *)host {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setAssetsHost:(NSString *)host {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setGtaHost:(NSString *)host {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setWsHost:(NSString *)host {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setReportHost:(NSString *)host {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setZone:(NSString *)zone {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setDeviceIDModeToCustomBlock:(NSString * (^)(void))customBlock {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setEvar:(NSDictionary<NSString *, NSObject *> *)variable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setEvarWithKey:(NSString *)key andStringValue:(NSString *)stringValue {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setEvarWithKey:(NSString *)key andNumberValue:(NSNumber *)numberValue {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)setVisitor:(NSDictionary<NSString *, NSObject *> *)variable {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

+ (void)registerRealtimeReportHandler:(void (^)(NSDictionary *eventObject))handler {
    GIOLogDebug(@"[V2Adapter] %s 已废弃", __FUNCTION__);
}

@end
