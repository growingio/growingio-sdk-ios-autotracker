//
//  GrowingCoreKit.h
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

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GrowingAspectMode) {
    GrowingAspectModeSubClass,
    GrowingAspectModeDynamicSwizzling,
};

@interface Growing : NSObject

#pragma mark - Adapter

+ (NSString *)sdkVersion;
+ (NSString *)getDeviceId;
+ (NSString *)getVisitUserId;
+ (NSString *)getSessionId;
+ (void)disableDataCollect;
+ (void)enableDataCollect;
+ (void)track:(NSString *)eventId;
+ (void)track:(NSString *)eventId withNumber:(NSNumber *)number;
+ (void)track:(NSString *)eventId withVariable:(NSDictionary<NSString *, id> *)variable;
+ (void)track:(NSString *)eventId withNumber:(NSNumber *)number andVariable:(NSDictionary<NSString *, id> *)variable;
+ (void)setUserId:(NSString *)userId;
+ (void)clearUserId;
+ (void)setPeopleVariable:(NSDictionary<NSString *, NSObject *> *)variable;
+ (void)setPeopleVariableWithKey:(NSString *)key andStringValue:(NSString *)stringValue;
+ (void)setPeopleVariableWithKey:(NSString *)key andNumberValue:(NSNumber *)numberValue;
+ (void)setUserAttributes:(NSDictionary<NSString *, id> *)attributes;  // cdp

#pragma mark - Configuration

+ (void)setUrlScheme:(NSString *)urlScheme;
+ (NSString *)getUrlScheme;
+ (void)setEnableLog:(BOOL)enableLog;
+ (BOOL)getEnableLog;
+ (void)setFlushInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)getFlushInterval;
+ (void)setSessionInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)getSessionInterval;
+ (void)setDailyDataLimit:(NSUInteger)numberOfKiloByte;
+ (NSUInteger)getDailyDataLimit;
+ (void)setTrackerHost:(NSString *)host;

#pragma mark - Modules
#pragma mark Hybrid Module

+ (void)bridgeForWKWebView:(WKWebView *)webView;

#pragma mark Advertising Module

+ (void)setReadClipBoardEnable:(BOOL)enabled;
+ (void)setAsaEnabled:(BOOL)asaEnabled;
+ (void)registerDeeplinkHandler:(void (^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))handler;
+ (BOOL)handleUrl:(NSURL *)url;
+ (BOOL)isDeeplinkUrl:(NSURL *)url;
+ (BOOL)doDeeplinkByUrl:(NSURL *)url
               callback:(void (^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))callback;

#pragma mark APM Module

+ (void)setUploadExceptionEnable:(BOOL)uploadExceptionEnable;

#pragma mark - Deprecated

+ (void)setAspectMode:(GrowingAspectMode)aspectMode;
+ (GrowingAspectMode)getAspectMode;
+ (void)setBundleId:(NSString *)bundleId;
+ (NSString *)getBundleId;
+ (void)setEnableDiagnose:(BOOL)enable;
+ (void)disablePushTrack:(BOOL)disable;
+ (BOOL)getDisablePushTrack;
+ (void)setEnableLocationTrack:(BOOL)enable;
+ (BOOL)getEnableLocationTrack;
+ (void)setEncryptStringBlock:(NSString * (^)(NSString *string))block;
+ (void)disable;
+ (void)setDataHost:(NSString *)host;
+ (void)setAssetsHost:(NSString *)host;
+ (void)setGtaHost:(NSString *)host;
+ (void)setWsHost:(NSString *)host;
+ (void)setReportHost:(NSString *)host;
+ (void)setZone:(NSString *)zone;
+ (void)setDeviceIDModeToCustomBlock:(NSString * (^)(void))customBlock;
+ (void)setEvar:(NSDictionary<NSString *, NSObject *> *)variable;
+ (void)setEvarWithKey:(NSString *)key andStringValue:(NSString *)stringValue;
+ (void)setEvarWithKey:(NSString *)key andNumberValue:(NSNumber *)numberValue;
+ (void)setVisitor:(NSDictionary<NSString *, NSObject *> *)variable;
+ (void)registerRealtimeReportHandler:(void (^)(NSDictionary *eventObject))handler;

#pragma mark - Unavailable

// saas
+ (void)startWithAccountId:(NSString *)accountId withSampling:(CGFloat)sampling NS_UNAVAILABLE;
+ (void)startWithAccountId:(NSString *)accountId NS_UNAVAILABLE;

// cdp
+ (void)startWithAccountId:(NSString *)accountId
              dataSourceId:(NSString *)dataSourceId
              withSampling:(CGFloat)sampling NS_UNAVAILABLE;
+ (void)startWithAccountId:(NSString *)accountId dataSourceId:(NSString *)dataSourceId NS_UNAVAILABLE;
+ (void)track:(NSString *)eventId withItem:(NSString *)itemId itemKey:(NSString *)itemKey NS_UNAVAILABLE;
+ (void)track:(NSString *)eventId
    withVariable:(NSDictionary<NSString *, id> *)variable
         forItem:(NSString *)itemId
         itemKey:(NSString *)itemKey NS_UNAVAILABLE;
+ (void)trackPage:(NSString *)pageName NS_UNAVAILABLE;
+ (void)trackPage:(NSString *)pageName withVariable:(NSDictionary<NSString *, id> *)variable NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
