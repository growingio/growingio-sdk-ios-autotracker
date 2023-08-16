//
// GrowingHybridModule.m
// GrowingAnalytics
//
//  Created by sheng on 2021/6/22.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Hybrid/Public/GrowingHybridModule.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "GrowingULSwizzle.h"
#import "Modules/Hybrid/WKWebView+GrowingAutotracker.h"

GrowingMod(GrowingHybridModule)

@interface GrowingHybridModule ()

@property (nonatomic, strong) NSHashTable *enableBridgeWebViews;

@end

@implementation GrowingHybridModule {
    GROWING_LOCK_DECLARE(lock);
}

#pragma mark - Init

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _autoBridgeEnabled = YES;
        _enableBridgeWebViews = [NSHashTable weakObjectsHashTable];
        GROWING_LOCK_INIT(lock);
    }
    return self;
}

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {
    [self track];
}

#pragma mark - Public Methods

- (void)enableBridgeForWebView:(WKWebView *)webView {
    if (![NSThread isMainThread]) {
        GIOLogError(@"调用异常，请在主线程调用 %@", NSStringFromSelector(_cmd));
        GROWING_LOCK(lock);
    }

    [self.enableBridgeWebViews addObject:webView];

    if (![NSThread isMainThread]) {
        GROWING_UNLOCK(lock);
    }
}

- (void)disableBridgeForWebView:(WKWebView *)webView {
    if (![NSThread isMainThread]) {
        GIOLogError(@"调用异常，请在主线程调用 %@", NSStringFromSelector(_cmd));
        GROWING_LOCK(lock);
    }

    [self.enableBridgeWebViews removeObject:webView];

    if (![NSThread isMainThread]) {
        GROWING_UNLOCK(lock);
    }
}

+ (BOOL)isBridgeForWebViewEnabled:(WKWebView *)webView {
    GrowingHybridModule *module = GrowingHybridModule.sharedInstance;
    return (module.autoBridgeEnabled || [module.enableBridgeWebViews containsObject:webView]);
}

#pragma mark - Private Methods

- (void)track {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // WKWebView
        NSError *webViewError = NULL;
        [WKWebView growingul_swizzleMethod:@selector(loadRequest:)
                                withMethod:@selector(growing_loadRequest:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadRequest:. Details: %@", webViewError);
            webViewError = NULL;
        }

        [WKWebView growingul_swizzleMethod:@selector(loadHTMLString:baseURL:)
                                withMethod:@selector(growing_loadHTMLString:baseURL:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadHTMLString:baseURL:. Details: %@", webViewError);
            webViewError = NULL;
        }

        [WKWebView growingul_swizzleMethod:@selector(loadFileURL:allowingReadAccessToURL:)
                                withMethod:@selector(growing_loadFileURL:allowingReadAccessToURL:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadFileURL:allowingReadAccessToURL:. Details: %@", webViewError);
            webViewError = NULL;
        }

        [WKWebView growingul_swizzleMethod:@selector(loadData:MIMEType:characterEncodingName:baseURL:)
                                withMethod:@selector(growing_loadData:MIMEType:characterEncodingName:baseURL:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadData:MIMEType:characterEncodingName:baseURL:. Details: %@",
                        webViewError);
            webViewError = NULL;
        }
    });
}

@end
