//
//  GrowingAdvertising.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
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

#import "Modules/Advert/Public/GrowingAdvertising.h"
#import "Modules/Advert/Utils/GrowingAdUtils.h"
#import "Modules/Advert/Event/GrowingActivateEvent.h"
#import "Modules/Advert/Event/GrowingReengageEvent.h"
#import "Modules/Advert/Event/GrowingAdvertEventType.h"
#import "Modules/Advert/Request/GrowingAdPreRequest.h"
#import "Modules/Advert/Request/GrowingAdEventRequest.h"
#import "Modules/Advert/AppleSearchAds/GrowingAsaFetcher.h"

#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Core/GrowingContext.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "GrowingTrackerCore/Helpers/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSURL+GrowingHelper.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import <WebKit/WebKit.h>

GrowingMod(GrowingAdvertising)

NSString *const GrowingAdvertisingErrorDomain = @"com.growingio.advertising";

@interface GrowingAdvertising () <GrowingDeepLinkHandlerProtocol, GrowingEventInterceptor>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, strong) NSError *deepLinkError;

@end

@implementation GrowingAdvertising

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {
    [[GrowingEventManager sharedInstance] addInterceptor:self];
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
    
    if ([GrowingConfigurationManager sharedInstance].trackConfiguration.ASAEnabled) {
        [GrowingAsaFetcher startFetchWithTimeOut:GrowingAsaFetcherDefaultTimeOut];
    }
    
    [self loadClipboard];
}

- (void)growingModSetDataCollectionEnabled:(GrowingContext *)context {
    NSDictionary *customParam = context.customParam;
    BOOL dataCollectionEnabled = ((NSNumber *)customParam[@"dataCollectionEnabled"]).boolValue;
    if (dataCollectionEnabled) {
        [self loadClipboard];
    }
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
    return [self growingHandlerUrl:url isManual:NO callback:nil];
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerChannels:(NSMutableArray<GrowingEventChannel *> *)channels {
    [channels addObject:[GrowingEventChannel eventChannelWithEventTypes:@[GrowingEventTypeReengage, GrowingEventTypeActivate]
                                                            urlTemplate:@"app/%@/ios/ctvt"
                                                          isCustomEvent:NO]];
}

- (id<GrowingRequestProtocol> _Nullable)growingEventManagerRequestWithChannel:(GrowingEventChannel *_Nullable)channel {
    if (channel.eventTypes.count > 0 && [channel.eventTypes indexOfObject:GrowingEventTypeActivate] != NSNotFound) {
        return [[GrowingAdEventRequest alloc] init];
    }
    return nil;
}

#pragma mark - Public Method

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });
    return _sharedInstance;
}

- (void)setReadClipBoardEnabled:(BOOL)enabled {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (enabled == trackConfiguration.readClipBoardEnabled) {
            return;
        }
        trackConfiguration.readClipBoardEnabled = enabled;
    }];
}

- (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(GrowingAdDeepLinkCallback)callback {
    return [self growingHandlerUrl:url isManual:YES callback:callback];
}

- (void)trackAppInstall {
    [self trackAppInstallWithAttributes:nil];
}

- (void)trackAppInstallWithAttributes:(NSDictionary <NSString *, NSString *> *_Nullable)attributes {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (trackConfiguration.autoInstall) {
            return;
        }
        
        [self sendActivateEvent:attributes];
    }];
}

#pragma mark - Private Method

- (BOOL)SDKDoNotTrack {
    if (![GrowingConfigurationManager sharedInstance].trackConfiguration.dataCollectionEnabled) {
        GIOLogDebug(@"[GrowingAdvertising] dataCollectionEnabled is false");
        return YES;
    }
    return NO;
}

