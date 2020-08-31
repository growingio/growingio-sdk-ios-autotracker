//
//  GIOHybridViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 16/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOHybridViewController.h"
//#import "GrowingWKWebViewJavascriptBridge.h"
@import WebKit;

@interface GIOHybridViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *webContainer;

@end

@implementation GIOHybridViewController

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
    // NSURL *requestURL = [NSURL URLWithString:@"https://dn-sharebaidu.qbox.me/gio_hybrid.html"];
    // NSURL *requestURL = [NSURL URLWithString:@"http://192.168.52.51/gio_hybrid.html"];
    //    NSURL *requestURL = [NSURL URLWithString:@"http://192.168.52.116/Hybrid_PatternServer.html"];
    //
    //    //NSURL *requestURL = [NSURL URLWithString:@"http://192.168.52.54/zeptotest1.html"];
    //
    //     NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    //     [self.webView loadRequest:request];

    //直接加载html文件
    // NSString *path = [[NSBundle mainBundle] bundlePath];
    // NSURL *baseURL = [NSURL fileURLWithPath:path];
    // NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"gio_hybrid"
    //                                                              ofType:@"html"];
    //  NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
    //                                                        encoding:NSUTF8StringEncoding
    //                                                           error:nil];
    //  [self.webView loadHTMLString:htmlCont baseURL:baseURL];
    //
    //    NSURL *requestURL = [NSURL URLWithString:@"http://m.baidu.com/"];
    //    NSURL *requestURL = [NSURL URLWithString:@"https://m.baidu.com/"];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    //    [self.webView loadRequest:request];

    //    NSURL *requestURL = [NSURL URLWithString:@"https://dn-sharebaidu.qbox.me/gio_hybrid.html"];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    //    [self.webView loadRequest:request];

    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
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
