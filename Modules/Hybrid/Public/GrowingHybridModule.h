//
// GrowingHybridModule.h
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

#import <Foundation/Foundation.h>
#import "GrowingModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class WKWebView;

NS_EXTENSION_UNAVAILABLE("Hybrid is not supported for iOS extensions.")
NS_SWIFT_NAME(Hybrid)
@interface GrowingHybridModule : NSObject <GrowingModuleProtocol>

+ (instancetype)sharedInstance;

// 以下配置的生效时机在webView的下一个load

// 是否对所有webView自动注入Hybrid SDK，默认为YES
@property (nonatomic, assign) BOOL autoBridgeEnabled;

// 在autoBridgeEnabled为NO时，对单个webView启用Hybrid注入，请在主线程调用
- (void)enableBridgeForWebView:(WKWebView *)webView NS_SWIFT_NAME(enableBridge(_:));

// 在autoBridgeEnabled为YES时，对单个webView关闭Hybrid注入，请在主线程调用
- (void)disableBridgeForWebView:(WKWebView *)webView NS_SWIFT_NAME(disableBridge(_:));

// 判断当前配置下，webView是否可注入
- (BOOL)isBridgeForWebViewEnabled:(WKWebView *)webView NS_SWIFT_NAME(isBridgeEnabled(_:));

// 重置Hybrid注入配置，请在主线程调用
- (void)resetBridgeSettings;

@end

NS_ASSUME_NONNULL_END
