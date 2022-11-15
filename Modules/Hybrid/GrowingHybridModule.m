//
// GrowingHybridModule.m
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

#import "Modules/Hybrid/GrowingHybridModule.h"
#import "Modules/Hybrid/WKWebView+GrowingAutotracker.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingULSwizzle.h"

GrowingMod(GrowingHybridModule)

@implementation GrowingHybridModule

- (void)growingModInit:(GrowingContext *)context {
    [self track];
}

- (void)track {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // WKWebView
        NSError *webViewError = NULL;
        [WKWebView growingul_swizzleMethod:@selector(loadRequest:)
                                withMethod:@selector(growing_loadRequest:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadRequest:. Details: %@", webViewError);
            webViewError = NULL;
        }
        
        [WKWebView growingul_swizzleMethod:@selector(loadHTMLString:baseURL:)
                                withMethod:@selector(growing_loadHTMLString:baseURL:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadHTMLString:baseURL:. Details: %@", webViewError);
            webViewError = NULL;
        }
        
        [WKWebView growingul_swizzleMethod:@selector(loadFileURL:allowingReadAccessToURL:)
                                withMethod:@selector(growing_loadFileURL:allowingReadAccessToURL:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadFileURL:allowingReadAccessToURL:. Details: %@", webViewError);
            webViewError = NULL;
        }
        
        [WKWebView growingul_swizzleMethod:@selector(loadData:MIMEType:characterEncodingName:baseURL:)
                                withMethod:@selector(growing_loadData:MIMEType:characterEncodingName:baseURL:)
                                     error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView loadData:MIMEType:characterEncodingName:baseURL:. Details: %@", webViewError);
            webViewError = NULL;
        }
    });
}

@end
