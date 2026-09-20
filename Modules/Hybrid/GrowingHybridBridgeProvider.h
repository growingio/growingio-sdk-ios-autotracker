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
@class WKFrameInfo;

@interface GrowingHybridBridgeProvider : NSObject

@property (nullable, nonatomic, weak) id<GrowingWebViewDomChangedDelegate> domChangedDelegate;

/// 获取 H5 DOM 树的超时时间，默认 10s
/// @discussion 仅用于兜底：WebContent 进程崩溃或挂起、页面未注入 bridge、JS 卡死时回调不会到达，
/// 无超时会导致主线程被永久占住。正常圈选路径远低于该值，不应按性能预算来调小
@property (nonatomic, assign) CGFloat getDomTreeTimeOut;

+ (instancetype _Nonnull)sharedInstance;

- (void)handleJavascriptBridgeMessage:(NSString *_Nullable)message;

- (void)handleJavascriptBridgeMessage:(NSString *_Nullable)message
                          fromWebView:(WKWebView *_Nullable)webView
                            frameInfo:(WKFrameInfo *_Nullable)frameInfo;

- (void)getDomTreeForWebView:(WKWebView *_Nonnull)webView
           completionHandler:
               (void (^_Nonnull)(NSDictionary *_Nullable domTee, NSError *_Nullable error))completionHandler;
@end