- (BOOL)growingHandlerUrl:(NSURL *)url isManual:(BOOL)isManual callback:(GrowingAdDeepLinkCallback)callback {
    if (![GrowingAdUtils isGrowingIOUrl:url]) {
        if (isManual) {
            // 若手动触发 callback 则报错
            [self handleDeepLinkError:[self illegalURLError] callback:callback startDate:nil];
        }
        return NO;
    }

    NSString *reengageType = [url.scheme hasPrefix:@"growing."] ? @"url_scheme" : @"universal_link";
    
    // ShortChain
    if ([GrowingAdUtils isShortChainUlink:url]) {
        NSDate *startDate = [NSDate date];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            if ([self SDKDoNotTrack]) {
                return;
            }
            [self accessUserAgent:^(NSString *userAgent) {
                if ([self SDKDoNotTrack]) {
                    return;
                }
                GrowingAdPreRequest *eventRequest = nil;
                eventRequest = [[GrowingAdPreRequest alloc] init];
                eventRequest.hashId = [url.path componentsSeparatedByString:@"/"].lastObject;
                eventRequest.isManual = isManual;
                eventRequest.userAgent = userAgent;
                eventRequest.query = [url.query growingHelper_dictionaryObject];
                id <GrowingEventNetworkService> service = [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
                if (!service) {
                    GIOLogError(@"[GrowingAdvertising] -growingHandlerUrl:isManual:callback: error : no network service support");
                    return;
                }
                [service sendRequest:eventRequest completion:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data, NSError * _Nonnull error) {
                    if ([self SDKDoNotTrack]) {
                        return;
                    }
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        NSDictionary *dataDict = [[data growingHelper_dictionaryObject] objectForKey:@"data"];
                        NSDictionary *customParams = [dataDict objectForKey:@"custom_params"];
                        [self sendReengageEvent:dataDict reengageType:reengageType customParams:customParams startDate:startDate callback:callback];
                    } else {
                        [self handleDeepLinkError:[self requestFailedError] callback:callback startDate:startDate];
                    }
                }];
            }];
        }];
        return YES;
    }
    // 如果是长链
    NSDictionary *dataDict = url.growingHelper_queryDict;
    if (dataDict[@"link_id"]) {
        [GrowingDispatchManager dispatchInGrowingThread:^{
            if ([self SDKDoNotTrack]) {
                return;
            }
            NSString *customStr = dataDict[@"custom_params"] ?: @"";
            NSDictionary *customParams = [GrowingAdUtils URLDecodedString:customStr].growingHelper_dictionaryObject;
            [self sendReengageEvent:dataDict reengageType:reengageType customParams:customParams startDate:nil callback:callback];
        }];
        return YES;
    }
    return NO;
}

- (void)accessUserAgent:(void (^)(NSString *_Nullable userAgent))block {
    if (!block) {
        return;
    }
    if (self.userAgent) {
        [GrowingDispatchManager dispatchInGrowingThread:^{
            block(self.userAgent);
        }];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // WKWebView 的 initWithFrame 方法偶发崩溃，这里 @try @catch 保护
        @try {
            self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
            __weak typeof(self) weakSelf = self;
            [self.wkWebView evaluateJavaScript:@"navigator.userAgent"
                             completionHandler:^(_Nullable id response, NSError *_Nullable error) {
                [GrowingDispatchManager dispatchInGrowingThread:^{
                    if (error || !response) {
                        GIOLogError(@"[GrowingAdvertising] WKWebView evaluateJavaScript load UA error:%@", error);
                        block(nil);
                    } else {
                        weakSelf.userAgent = response;
                        block(response);
                    }
                }];
                weakSelf.wkWebView = nil;
            }];
        } @catch (NSException *exception) {
            GIOLogDebug(@"[GrowingAdvertising] loadUserAgentWithCompletion crash :%@", exception);
            [GrowingDispatchManager dispatchInGrowingThread:^{
                block(nil);
            }];
        }
    });
}

- (void)loadClipboard {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if ([self SDKDoNotTrack]) {
            return;
        }
        if ([GrowingAdUtils isActivateWrote]) {
            // activate 在同一安装周期内仅需发送一次
            return;
        }
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (!trackConfiguration.readClipBoardEnabled) {
            GIOLogDebug(@"[GrowingAdvertising] readClipBoardEnabled is false");
            if (trackConfiguration.autoInstall) {
                [self sendActivateEvent:nil];
            }
            return;
        }
        
        // 不直接在 GrowingThread 执行是因为 UIPasteboard 调用**可能**会卡死线程，实测在主线程调用有卡死案例
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *clipboardContent = [UIPasteboard generalPasteboard].string;
            NSDictionary *clipboardDict = [GrowingAdUtils dictFromPasteboard:clipboardContent];
            if (clipboardDict.count == 0
                || ![clipboardDict[@"typ"] isEqualToString:@"gads"]
                || ![clipboardDict[@"scheme"] isEqualToString:[GrowingDeviceInfo currentDeviceInfo].urlScheme]) {
                if (trackConfiguration.autoInstall) {
                    [self sendActivateEvent:nil];
                }
                return;
            }
            
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            dictM[@"link_id"] = clipboardDict[@"link_id"];
            dictM[@"click_id"] = clipboardDict[@"click_id"];
            dictM[@"tm_click"] = clipboardDict[@"tm_click"];
            dictM[@"cl"] = @"defer";
            if (trackConfiguration.autoInstall) {
                [self sendActivateEvent:dictM.copy];
            }
            
            NSString *customStr = @"";
            NSDictionary *v1 = clipboardDict[@"v1"];
            if ([v1 isKindOfClass:[NSDictionary class]]) {
                customStr = v1[@"custom_params"] ?: @"";
            }
            NSDictionary *customParams = [GrowingAdUtils URLDecodedString:customStr].growingHelper_dictionaryObject;
            NSString *reengageType = @"universal_link";
            [self sendReengageEvent:dictM reengageType:reengageType customParams:customParams startDate:nil callback:nil];
            
            if ([[UIPasteboard generalPasteboard].string isEqualToString:clipboardContent]) {
                [UIPasteboard generalPasteboard].string = @"";
            }
        });
    }];
}

