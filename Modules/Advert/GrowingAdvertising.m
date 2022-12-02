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
#import "Modules/Advert/Event/GrowingAdvertEventType.h"
#import "Modules/Advert/Request/GrowingAdPreRequest.h"
#import "Modules/Advert/AppleSearchAds/GrowingAsaFetcher.h"

#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Core/GrowingContext.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Network/Request/GrowingNetworkConfig.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSURL+GrowingHelper.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

#import <WebKit/WebKit.h>

GrowingMod(GrowingAdvertising)

NSString *const GrowingAdvertisingErrorDomain = @"com.growingio.advertising";

@interface GrowingAdvertising () <GrowingDeepLinkHandlerProtocol, GrowingEventInterceptor>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, copy) NSString *userAgent;

@end

@implementation GrowingAdvertising

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {
    [[GrowingEventManager sharedInstance] addInterceptor:self];
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
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
    [channels addObject:[GrowingEventChannel eventChannelWithEventTypes:@[GrowingEventTypeActivate]
                                                            urlTemplate:kGrowingEventApiTemplate
                                                          isCustomEvent:NO]];
}

#pragma mark - Public Method

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)setReadClipboardEnabled:(BOOL)enabled {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (enabled == trackConfiguration.readClipboardEnabled) {
            return;
        }
        trackConfiguration.readClipboardEnabled = enabled;
    }];
}

- (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(GrowingAdDeepLinkCallback)callback {
    return [self growingHandlerUrl:url isManual:YES callback:callback];
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
            [self handleDeepLinkCallback:callback customParams:nil startDate:nil error:self.illegalURLError];
        }
        return NO;
    }
    
    // Universal Link 短链
    if ([GrowingAdUtils isShortChainUlink:url]) {
        NSDate *startDate = [NSDate date];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            if ([self SDKDoNotTrack]) {
                return;
            }
            [self accessUserAgent:^(NSString * _Nullable userAgent) {
                if ([self SDKDoNotTrack]) {
                    return;
                }
                GrowingAdPreRequest *eventRequest = nil;
                eventRequest = [[GrowingAdPreRequest alloc] init];
                eventRequest.trackId = [url.path componentsSeparatedByString:@"/"].lastObject;
                eventRequest.isManual = isManual;
                eventRequest.userAgent = userAgent;
                id <GrowingEventNetworkService> service = [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
                if (!service) {
                    GIOLogError(@"[GrowingAdvertising] -growingHandlerUrl:isManual:callback: error : no network service support");
                    return;
                }
                [service sendRequest:eventRequest completion:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data, NSError * _Nonnull error) {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        NSDictionary *dic = [[data growingHelper_dictionaryObject] objectForKey:@"data"];
                        [self getDeeplinkParams:dic isManual:isManual block:^(BOOL completed, NSDictionary *params, NSDictionary * _Nullable customParams) {
                            if (completed) {
                                [self generateAppReengage:params];
                                [self handleDeepLinkCallback:callback customParams:customParams startDate:startDate error:nil];
                            }
                        }];
                    } else {
                        [self handleDeepLinkCallback:callback customParams:nil startDate:startDate error:self.requestFailedError];
                    }
                }];
            }];
        }];
        return YES;
    }
    
    // Universal Link 长链 / URL Scheme
    NSDictionary *dic = url.growingHelper_queryDict;
    if (dic[@"deep_link_id"]) {
        [self getDeeplinkParams:dic isManual:isManual block:^(BOOL completed, NSDictionary *params, NSDictionary * _Nullable customParams) {
            if (completed) {
                [self generateAppReengage:params];
                [self handleDeepLinkCallback:callback customParams:customParams startDate:nil error:nil];
            }
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
        
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if ([GrowingAdUtils isActivateWrote]) {
            // activate 在同一安装周期内仅需发送一次
            if (![GrowingAdUtils isActivateDefer]) {
                // AppActivation
                if (trackConfiguration.ASAEnabled) {
                    [GrowingAsaFetcher startFetchWithTimeOut:GrowingAsaFetcherDefaultTimeOut];
                }
            }
            return;
        }
        
        if (!trackConfiguration.readClipboardEnabled) {
            GIOLogDebug(@"[GrowingAdvertising] readClipboardEnabled is false");
            [self generateAppActivation];
            return;
        }
        
        // 不直接在 GrowingThread 执行是因为 UIPasteboard 调用**可能**会卡死线程，实测在主线程调用有卡死案例
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *content = [UIPasteboard generalPasteboard].string;
            NSDictionary *dic = [GrowingAdUtils dictFromPasteboard:content];

            [GrowingDispatchManager dispatchInGrowingThread:^{
                if (dic.count == 0
                    || ![dic[@"type"] isEqualToString:@"gads"]
                    || ![dic[@"scheme"] isEqualToString:[GrowingDeviceInfo currentDeviceInfo].urlScheme]) {
                    [self generateAppActivation];
                    return;
                }
                
                [self getDeeplinkParams:dic isManual:NO block:^(BOOL completed, NSDictionary *params, NSDictionary * _Nullable customParams) {
                    if (completed) {
                        [self generateAppDefer:params];
                        [self handleDeepLinkCallback:nil customParams:customParams startDate:nil error:nil];
                    }
                }];
            }];
            
            if ([[UIPasteboard generalPasteboard].string isEqualToString:content]) {
                [UIPasteboard generalPasteboard].string = @"";
            }
        });
    }];
}

