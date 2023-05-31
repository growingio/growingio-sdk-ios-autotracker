//
//  WKWebView+GrowingAutoTrack.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/23.
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
#import "Modules/Hybrid/WKWebView+GrowingAutotracker.h"

@implementation WKWebView (GrowingAutotracker)

- (WKNavigation *)growing_loadRequest:(NSURLRequest *)request {
    [GrowingWKWebViewJavascriptBridge bridgeForWebView:self];
    return [self growing_loadRequest:request];
}

- (WKNavigation *)growing_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [GrowingWKWebViewJavascriptBridge bridgeForWebView:self];
    return [self growing_loadHTMLString:string baseURL:baseURL];
}

- (WKNavigation *)growing_loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    [GrowingWKWebViewJavascriptBridge bridgeForWebView:self];
    return [self growing_loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

- (WKNavigation *)growing_loadData:(NSData *)data
                          MIMEType:(NSString *)MIMEType
             characterEncodingName:(NSString *)characterEncodingName
                           baseURL:(NSURL *)baseURL {
    [GrowingWKWebViewJavascriptBridge bridgeForWebView:self];
    return [self growing_loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];
}

@end
