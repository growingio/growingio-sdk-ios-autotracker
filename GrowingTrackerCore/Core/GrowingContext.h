//
// GrowingContext.h
// GrowingAnalytics
//
//  Created by sheng on 2021/6/17.
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

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#elif __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface GrowingOpenURLItem : NSObject

@property (nonatomic, strong) NSURL *openURL;
@property (nonatomic, copy) NSString *sourceApplication;
@property (nonatomic, strong) id annotation;
@property (nonatomic, strong) NSDictionary *options;

@end

@interface GrowingContext : NSObject

#if __has_include(<UIKit/UIKit.h>)
@property (nonatomic, strong) UIApplication *application;
#elif __has_include(<AppKit/AppKit.h>)
@property (nonatomic, strong) NSApplication *application;
#endif

@property (nonatomic, strong) NSDictionary *launchOptions;
// customEvent>=1000
@property (nonatomic, assign) NSInteger customEvent;
// custom param
@property (nonatomic, copy) NSDictionary *customParam;

// OpenURL model
@property (nonatomic, strong) GrowingOpenURLItem *openURLItem;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
