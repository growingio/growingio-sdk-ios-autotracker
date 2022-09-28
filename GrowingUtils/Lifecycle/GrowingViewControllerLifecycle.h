//
//  GrowingViewControllerLifecycle.h
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/23.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol GrowingViewControllerLifecycleDelegate <NSObject>

@optional
- (void)viewControllerLoadView:(UIViewController *)controller;

- (void)viewControllerDidLoad:(UIViewController *)controller;

- (void)viewControllerWillAppear:(UIViewController *)controller;

- (void)viewControllerDidAppear:(UIViewController *)controller;

- (void)viewControllerWillDisappear:(UIViewController *)controller;

- (void)viewControllerDidDisappear:(UIViewController *)controller;

- (void)pageLoadCompletedWithViewController:(UIViewController *)viewController
                               loadViewTime:(double)loadViewTime
                            viewDidLoadTime:(double)viewDidLoadTime
                         viewWillAppearTime:(double)viewWillAppearTime
                          viewDidAppearTime:(double)viewDidAppearTime;

@end

@interface UIViewController (GrowingUtils)

@property (nonatomic, assign) BOOL growing_DidAppear;

@end

@interface GrowingViewControllerLifecycle : NSObject

+ (instancetype)sharedInstance;

+ (void)setup;

- (void)addViewControllerLifecycleDelegate:(id <GrowingViewControllerLifecycleDelegate>)delegate;

- (void)removeViewControllerLifecycleDelegate:(id <GrowingViewControllerLifecycleDelegate>)delegate;

@end
