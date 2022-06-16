//
// GrowingHybridBridgeProvider.h
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

#import <Foundation/Foundation.h>

@protocol GrowingWebViewDomChangedDelegate;
@class WKWebView;

@interface GrowingHybridBridgeProvider : NSObject

@property (nullable, nonatomic, weak) id <GrowingWebViewDomChangedDelegate> domChangedDelegate;

+ (instancetype _Nonnull)sharedInstance;

- (void)handleJavascriptBridgeMessage:(NSString *_Nullable)message;

- (void)getDomTreeForWebView:(WKWebView *_Nonnull)webView
           completionHandler:(void (^ _Nonnull)(NSDictionary *_Nullable domTee, NSError *_Nullable error))completionHandler;
@end
