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


#import "GrowingDebuggerEventQueue.h"
#import "GrowingEventManager.h"

#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

static const NSInteger kGIOMaxCachesLogNumber = 50;

@interface GrowingDebuggerEventQueue () <GrowingEventInterceptor>

@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, assign) NSInteger maxCachesNumber;

@end

@implementation GrowingDebuggerEventQueue {
    dispatch_semaphore_t _lock;
}

static GrowingDebuggerEventQueue *shareInstance = nil;

+ (void)startQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[GrowingDebuggerEventQueue alloc] init];
    });
    [[GrowingEventManager shareInstance] addInterceptor:shareInstance];
}

+ (instancetype)currentQueue {
    return shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _lock = dispatch_semaphore_create(1);
        _cacheArray = [[NSMutableArray alloc] init];
        _maxCachesNumber = kGIOMaxCachesLogNumber;
    }
    return self;
}

- (void)dequeue {
    if (self.debuggerBlock) {
        LOCK(NSArray *arr = self.cacheArray.copy);
        self.debuggerBlock(arr);
        LOCK([self.cacheArray removeAllObjects]);
    }
}

- (void)enqueue:(id)anObject {
    if (self.debuggerBlock) {
        LOCK([self.cacheArray addObject:anObject];
             NSArray *arr = self.cacheArray.copy;);
        self.debuggerBlock(arr);
        LOCK([self.cacheArray removeAllObjects]);
    } else {
        while ((NSInteger)self.cacheArray.count >= self.maxCachesNumber) {
            LOCK([self.cacheArray removeObjectAtIndex:0]);
        }
        LOCK([self.cacheArray addObject:anObject]);
    }
}

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *)event {
    [self enqueue:event.toDictionary];
}

@end
