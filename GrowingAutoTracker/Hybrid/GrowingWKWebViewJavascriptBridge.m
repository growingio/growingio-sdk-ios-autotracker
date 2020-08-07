//  Created by GrowingIO on 2020/5/27.
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

#import <WebKit/WebKit.h>
#import "GrowingWKWebViewJavascriptBridge.h"
#import "GrowingWKWebViewJavascriptBridge_JS.h"
#import "GrowingWebViewJavascriptBridgeConfiguration.h"
#import "GrowingHybridBridgeProvider.h"
#import "GrowingInstance.h"
#import "GrowingDeviceInfo.h"

static NSString *const kGrowingWKWebViewJavascriptBridge = @"GrowingWKWebViewJavascriptBridge";

@interface GrowingWKWebViewJavascriptBridge () <WKScriptMessageHandler>
@end

@implementation GrowingWKWebViewJavascriptBridge
+ (void)bridgeForWebView:(WKWebView *)webView {
    GrowingWKWebViewJavascriptBridge *bridge = [[self alloc] init];
    [webView.configuration.userContentController removeScriptMessageHandlerForName:kGrowingWKWebViewJavascriptBridge];
    [webView.configuration.userContentController addScriptMessageHandler:bridge name:kGrowingWKWebViewJavascriptBridge];
    // TODO: nativeSdkVersionCode
    NSString *projectId = [GrowingInstance sharedInstance].projectID ?: @"";
    NSString *bundleId = [GrowingDeviceInfo currentDeviceInfo].bundleID;

    GrowingWebViewJavascriptBridgeConfiguration *config = [GrowingWebViewJavascriptBridgeConfiguration configurationWithProjectId:projectId appId:bundleId nativeSdkVersionCode:12];

    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[GrowingWKWebViewJavascriptBridge_JS createJavascriptBridgeJsWithNativeConfiguration:config]
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                   forMainFrameOnly:NO];

    [webView.configuration.userContentController addUserScript:userScript];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kGrowingWKWebViewJavascriptBridge]) {
        [GrowingHybridBridgeProvider.sharedInstance handleJavascriptBridgeMessage:message.body];
    }
}


@end
