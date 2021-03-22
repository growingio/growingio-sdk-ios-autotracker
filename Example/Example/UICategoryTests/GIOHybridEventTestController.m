//
// GIOHybridEventTestController.m
// Example
//
//  Created by gio on 2021/3/22.
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


#import "GIOHybridEventTestController.h"
@import WebKit;

@interface GIOHybridEventTestController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *webContainer;

@end

@implementation GIOHybridEventTestController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self configureWebView];
    [self loadAddressURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadAddressURL {
    
    NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"gio_hybrideventtest" ofType:@"html"];
        
    NSURL *requestURL = [NSURL fileURLWithPath:bundleStr];
        
    [self.webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
}

- (IBAction)refreshPage:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (IBAction)goBack:(UIBarButtonItem *)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Configuration

- (void)configureWebView {
    [self.webContainer addSubview:self.webView];
}

- (void)viewDidLayoutSubviews {
    self.webView.frame = self.webContainer.bounds;
}

#pragma mark - UIWebViewDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
    [HybirdEventSender sharedInstance].webView = self.webView;
}

- (void)dealloc {
    NSLog(@"self = %@ dealloc", NSStringFromClass(self.class));
}

#pragma mark Lazy Load

- (WKWebView *)webView {
    if (!_webView) {
        [self.view setNeedsLayout];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
    }
    return _webView;
}

@end


@implementation HybirdEventSender

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}


- (void)testHybirdEventSender:(NSString *)jsStr{
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"error: %@  result: %@",error,result);
    }];
}

@end


