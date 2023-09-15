//
// GrowingWKWebViewJavascriptBridge.m
// GrowingAnalytics
//
//  Created by GrowingIO on 2020/5/27.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Hybrid/GrowingWKWebViewJavascriptBridge.h"
#import <WebKit/WebKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "GrowingTrackerCore/Event/GrowingNodeProtocol.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogMacros.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingTrackerCore/include/GrowingTrackConfiguration.h"
#import "Modules/Hybrid/GrowingHybridBridgeProvider.h"
#import "Modules/Hybrid/GrowingWKWebViewJavascriptBridge_JS.h"
#import "Modules/Hybrid/GrowingWebViewJavascriptBridgeConfiguration.h"
#import "Modules/Hybrid/Public/GrowingHybridModule.h"

static NSString *const kGrowingWKWebViewJavascriptBridge = @"GrowingWKWebViewJavascriptBridge";

@interface GrowingWKWebViewJavascriptBridge () <WKScriptMessageHandler>

@end

@implementation GrowingWKWebViewJavascriptBridge

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (BOOL)webViewDontTrackCheck:(WKWebView *)webView {
    SEL selector = NSSelectorFromString(@"growingViewDontTrack");
    if ([webView respondsToSelector:selector]) {
        return ((BOOL(*)(id, SEL))objc_msgSend)(webView, selector);
    }
    return NO;
}

+ (void)bridgeForWebView:(WKWebView *)webView {
    if ([self webViewDontTrackCheck:webView]) {
        GIOLogDebug(@"WKWebview Bridge %@ is donotTrack", webView);
        return;
    }

    if (![GrowingHybridModule.sharedInstance isBridgeForWebViewEnabled:webView]) {
        GIOLogDebug(@"WKWebview Bridge %@ is disabled", webView);
        return;
    }

    WKUserContentController *contentController = webView.configuration.userContentController;
    [self addScriptMessageHandler:contentController];
    [self addUserScripts:contentController];
}

+ (void)addScriptMessageHandler:(WKUserContentController *)contentController {
    GrowingWKWebViewJavascriptBridge *bridge = [GrowingWKWebViewJavascriptBridge sharedInstance];
    [contentController removeScriptMessageHandlerForName:kGrowingWKWebViewJavascriptBridge];
    [contentController addScriptMessageHandler:bridge name:kGrowingWKWebViewJavascriptBridge];
}

+ (void)addUserScripts:(WKUserContentController *)contentController {
    @try {
        NSArray<WKUserScript *> *userScripts = contentController.userScripts;
        __block BOOL isContainUserScripts = NO;
        [userScripts enumerateObjectsUsingBlock:^(WKUserScript *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj.source containsString:NSStringFromClass(self.class)]) {
                isContainUserScripts = YES;
                *stop = YES;
            }
        }];

        if (!isContainUserScripts) {
            NSString *projectId = GrowingConfigurationManager.sharedInstance.trackConfiguration.projectId;
            NSString *bundleId = [GrowingDeviceInfo currentDeviceInfo].bundleID;
            NSString *urlScheme = [GrowingDeviceInfo currentDeviceInfo].urlScheme;
            GrowingWebViewJavascriptBridgeConfiguration *config =
                [GrowingWebViewJavascriptBridgeConfiguration configurationWithProjectId:projectId
                                                                                  appId:urlScheme
                                                                             appPackage:bundleId
                                                                       nativeSdkVersion:GrowingTrackerVersionName
                                                                   nativeSdkVersionCode:GrowingTrackerVersionCode];

            WKUserScript *userScript =
                [[WKUserScript alloc] initWithSource:[GrowingWKWebViewJavascriptBridge_JS
                                                         createJavascriptBridgeJsWithNativeConfiguration:config]
                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                    forMainFrameOnly:NO];
            [contentController addUserScript:userScript];
        }
    } @catch (NSException *exception) {
    }
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([GrowingWKWebViewJavascriptBridge webViewDontTrackCheck:message.webView]) {
        GIOLogDebug(@"WKWebview Bridge %@ is donotTrack", message.webView);
        return;
    }

    if ([message.name isEqualToString:kGrowingWKWebViewJavascriptBridge]) {
        [GrowingHybridBridgeProvider.sharedInstance handleJavascriptBridgeMessage:message.body];
    }
}

@end
