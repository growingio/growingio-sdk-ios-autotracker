//
//  GrowingAutotrackPageViewController.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/7/10.
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

#import "GrowingAutotrackPageViewController.h"

@interface GrowingAutotrackPageViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation GrowingAutotrackPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.button = button;
    
    [NSLayoutConstraint activateConstraints:@[
        [button.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [button.widthAnchor constraintEqualToConstant:60.0f],
        [button.heightAnchor constraintEqualToConstant:35.0f]
    ]];
    
    if (self.type == GrowingDemoAutotrackPageTypeDefault
        || self.type == GrowingDemoAutotrackPageTypeNotViewDidAppear) {
        [self autotrackPage];
    } else if (self.type == GrowingDemoAutotrackPageTypeDelay
               || self.type == GrowingDemoAutotrackPageTypeDelayNotViewDidAppear) {
        // 模拟网络请求，此时autotrackPage的调用在viewDidAppear之后
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self autotrackPage];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.type == GrowingDemoAutotrackPageTypeNotViewDidAppear
        || self.type == GrowingDemoAutotrackPageTypeDelayNotViewDidAppear) {
        return;
    }
    [super viewDidAppear:animated];
}

- (void)buttonAction {
    
}

- (void)autotrackPage {
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
    [[GrowingAutotracker sharedInstance] autotrackPage:self alias:@"页面测试" attributes:@{@"key" : @"value"}];
#endif
#endif
}

@end
