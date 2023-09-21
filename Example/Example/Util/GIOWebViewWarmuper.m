//
//  GIOWebViewWarmuper.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/9/21.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "GIOWebViewWarmuper.h"

@interface GIOWebViewWarmuper ()

@property (nonatomic, strong) NSMutableArray<WKWebView *> *webViews;

@end

@implementation GIOWebViewWarmuper

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _webViews = [NSMutableArray array];
    }
    [self prepare];
    return self;
}

- (void)prepare {
    int numberOfWebViews = 2;
    [self enqueue:numberOfWebViews];
}

- (void)enqueue:(int)count {
    while (self.webViews.count < count) {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        [self.webViews addObject:webView];
        [webView loadHTMLString:@"" baseURL:nil];
    }
}

- (WKWebView *)dequeue {
    if (self.webViews.count > 0) {
        WKWebView *webView = self.webViews.lastObject;
        [self.webViews removeLastObject];
        return webView;
    }
    
    [self enqueue:1];
    return [self dequeue];
}

@end