- (void)getDeeplinkParams:(NSDictionary *)originDic
                 isManual:(BOOL)isManual
                    block:(void(^)(BOOL, NSDictionary *, NSDictionary * _Nullable))paramsBlock {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"deep_link_id"] = originDic[@"deep_link_id"];
    dictM[@"deep_click_id"] = originDic[@"deep_click_id"];
    dictM[@"deep_click_time"] = originDic[@"deep_click_time"];
    BOOL completed = dictM.count == 3;
    
    NSString *encode = originDic[@"deep_params"];
    NSDictionary *customParams = nil;
    if (encode.length > 0) {
        NSString *decode = [GrowingAdUtils URLDecodedString:encode];
        if (decode.length > 0) {
            dictM[@"deep_params"] = decode;
            customParams = decode.growingHelper_dictionaryObject;
        }
    }
    
    if (isManual) {
        dictM[@"deep_type"] = @"in_app";
    }
    
    if (paramsBlock) {
        paramsBlock(completed, dictM.copy, customParams);
    }
}

#pragma mark - Event handler

- (void)generateAppActivation {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (trackConfiguration.ASAEnabled) {
        [GrowingAsaFetcher startFetchWithTimeOut:GrowingAsaFetcherDefaultTimeOut];
    }
    
    [self accessUserAgent:^(NSString *userAgent) {
        if ([self SDKDoNotTrack]) {
            return;
        }

        GrowingActivateBuilder *builder = GrowingActivateEvent.builder
                                                              .setEventName(GrowingAdvertEventNameActivate);
        if (userAgent.length > 0) {
            builder.setAttributes(@{@"userAgent" : userAgent.copy});
        }
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        [GrowingAdUtils setActivateWrote:YES];
    }];
}

- (void)generateAppDefer:(NSDictionary *)dic {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if ([self SDKDoNotTrack]) {
            return;
        }

        GrowingActivateBuilder *builder = GrowingActivateEvent.builder
                                                              .setEventName(GrowingAdvertEventNameDefer)
                                                              .setAttributes(dic);
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        [GrowingAdUtils setActivateWrote:YES];
        [GrowingAdUtils setActivateDefer:YES];
    }];
}

- (void)generateAppReengage:(NSDictionary *)dic {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if ([self SDKDoNotTrack]) {
            return;
        }
        
        GrowingActivateBuilder *builder = GrowingActivateEvent.builder
                                                              .setEventName(GrowingAdvertEventNameReengage)
                                                              .setAttributes(dic);
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
    }];
}

- (void)handleDeepLinkCallback:(nullable GrowingAdDeepLinkCallback)callback
                  customParams:(nullable NSDictionary *)customParams
                     startDate:(nullable NSDate *)startDate
                         error:(nullable NSError *)error {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!callback && !trackConfiguration.deepLinkCallback) {
        return;
    }
    if (!callback) {
        callback = trackConfiguration.deepLinkCallback;
    }
    
    if (callback) {
        NSTimeInterval processTime = startDate ? [[NSDate date] timeIntervalSinceDate:startDate] : 0.0;

        [GrowingDispatchManager dispatchInMainThread:^{
            if (error) {
                callback(nil, processTime, error);
            } else if (customParams.count == 0) {
                callback(nil, processTime, self.noQueryError);
            } else {
                callback(customParams.copy, processTime, nil);
            }
        }];
    }
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
