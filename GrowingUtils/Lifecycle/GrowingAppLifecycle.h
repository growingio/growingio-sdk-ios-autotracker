//
//  GrowingAppLifecycle.h
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol GrowingAppLifecycleDelegate <NSObject>

@optional
- (void)applicationDidFinishLaunching:(NSDictionary *)userInfo;

- (void)applicationWillTerminate;

- (void)applicationDidBecomeActive;

- (void)applicationWillResignActive;

- (void)applicationDidEnterBackground;

- (void)applicationWillEnterForeground;

@end

@interface GrowingAppLifecycle : NSObject

@property (nonatomic, assign) double appDidFinishLaunchingTime;
@property (nonatomic, assign) double appWillEnterForegroundTime;
@property (nonatomic, assign) double appDidBecomeActiveTime;
@property (nonatomic, assign) double appDidEnterBackgroundTime;
@property (nonatomic, assign) double appWillResignActiveTime;

+ (instancetype)sharedInstance;

+ (void)setup;

- (void)addAppLifecycleDelegate:(id <GrowingAppLifecycleDelegate>)delegate;

- (void)removeAppLifecycleDelegate:(id <GrowingAppLifecycleDelegate>)delegate;

@end
