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

#import "GrowingWKWebViewJavascriptBridge_JS.h"
#import "GrowingWebViewJavascriptBridgeConfiguration.h"


@implementation GrowingWKWebViewJavascriptBridge_JS

NSString *WKWebViewJavascriptBridge_js(void) {
#define __WKWebViewJavascriptBridge_js_func__(x) #x

    // BEGIN preprocessorJSCode
    static NSString *kGrowingPreprocessorJSCode = @__WKWebViewJavascriptBridge_js_func__((function() {
        if (window.GrowingWebViewJavascriptBridge) {
            return;
        }

        window.GrowingWebViewJavascriptBridge = {
                configuration: %@,
                dispatchEvent: dispatchEvent,
                setNativeUserId: setNativeUserId,
                clearNativeUserId: clearNativeUserId,
                onDomChanged: onDomChanged
        };

        function dispatchEvent(event) {
            _doSend("dispatchEvent", event);
        }

        function setNativeUserId(userId) {
            _doSend("setNativeUserId", userId);
        }

        function clearNativeUserId() {
            _doSend("clearNativeUserId", null);
        }

        function onDomChanged() {
            _doSend("onDomChanged", null);
        }

        function _doSend(messageType, data) {
            console.log("Growing hybrid send message: messageType = " + messageType + ", data = " + data);
            var messageString = JSON.stringify({messageType:messageType, data:data});
            window.webkit.messageHandlers.GrowingWKWebViewJavascriptBridge.postMessage(messageString);
        }

    })();
    ); // END preprocessorJSCode

#undef __WKWebViewJavascriptBridge_js_func__
    return kGrowingPreprocessorJSCode;
};

+ (NSString *)createJavascriptBridgeJsWithNativeConfiguration:(GrowingWebViewJavascriptBridgeConfiguration *)configuration {
    return [NSString stringWithFormat:WKWebViewJavascriptBridge_js(), [configuration toJsonString]];
}

@end
