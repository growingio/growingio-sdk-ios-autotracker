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

@interface GrowingHybridModule : NSObject <GrowingModuleProtocol>

// 是否自动注入Hybrid SDK
@property (nonatomic, assign) BOOL autoBridgeEnabled;

// 对单个webView启用Hybrid注入，请在主线程调用
- (void)enableBridgeForWebView:(WKWebView *)webView;

// 对单个webView关闭Hybrid注入，请在主线程调用
- (void)disableBridgeForWebView:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
