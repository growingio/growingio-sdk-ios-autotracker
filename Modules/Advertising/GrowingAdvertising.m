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

#import "Modules/Advertising/Public/GrowingAdvertising.h"
#import "Modules/Advertising/AppleSearchAds/GrowingAsaFetcher.h"
#import "Modules/Advertising/Event/GrowingActivateEvent.h"
#import "Modules/Advertising/Event/GrowingAdEventType.h"
#import "Modules/Advertising/Request/GrowingAdPreRequest.h"
#import "Modules/Advertising/Utils/GrowingAdUtils.h"

#import "GrowingTrackerCore/Core/GrowingContext.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingULAppLifecycle.h"

#import <WebKit/WebKit.h>

GrowingMod(GrowingAdvertising)

NSString *const GrowingAdvertisingErrorDomain = @"com.growingio.advertising";

@interface GrowingAdvertising () <GrowingDeepLinkHandlerProtocol,
                                  GrowingEventInterceptor,
                                  GrowingULAppLifecycleDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSURL *deeplinkUrl;
@property (nonatomic, strong) NSMutableArray<GrowingBaseBuilder *> *builders;

@end

@implementation GrowingAdvertising

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (config.deepLinkHost && config.deepLinkHost.length > 0) {
        NSString *host = [NSURL URLWithString:config.deepLinkHost].host;
        if (!host) {
            @throw [NSException exceptionWithName:@"初始化异常"
                                           reason:@"您所配置的DeepLinkHost不符合规范"
                                         userInfo:nil];
        }
    } else {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"请在SDK初始化时，配置DeepLinkHost" userInfo:nil];
    }

    self.builders = [NSMutableArray array];
    [[GrowingEventManager sharedInstance] addInterceptor:self];
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
    [GrowingULAppLifecycle.sharedInstance addAppLifecycleDelegate:self];
    [self loadClipboard];
}

- (void)growingModSetDataCollectionEnabled:(GrowingContext *)context {
    NSDictionary *customParam = context.customParam;
    BOOL dataCollectionEnabled = ((NSNumber *)customParam[@"dataCollectionEnabled"]).boolValue;
    if (dataCollectionEnabled) {
        [self loadClipboard];
        if (self.deeplinkUrl) {
            [self growingHandlerUrl:self.deeplinkUrl.copy isManual:NO callback:nil];
            self.deeplinkUrl = nil;  // 避免多线程环境下有可能多发 AppReengage
        }
    }
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
    return [self growingHandlerUrl:url isManual:NO callback:nil];
}

#pragma mark - GrowingULAppLifecycleDelegate

