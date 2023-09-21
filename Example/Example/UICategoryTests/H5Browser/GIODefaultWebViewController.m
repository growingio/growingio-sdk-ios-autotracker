//
//  GIODefaultWebViewController.m
//  GrowingIOTest
//
//  Created by YoloMao on 2021/7/22.
//  Copyright © 2021 GrowingIO. All rights reserved.
//

#import "GIODefaultWebViewController.h"
#import "GIOWebViewWarmuper.h"
#import <WebKit/WebKit.h>

@interface GIODefaultWebViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation GIODefaultWebViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.h5Url]]];

    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([@"estimatedProgress" isEqualToString:keyPath]) {
        self.progressView.alpha = 1.0;
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        
        if (self.webView.estimatedProgress >= 1.0) {
            [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.progressView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0 animated:NO];
            }];
        }
    }
}

#pragma mark - Setter & Getter

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[GIOWebViewWarmuper sharedInstance] dequeue];
        _webView.frame = self.view.bounds;
#if defined(__IPHONE_16_4) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_16_4)
        if (@available(macOS 13.3, iOS 16.4, tvOS 16.4, *)) {
            _webView.inspectable = YES;
        }
#endif
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        CGFloat top = 44;
        if (@available(iOS 11.0, *)) {
            top = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44;
        }
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, top, self.view.bounds.size.width, 1.0)];
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor whiteColor];
    }
    return _progressView;
}

@end
