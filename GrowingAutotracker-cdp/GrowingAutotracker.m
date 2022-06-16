//
// GrowingAutotracker.m
// GrowingAnalytics-cdp
//
//  Created by sheng on 2020/11/24.
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

#import "GrowingAutotracker-cdp/GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore-cdp/GrowingResourceCustomEvent.h"
#import "GrowingTrackerCore-cdp/GrowingCdpEventInterceptor.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

static GrowingAutotracker *sharedInstance = nil;

@interface GrowingAutotracker ()

@property (nonatomic, strong) GrowingCdpEventInterceptor *interceptor;

@end

@implementation GrowingAutotracker

#pragma mark - Initialization

- (instancetype)initWithRealAutotracker:(GrowingRealAutotracker *)realAutotracker {
    self = [super initWithTarget:realAutotracker];
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
        GrowingRealAutotracker *autotracker = [GrowingRealAutotracker trackerWithConfiguration:configuration launchOptions:launchOptions];
        sharedInstance = [[self alloc] initWithRealAutotracker:autotracker];
        sharedInstance.interceptor = [[GrowingCdpEventInterceptor alloc] initWithSourceId:configuration.dataSourceId];
        [[GrowingSession currentSession] addUserIdChangedDelegate:sharedInstance.interceptor];
        [[GrowingEventManager sharedInstance] addInterceptor:sharedInstance.interceptor];
        [[GrowingSession currentSession] generateVisit];
    });
}

+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        @throw [NSException exceptionWithName:@"GrowingAutotracker未初始化" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }
    return sharedInstance;
}

#pragma mark - Track Event

- (void)trackCustomEvent:(NSString *)eventName itemKey:(NSString *)itemKey itemId:(NSString *)itemId {
    
    [self trackCustomEvent:eventName itemKey:itemKey itemId:itemId withAttributes:nil];
}

- (void)trackCustomEvent:(NSString *)eventName itemKey:(NSString *)itemKey itemId:(NSString *)itemId withAttributes:(NSDictionary <NSString *, NSString *> * _Nullable)attributes {
    if ([GrowingArgumentChecker isIllegalEventName:eventName]
        || [GrowingArgumentChecker isIllegalEventName:itemKey]
        || [GrowingArgumentChecker isIllegalEventName:itemId]) {
        return;
    }
    if (attributes/* nullable */) {
        if ([GrowingArgumentChecker isIllegalAttributes:attributes]) {
            return;
        }
    }
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingCdpResourceItem *item = [GrowingCdpResourceItem new];
        item.itemKey = itemKey;
        item.itemId = itemId;
        GrowingResourceCustomBuilder *builder = GrowingResourceCustomEvent.builder.setResourceItem(item).setAttributes(attributes).setEventName(eventName);
        [[GrowingEventManager sharedInstance] postEventBuidler:builder];
    }];
}

@end

#pragma clang diagnostic pop
