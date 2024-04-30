//
// GrowingDebuggerEventPool.m
// GrowingAnalytics
//
//  Created by sheng on 2021/3/31.
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

#import "Modules/MobileDebugger/GrowingDebuggerEventQueue.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

static const NSInteger kGIOMaxCachesLogNumber = 50;

@interface GrowingDebuggerEventQueue () <GrowingEventInterceptor>

@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, assign) NSInteger maxCachesNumber;

@end

@implementation GrowingDebuggerEventQueue {
    GROWING_LOCK_DECLARE(lock);
}

static GrowingDebuggerEventQueue *sharedInstance = nil;

+ (void)startQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GrowingDebuggerEventQueue alloc] init];
    });
    [[GrowingEventManager sharedInstance] addInterceptor:sharedInstance];
}

+ (instancetype)currentQueue {
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        GROWING_LOCK_INIT(lock);
        _cacheArray = [[NSMutableArray alloc] init];
        _maxCachesNumber = kGIOMaxCachesLogNumber;
    }
    return self;
}

- (void)dequeue {
    GROWING_LOCK(lock);
    if (self.debuggerBlock) {
        NSArray *array = self.cacheArray.copy;
        self.debuggerBlock(array);
        [self.cacheArray removeAllObjects];
    }
    GROWING_UNLOCK(lock);
}

- (void)enqueue:(id)anObject {
    GROWING_LOCK(lock);
    if (self.debuggerBlock) {
        [self.cacheArray addObject:anObject];
        NSArray *array = self.cacheArray.copy;
        self.debuggerBlock(array);
        [self.cacheArray removeAllObjects];
    } else {
        while ((NSInteger)self.cacheArray.count >= self.maxCachesNumber) {
            [self.cacheArray removeObjectAtIndex:0];
        }
        [self.cacheArray addObject:anObject];
    }
    GROWING_UNLOCK(lock);
}

- (void)growingEventManagerEventsSendingCompletion:(NSArray<id<GrowingEventPersistenceProtocol>> *)events
                                           request:(id<GrowingRequestProtocol>)request
                                           channel:(GrowingEventChannel *)channel
                                      httpResponse:(NSHTTPURLResponse *)httpResponse
                                             error:(NSError *)error {
    if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 400) {
        return;
    }

    if (events && request && request.absoluteURL) {
        NSString *url = request.absoluteURL.absoluteString.copy;
        for (id<GrowingEventPersistenceProtocol> event in events) {
            NSDictionary *eventDic = event.toJSONObject;
            if (!eventDic) {
                continue;
            }
            NSMutableDictionary *dic = eventDic.mutableCopy;
            [dic setObject:url forKey:@"url"];
            [self enqueue:dic];
        }
    }
}

@end
