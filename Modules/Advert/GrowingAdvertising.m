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
#import "Modules/Advert/AppleSearchAds/GrowingAsaFetcher.h"

#import "GrowingTrackerCore/Core/GrowingContext.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Network/Request/GrowingNetworkConfig.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

#import <WebKit/WebKit.h>

GrowingMod(GrowingAdvertising)

@interface GrowingAdvertising () <GrowingEventInterceptor>

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
    [self generateActivate];
}

- (void)growingModSetDataCollectionEnabled:(GrowingContext *)context {
    NSDictionary *customParam = context.customParam;
    BOOL dataCollectionEnabled = ((NSNumber *)customParam[@"dataCollectionEnabled"]).boolValue;
    if (dataCollectionEnabled) {
        [self generateActivate];
    }
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

#pragma mark - Private Method

- (BOOL)SDKDoNotTrack {
    if (![GrowingConfigurationManager sharedInstance].trackConfiguration.dataCollectionEnabled) {
        GIOLogDebug(@"[GrowingAdvertising] dataCollectionEnabled is false");
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

- (void)generateActivate {
    if ([GrowingConfigurationManager sharedInstance].trackConfiguration.ASAEnabled) {
        [GrowingAsaFetcher startFetchWithTimeOut:GrowingAsaFetcherDefaultTimeOut];
    }
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if ([self SDKDoNotTrack]) {
            return;
        }
        if ([GrowingAdUtils isActivateWrote]) {
            // activate 在同一安装周期内仅需发送一次
            return;
        }

        [self sendActivateEvent];
    }];
}

#pragma mark - Event handler

- (void)sendActivateEvent {
    [self accessUserAgent:^(NSString *userAgent) {
        if ([self SDKDoNotTrack]) {
            return;
        }
        if ([GrowingAdUtils isActivateWrote]) {
            // activate 在同一安装周期内仅需发送一次
            return;
        }

        GrowingActivateBuilder *builder = GrowingActivateEvent.builder;
        if (userAgent.length > 0) {
            builder.setAttributes(@{@"userAgent" : userAgent.copy});
        }
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        [GrowingAdUtils setActivateWrote:YES];
    }];
}

@end