#pragma mark - Event handler

- (void)sendActivateEvent:(nullable NSDictionary *)clipboardParams {
    [self accessUserAgent:^(NSString *userAgent) {
        if ([self SDKDoNotTrack]) {
            return;
        }
        if ([GrowingAdUtils isActivateWrote]) {
            // activate 在同一安装周期内仅需发送一次
            return;
        }
        
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        dictM[@"ua"] = userAgent;
        [dictM addEntriesFromDictionary:clipboardParams];
        GrowingActivateBuilder *builder = GrowingActivateEvent.builder.setExtraParams(dictM);
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        [GrowingAdUtils setActivateWrote:YES];
    }];
}

- (void)sendReengageEvent:(NSDictionary *)parameters
             reengageType:(NSString *)reengageType
             customParams:(nullable NSDictionary *)customParams
                startDate:(nullable NSDate *)startDate
                 callback:(nullable GrowingAdDeepLinkCallback)callback {
    [self accessUserAgent:^(NSString *userAgent) {
        if ([self SDKDoNotTrack]) {
            return;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"rngg_mch"] = reengageType;
        params[@"ua"] = userAgent;
        params[@"link_id"] = [parameters objectForKey:@"link_id"];
        params[@"click_id"] = [parameters objectForKey:@"click_id"];
        params[@"tm_click"] = [parameters objectForKey:@"tm_click"];
        params[@"var"] = customParams ?: @{};
        GrowingReengageBuilder *builder = GrowingReengageEvent.builder.setExtraParams(params);
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        
        [self handleDeepLinkCallback:callback reengageType:reengageType customParams:customParams ?: @{} startDate:startDate];
    }];
}

- (void)handleDeepLinkError:(NSError *)error
                   callback:(nullable GrowingAdDeepLinkCallback)callback
                  startDate:(nullable NSDate *)startDate {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!callback && !trackConfiguration.deepLinkCallback) {
        return;
    }
    if (!callback) {
        callback = trackConfiguration.deepLinkCallback;
    }
    
    [GrowingDispatchManager dispatchInMainThread:^{
        if (callback) {
            callback(nil, startDate ? [[NSDate date] timeIntervalSinceDate:startDate] : 0.0, error);
        }
    }];
}

- (void)handleDeepLinkCallback:(nullable GrowingAdDeepLinkCallback)callback
                  reengageType:(NSString *)reengageType
                  customParams:(NSDictionary *)customParams
                     startDate:(nullable NSDate *)startDate {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!callback && !trackConfiguration.deepLinkCallback) {
        return;
    }
    if (!callback) {
        callback = trackConfiguration.deepLinkCallback;
    }
    
    NSError *error = nil;
    if (customParams.count == 0) {
        error = self.noQueryError;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:customParams];
    if ([dict objectForKey:@"_gio_var"]) {
        [dict removeObjectForKey:@"_gio_var"];
    }
    if (![dict objectForKey:@"+deeplink_mechanism"]) {
        [dict setObject:reengageType forKey:@"+deeplink_mechanism"];
    }
    
    [GrowingDispatchManager dispatchInMainThread:^{
        if (callback) {
            callback(dict, startDate ? [[NSDate date] timeIntervalSinceDate:startDate] : 0.0, error);
        }
    }];
}

#pragma mark - Error

- (NSError *)noQueryError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingNoQueryError
                           userInfo:@{NSLocalizedDescriptionKey : @"no custom parameters"}];
}

- (NSError *)illegalURLError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingIllegalURLError
                           userInfo:@{NSLocalizedDescriptionKey : @"this is not GrowingIO DeepLink URL"}];
}

- (NSError *)requestFailedError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingRequestFailedError
                           userInfo:@{NSLocalizedDescriptionKey : @"pre-request failed"}];
}

@end
