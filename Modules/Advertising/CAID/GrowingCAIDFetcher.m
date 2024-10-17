//
//  GrowingCAIDFetcher.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/10/17.
//  Copyright (C) 2024 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Advertising/CAID/GrowingCAIDFetcher.h"
#import "Modules/Advertising/Event/GrowingAdEventType.h"
#import "Modules/Advertising/Public/GrowingAdvertising.h"

#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

#import <objc/runtime.h>
#import <pthread.h>

typedef NS_ENUM(NSUInteger, GrowingCAIDFetcherStatus) {
    GrowingCAIDFetcherStatusDenied = 1,  // 未配置CAID获取接口
    GrowingCAIDFetcherStatusFailure,     // 获取CAID标识符失败(超时)
    GrowingCAIDFetcherStatusFetching,    // 正在获取CAID标识符
    GrowingCAIDFetcherStatusSuccess,     // 获取CAID标识符成功
};

static CGFloat const kGrowingCAIDFetcherDefaultTimeOut = 5.0f;
static pthread_rwlock_t _lock = PTHREAD_RWLOCK_INITIALIZER;

@interface GrowingCAIDFetcher () <GrowingEventInterceptor>

@property (class, nonatomic, assign) GrowingCAIDFetcherStatus status;
@property (class, nonatomic, nullable, copy) NSString *caid;

@end

@implementation GrowingCAIDFetcher

#pragma mark - Init

+ (instancetype)sharedInstance {
    static GrowingCAIDFetcher *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingCAIDFetcher alloc] init];
    });
    return instance;
}

#pragma mark - GrowingEventInterceptor

- (NSArray *)growingEventManagerEventsWillSend:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
                                       channel:(GrowingEventChannel *)channel {
    if (channel.eventTypes.count == 0 || [channel.eventTypes indexOfObject:GrowingEventTypeActivate] == NSNotFound) {
        return events;
    }

    NSMutableArray<id <GrowingEventPersistenceProtocol>> *activates = @[].mutableCopy;
    for (id<GrowingEventPersistenceProtocol> event in events) {
        if ([event.eventType isEqualToString:GrowingEventTypeActivate]) {
            [activates addObject:event];
        }
    }
    if (activates.count == 0) {
        return events;
    }

    if (GrowingCAIDFetcher.status == GrowingCAIDFetcherStatusFetching) {
        // CAID 还在获取中，activate 需延迟上传
        NSMutableArray *array = [NSMutableArray arrayWithArray:events];
        [array removeObjectsInArray:activates];
        return array;
    } else {
        if (GrowingCAIDFetcher.caid.length > 0) {
            NSString *caid = GrowingCAIDFetcher.caid.copy;
            for (id<GrowingEventPersistenceProtocol> event in activates) {
                [event appendExtraParams:@{@"CAID": caid}];
            }
        }
    }

    return events;
}

#pragma mark - Public Method

+ (void)startFetch {
    if (self.status == GrowingCAIDFetcherStatusFetching) {
        return;
    }

    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!trackConfiguration.dataCollectionEnabled) {
        GIOLogDebug(@"[GrowingAdvertising] CAIDFetcher - dataCollectionEnabled is NO");
        self.status = GrowingCAIDFetcherStatusDenied;
        return;
    }
    
    if (!trackConfiguration.CAIDFetchBlock) {
        GIOLogDebug(@"[GrowingAdvertising] CAIDFetcher - CAIDFetchBlock is nil");
        self.status = GrowingCAIDFetcherStatusDenied;
        return;
    }

    [[GrowingEventManager sharedInstance] addInterceptor:[GrowingCAIDFetcher sharedInstance]];
    CGFloat timeOut = kGrowingCAIDFetcherDefaultTimeOut;
    GIOLogDebug(@"[GrowingAdvertising] CAIDFetcher start fetch with time out %.2f sec", timeOut);
    self.status = GrowingCAIDFetcherStatusFetching;
    [[GrowingCAIDFetcher sharedInstance] fetchCAID];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.status != GrowingCAIDFetcherStatusFetching) {
            return;
        }
        GrowingCAIDFetcher.status = GrowingCAIDFetcherStatusFailure;
        GIOLogError(@"[GrowingAdvertising] CAIDFetcher error: time is out");
    });
}

#pragma mark - Private Method

- (void)fetchCAID {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    trackConfiguration.CAIDFetchBlock(^(NSString * _Nonnull CAID) {
        if (CAID.length > 0) {
            GrowingCAIDFetcher.caid = CAID;
            GrowingCAIDFetcher.status = GrowingCAIDFetcherStatusSuccess;
        } else {
            GrowingCAIDFetcher.status = GrowingCAIDFetcherStatusFailure;
        }
    });
}

#pragma mark - Setter & Getter

+ (GrowingCAIDFetcherStatus)status {
    pthread_rwlock_rdlock(&_lock);
    int status = ((NSNumber *)objc_getAssociatedObject(self, _cmd)).intValue;
    pthread_rwlock_unlock(&_lock);
    return status;
}

+ (void)setStatus:(GrowingCAIDFetcherStatus)status {
    if (self.status == status) {
        return;
    }

    pthread_rwlock_wrlock(&_lock);
    objc_setAssociatedObject(self, @selector(status), @(status), OBJC_ASSOCIATION_ASSIGN);
    pthread_rwlock_unlock(&_lock);
    GIOLogDebug(@"[GrowingAdvertising] CAIDFetcher fetch status change to %@", [self statusDescription]);
}

+ (NSString *)statusDescription {
    switch (self.status) {
        case GrowingCAIDFetcherStatusDenied:
            return @"denied";
        case GrowingCAIDFetcherStatusFetching:
            return @"fetching";
        case GrowingCAIDFetcherStatusSuccess:
            return @"success";
        case GrowingCAIDFetcherStatusFailure:
            return @"failure";
        default:
            return @"";
    }
}

+ (nullable NSString *)caid {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setCaid:(NSString *)caid {
    objc_setAssociatedObject(self, @selector(caid), caid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    GIOLogDebug(@"[GrowingAdvertising] CAIDFetcher set CAID = %@", caid);
}

@end
