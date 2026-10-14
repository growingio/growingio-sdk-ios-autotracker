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

    // clang-format off
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
                getDomTree: getDomTreeTemp,
                getNativeIdentity: getNativeIdentity,
                _onNativeCallback: _onNativeCallback,
                _updateRoutingContext: updateRoutingContext,
                confirmRoutingContext: confirmRoutingContext,
                getRoutingContext: getRoutingContext
            };

            var _callbacks = {};
            var _callbackSeed = 0;
            var _CALLBACK_TIMEOUT = 500;

            function getDomTreeTemp() {
                console.log("%c [GrowingIO]：圈选获取节点信息失败！请集成 gioHybridCircle 插件后重试！",
                            "color: #F59E0B;");
            }

            var _routingContext = window.GrowingWebViewJavascriptBridge.configuration.routingContext;
            var _pendingRoutingContext = null;

            function getRoutingContext() {
                return _routingContext ? JSON.parse(JSON.stringify(_routingContext)) : null;
            }

            function updateRoutingContext(context) {
                if (_routingContext && (context.sequence < _routingContext.sequence ||
                    (context.sequence === _routingContext.sequence && context.sessionId === _routingContext.sessionId))) return;
                if (_pendingRoutingContext && context.sequence < _pendingRoutingContext.sequence) return;
                _pendingRoutingContext = context;
                /* The Web SDK applies its session/source and emits the PAGE, then confirms. */
                var event = document.createEvent("CustomEvent");
                event.initCustomEvent("GrowingIORoutingChange", false, false, context);
                window.dispatchEvent(event);
            }

            function confirmRoutingContext(context) {
                if (!_pendingRoutingContext || context.sequence !== _pendingRoutingContext.sequence ||
                    context.sessionId !== _pendingRoutingContext.sessionId) return false;
                _routingContext = _pendingRoutingContext;
                _pendingRoutingContext = null;
                window.GrowingWebViewJavascriptBridge.configuration.dataSourceId = context.dataSourceId;
                _doSend("routingContextApplied", _routingContext);
                return true;
            }

            function dispatchEvent(event) {
                var data = typeof event === "string" ? JSON.parse(event) : event;
                /* Updated Web SDKs bind routingContext when producing an event, before buffering. */
                if (data && !data.routingContext && _routingContext) {
                    data.routingContext = getRoutingContext();
                    data.routingContextFromBridge = true;
                }
                _doSend("dispatchEvent", JSON.stringify(data));
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

            /* 注意: 该段 JS 经 C 预处理器 # 字符串化后会被压成单行,
               只能使用块注释, 出现行注释会导致其后所有代码失效;
               另外 iOS 10.0 ~ 10.2 不支持 async/await, 这里只用 Promise */
            function getNativeIdentity() {
                return new Promise(function(resolve) {
                    var callbackId = "gio_" + (++_callbackSeed) + "_" + Date.now();

                    var timer = setTimeout(function() {
                        delete _callbacks[callbackId];
                        /* 超时, 交由 Web 侧回落至使用自身身份 */
                        resolve(null);
                    }, _CALLBACK_TIMEOUT);

                    _callbacks[callbackId] = function(identity) {
                        clearTimeout(timer);
                        resolve(identity);
                    };

                    _doSend("getNativeIdentity", JSON.stringify({callbackId: callbackId}));
                });
            }

            /* 由原生通过 evaluateJavaScript 调用 */
            function _onNativeCallback(callbackId, identity) {
                var callback = _callbacks[callbackId];
                if (!callback) {
                    /* 超时之后才到达, 丢弃 */
                    return;
                }
                delete _callbacks[callbackId];
                callback(identity);
            }

            function _doSend(messageType, data) {
                var messageString = JSON.stringify({messageType: messageType, data: data});
                window.webkit.messageHandlers.GrowingWKWebViewJavascriptBridge.postMessage(messageString);
            }
        })(););  // END preprocessorJSCode

#undef __WKWebViewJavascriptBridge_js_func__
    // clang-format on
    return kGrowingPreprocessorJSCode;
};

+ (NSString *)createJavascriptBridgeJsWithNativeConfiguration:
    (GrowingWebViewJavascriptBridgeConfiguration *)configuration {
    NSString *bridge = kWKWebViewJavascriptBridge_js();
    return [bridge stringByReplacingOccurrencesOfString:@"$configuration_replacement"
                                             withString:[configuration toJsonString]];
}

static NSString *kWKWebViewJavascriptSdkInject_js(void) {
#define __WKWebViewJavascriptSdkInject_js_func__(x) #x

    // BEGIN preprocessorJSCode
    static NSString *kGrowingPreprocessorJSCode = @__WKWebViewJavascriptSdkInject_js_func__(
        try{
            !(function (e, n, t, s, c) {
                e[s] =
                e[s] ||
                function () {
                    (e[s].q = e[s].q || []).push(arguments);
                };
                (e._gio_local_vds = c = c || 'vds'),
                (e[c] = e[c] || {}),
                (e[c].namespace = s);
                var d = n.createElement('script');
                var i = n.getElementsByTagName('script')[0];
                (d.async = !0), (d.src = t);
                i ? i.parentNode.insertBefore(d, i) : n.head.appendChild(d);
            })(window, document, 'https://assets.giocdn.com/sdk/webjs/gdp-full.js', 'gdp');

            window._gr_ignore_local_rule = true;
            gdp('init', '$accountId_replacement', '$dataSourceId_replacement');
        } catch(e){});
#undef __WKWebViewJavascriptSdkInject_js_func__
    return kGrowingPreprocessorJSCode;
};

+ (NSString *)createJavascriptSdkInjectJsWithNativeConfiguration:
    (GrowingWebViewJavascriptBridgeConfiguration *)configuration {
    NSString *bridge = kWKWebViewJavascriptSdkInject_js();
    bridge = [bridge stringByReplacingOccurrencesOfString:@"$accountId_replacement" withString:configuration.accountId];
    bridge = [bridge stringByReplacingOccurrencesOfString:@"$dataSourceId_replacement"
                                               withString:configuration.dataSourceId];
    return bridge;
}

@end
