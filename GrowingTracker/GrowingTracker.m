//
//  GrowingTracker.m
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/11/6.
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

#import "GrowingTracker/GrowingTracker.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogMacros.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

static GrowingTracker *sharedInstance = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation GrowingTracker
- (instancetype)initWithRealTracker:(GrowingRealTracker *)realTracker {
    self = [super initWithTarget:realTracker];
    return self;
}

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }

    if (!configuration.projectId.length) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"ProjectId不能为空" userInfo:nil];
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GrowingRealTracker *realTracker = [GrowingRealTracker trackerWithConfiguration:configuration launchOptions:launchOptions];
        sharedInstance = [[self alloc] initWithRealTracker:realTracker];
        [[GrowingSession currentSession] generateVisit];
    });
}

+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        @throw [NSException exceptionWithName:@"GrowingTracker未初始化" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }
    return sharedInstance;
}

@end

#pragma clang diagnostic pop