- (void)applicationDidBecomeActive {
    // 避免在SessionId刷新的情况下，app_reengage事件先于VISIT事件发送，导致其SessionId与VISIT事件不一致
    [GrowingDispatchManager dispatchInGrowingThread:^{
        for (GrowingBaseBuilder *builder in self.builders) {
            [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        }
        self.builders = [NSMutableArray array];
    }];
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

    if (!isManual) {
        // 适配初始化时， dataCollectionEnabled == NO 的场景
        self.deeplinkUrl = url.copy;
    }

    if ([self SDKDoNotTrack]) {
        return NO;
    }

    // Universal Link 短链
    if ([GrowingAdUtils isShortChainUlink:url]) {
        NSDate *startDate = [NSDate date];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            if ([self SDKDoNotTrack]) {
                return;
            }
            [self accessUserAgent:^(NSString *_Nullable userAgent) {
                if ([self SDKDoNotTrack]) {
                    return;
                }
                self.deeplinkUrl = nil;
                if (!userAgent) {
                    return;
                }
                GrowingAdPreRequest *eventRequest = nil;
                eventRequest = [[GrowingAdPreRequest alloc] init];
                eventRequest.trackId = [url.path componentsSeparatedByString:@"/"].lastObject;
                eventRequest.isManual = isManual;
                eventRequest.userAgent = userAgent;
                id<GrowingEventNetworkService> service =
                    [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
                if (!service) {
                    GIOLogError(
                        @"[GrowingAdvertising] -growingHandlerUrl:isManual:callback: error : no network service "
                        @"support");
                    return;
                }
                [service sendRequest:eventRequest
                          completion:^(NSHTTPURLResponse *_Nonnull httpResponse,
                                       NSData *_Nonnull data,
                                       NSError *_Nonnull error) {
                              if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                                  NSDictionary *dic = [[data growingHelper_dictionaryObject] objectForKey:@"data"];
                                  [self getDeeplinkParams:dic
                                                 isManual:isManual
                                                    block:^(BOOL completed,
                                                            NSDictionary *params,
                                                            NSDictionary *_Nullable customParams) {
                                                        if (completed) {
                                                            [self generateAppReengage:params];
                                                            [self handleDeepLinkCallback:callback
                                                                            customParams:customParams
                                                                               startDate:startDate
                                                                                   error:nil];
                                                        }
                                                    }];
                              } else {
                                  [self handleDeepLinkCallback:callback
                                                  customParams:nil
                                                     startDate:startDate
                                                         error:self.requestFailedError];
                              }
                          }];
            }];
        }];
        return YES;
    }

    // Universal Link 长链 / URL Scheme
    NSDictionary *dic = url.growingHelper_queryDict;
    if (dic[@"deep_link_id"]) {
        self.deeplinkUrl = nil;
        [self getDeeplinkParams:dic
                       isManual:isManual
                          block:^(BOOL completed, NSDictionary *params, NSDictionary *_Nullable customParams) {
                              if (completed) {
                                  [self generateAppReengage:params];
                                  [self handleDeepLinkCallback:callback
                                                  customParams:customParams
                                                     startDate:nil
                                                         error:nil];
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
            if (!self.wkWebView) {
                self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
            }
            __weak typeof(self) weakSelf = self;
            [self.wkWebView
                evaluateJavaScript:@"navigator.userAgent"
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
                if (dic.count == 0 || ![dic[@"type"] isEqualToString:@"gads"] ||
                    ![dic[@"scheme"] isEqualToString:[GrowingDeviceInfo currentDeviceInfo].urlScheme]) {
                    [self generateAppActivation];
                    return;
                }

                [self getDeeplinkParams:dic
                               isManual:NO
                                  block:^(BOOL completed, NSDictionary *params, NSDictionary *_Nullable customParams) {
                                      if (completed) {
                                          [self generateAppDefer:params];
                                          [self handleDeepLinkCallback:nil
                                                          customParams:customParams
                                                             startDate:nil
                                                                 error:nil];
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
                    block:(void (^)(BOOL, NSDictionary *, NSDictionary *_Nullable))paramsBlock {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"deep_link_id"] = originDic[@"deep_link_id"];
    dictM[@"deep_click_id"] = originDic[@"deep_click_id"];
    dictM[@"deep_click_time"] = originDic[@"deep_click_time"];
    if ([dictM[@"deep_click_time"] isKindOfClass:[NSNumber class]]) {
        dictM[@"deep_click_time"] = [NSString stringWithFormat:@"%@", dictM[@"deep_click_time"]];
    }

    BOOL completed = dictM.count == 3;

    NSString *encode = originDic[@"deep_params"];
    NSDictionary *customParams = nil;
    if ([encode isKindOfClass:[NSString class]]) {
        if (encode.length > 0) {
            NSString *decode = [GrowingAdUtils URLDecodedString:encode];
            if (decode.length > 0) {
                dictM[@"deep_params"] = decode;
                customParams = decode.growingHelper_dictionaryObject;
            }
        }
    } else if ([encode isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)encode;
        dictM[@"deep_params"] = dic.growingHelper_jsonString;
        customParams = dic.copy;
    }

    if (isManual) {
        dictM[@"deep_type"] = @"inapp";
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

        GrowingActivateBuilder *builder = GrowingActivateEvent.builder.setEventName(GrowingAdEventNameActivate);
        if (userAgent.length > 0) {
            builder.setAttributes(@{@"userAgent": userAgent.copy});
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

        GrowingActivateBuilder *builder =
            GrowingActivateEvent.builder.setEventName(GrowingAdEventNameDefer).setAttributes(dic);
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

        GrowingActivateBuilder *builder =
            GrowingActivateEvent.builder.setEventName(GrowingAdEventNameReengage).setAttributes(dic);
        if ([GrowingSession currentSession].state == GrowingSessionStateActive) {
            [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        } else {
            [self.builders addObject:builder];
        }
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
                           userInfo:@{NSLocalizedDescriptionKey: @"no custom parameters"}];
}

- (NSError *)illegalURLError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingIllegalURLError
                           userInfo:@{NSLocalizedDescriptionKey: @"this is not GrowingIO DeepLink URL"}];
}

- (NSError *)requestFailedError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingRequestFailedError
                           userInfo:@{NSLocalizedDescriptionKey: @"pre-request failed"}];
}

@end
