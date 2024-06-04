//
//  GrowingAutotracker.m
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

#import "GrowingAutotracker/GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingTrackerCore/Event/GrowingGeneralProps.h"
#import "GrowingTrackerCore/Event/GrowingPropertyPluginManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"

static GrowingAutotracker *sharedInstance = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation GrowingAutotracker
- (instancetype)initWithRealAutotracker:(GrowingRealAutotracker *)realAutotracker {
    self = [super initWithTarget:realAutotracker];
    return self;
}

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    if (![NSThread isMainThread]) {
        @throw [NSException
            exceptionWithName:@"初始化异常"
                       reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中"
                     userInfo:nil];
    }

    if (!configuration.accountId.length) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"accountId不能为空" userInfo:nil];
    }

    if (!configuration.dataSourceId.length) {
        @throw [NSException exceptionWithName:@"初始化异常" reason:@"dataSourceId不能为空" userInfo:nil];
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GrowingRealAutotracker *autotracker = [GrowingRealAutotracker trackerWithConfiguration:configuration
                                                                                 launchOptions:launchOptions];
        sharedInstance = [[self alloc] initWithRealAutotracker:autotracker];
        [[GrowingSession currentSession] generateVisit];
    });
}

+ (BOOL)isInitializedSuccessfully {
    return sharedInstance != nil;
}

+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        @throw [NSException
            exceptionWithName:@"GrowingAutotracker未初始化"
                       reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中"
                     userInfo:nil];
    }
    return sharedInstance;
}

+ (void)setGeneralProps:(NSDictionary<NSString *, id> *)props {
    [[GrowingGeneralProps sharedInstance] setGeneralProps:props];
}

+ (void)removeGeneralProps:(NSArray<NSString *> *)keys {
    [[GrowingGeneralProps sharedInstance] removeGeneralProps:keys];
}

+ (void)clearGeneralProps {
    [[GrowingGeneralProps sharedInstance] clearGeneralProps];
}

+ (void)setDynamicGeneralPropsGenerator:(NSDictionary<NSString *, id> * (^_Nullable)(void))generator {
    [[GrowingGeneralProps sharedInstance] setDynamicGeneralPropsGenerator:generator];
}

+ (void)setPropertyPlugins:(id <GrowingPropertyPlugin>)plugin {
    [[GrowingPropertyPluginManager sharedInstance] setPropertyPlugins:plugin];
}

@end

#pragma clang diagnostic pop
