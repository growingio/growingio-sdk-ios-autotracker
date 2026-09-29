//
//  GIOHybridViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 16/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOHybridViewController.h"
#import "GIOWebViewWarmuper.h"
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
#if defined(SDKABTESTINGMODULE)
    [self setupABTestingBarButton];
#endif
}

#if defined(SDKABTESTINGMODULE)

#pragma mark - ABTesting

- (void)setupABTestingBarButton {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"原生AB"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(fetchNativeExperiment:)];
    NSMutableArray *items = self.navigationItem.rightBarButtonItems.mutableCopy ?: [NSMutableArray array];
    [items addObject:item];
    self.navigationItem.rightBarButtonItems = items;
}

/// 用 H5 页面上填的 layerId 发一次原生分流，便于对照同一实验位下两端各自的请求与缓存
- (void)fetchNativeExperiment:(id)sender {
    NSString *readLayerId = @"document.getElementById('abtLayerId') ? "
                            @"document.getElementById('abtLayerId').value : ''";
    [self.webView evaluateJavaScript:readLayerId
                   completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                       NSString *layerId = @"demo_layer";
                       if ([result isKindOfClass:NSString.class] && [(NSString *)result length] > 0) {
                           layerId = (NSString *)result;
                       }
                       [self fetchExperimentWithLayerId:layerId];
                   }];
}

- (void)fetchExperimentWithLayerId:(NSString *)layerId {
    [GrowingABTesting fetchExperiment:layerId
                       completedBlock:^(GrowingABTExperiment *_Nullable experiment) {
                           NSString *message;
                           if (!experiment) {
                               message = @"请求失败";
                           } else {
                               message = [NSString stringWithFormat:@"layerId: %@\nexperimentId: %@\nstrategyId: "
                                                                    @"%@\nvariables: %@",
                                                                    experiment.layerId,
                                                                    experiment.experimentId ?: @"(未命中)",
                                                                    experiment.strategyId ?: @"(未命中)",
                                                                    experiment.variables ?: @{}];
                           }
                           NSLog(@"[GIO-ABT] 原生 fetchExperiment: %@", message);
                           dispatch_async(dispatch_get_main_queue(), ^{
                               UIAlertController *alert =
                                   [UIAlertController alertControllerWithTitle:@"原生分流结果"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
                               [alert addAction:[UIAlertAction actionWithTitle:@"好"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:nil]];
                               [self presentViewController:alert animated:YES completion:nil];
                           });
                       }];
}

#endif

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
    //直接加载html文件 userkey打通测试
     NSString *path = [[NSBundle mainBundle] bundlePath];
     NSURL *baseURL = [NSURL fileURLWithPath:path];
     NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"gio_hybrideventtest"
                                                                  ofType:@"html"];
      NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                            encoding:NSUTF8StringEncoding
                                                               error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:baseURL];
//    NSURL *url = [NSURL URLWithString:@"http://release-messages.growingio.cn/push/cdp/webcircel.html"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
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
        _webView = [[GIOWebViewWarmuper sharedInstance] dequeue];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.accessibilityLabel = @"HybridWebView";
#if defined(__IPHONE_16_4) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_16_4)
        if (@available(macOS 13.3, iOS 16.4, tvOS 16.4, *)) {
            _webView.inspectable = YES;
        }
#endif
    }
    return _webView;
}

@end
