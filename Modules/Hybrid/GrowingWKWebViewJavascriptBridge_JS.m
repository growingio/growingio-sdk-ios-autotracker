//
// GrowingWKWebViewJavascriptBridge_JS.m
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

#import "Modules/Hybrid/GrowingWKWebViewJavascriptBridge_JS.h"
#import "Modules/Hybrid/GrowingWebViewJavascriptBridgeConfiguration.h"

@implementation GrowingWKWebViewJavascriptBridge_JS

static NSString *kWKWebViewJavascriptBridge_js(void) {
#define __WKWebViewJavascriptBridge_js_func__(x) #x

    // BEGIN preprocessorJSCode
    static NSString *kGrowingPreprocessorJSCode = @__WKWebViewJavascriptBridge_js_func__(
        (function() {
            if (window.GrowingWebViewJavascriptBridge) {
                return;
            }

            window.GrowingWebViewJavascriptBridge = {
                configuration: $configuration_replacement,
                dispatchEvent: dispatchEvent,
                setNativeUserId: setNativeUserId,
                clearNativeUserId: clearNativeUserId,
                setNativeUserIdAndUserKey: setNativeUserIdAndUserKey,
                clearNativeUserIdAndUserKey: clearNativeUserIdAndUserKey,
                onDomChanged: onDomChanged,
                getDomTree: getDomTreeTemp
            };

            function getDomTreeTemp() {
                console.log("%c [GrowingIO]：圈选获取节点信息失败！请集成 gioHybridCircle 插件后重试！",
                            "color: #F59E0B;");
            }

            function dispatchEvent(event) {
                _doSend("dispatchEvent", event);
            }

            function setNativeUserId(userId) {
                _doSend("setNativeUserId", userId);
            }

            function clearNativeUserId() {
                _doSend("clearNativeUserId", null);
            }

            function setNativeUserIdAndUserKey(userId, userKey) {
                let data = {"userId": userId, "userKey": userKey};
                _doSend("setNativeUserIdAndUserKey", JSON.stringify(data));
            }

            function clearNativeUserIdAndUserKey() {
                _doSend("clearNativeUserIdAndUserKey", null);
            }

            function onDomChanged() {
                _doSend("onDomChanged", null);
            }

            function _doSend(messageType, data) {
                var messageString = JSON.stringify({messageType: messageType, data: data});
                window.webkit.messageHandlers.GrowingWKWebViewJavascriptBridge.postMessage(messageString);
            }
        })(););  // END preprocessorJSCode

#undef __WKWebViewJavascriptBridge_js_func__
    return kGrowingPreprocessorJSCode;
};

+ (NSString *)createJavascriptBridgeJsWithNativeConfiguration:
    (GrowingWebViewJavascriptBridgeConfiguration *)configuration {
    NSString *bridge = kWKWebViewJavascriptBridge_js();
    return [bridge stringByReplacingOccurrencesOfString:@"$configuration_replacement"
                                             withString:[configuration toJsonString]];
}

@end
