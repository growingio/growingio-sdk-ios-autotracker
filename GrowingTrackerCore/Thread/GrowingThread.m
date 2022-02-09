//
// GrowingThread.m
// GrowingAnalytics
//
//  Created by sheng on 2020/12/24.
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

#import "GrowingThread.h"

@interface GrowingThread () {
    dispatch_group_t _waitGroup;
}

@property (nonatomic, strong, readwrite) NSRunLoop *runLoop;

@end

@implementation GrowingThread

+ (instancetype)sharedThread {
    static GrowingThread *thread;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[GrowingThread alloc] init];
        thread.name = @"com.growing.thread";
        [thread start];
    });
    return thread;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _waitGroup = dispatch_group_create();
        dispatch_group_enter(_waitGroup);
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        _runLoop = [NSRunLoop currentRunLoop];
        dispatch_group_leave(_waitGroup);

        // Add an empty run loop source to prevent runloop from spinning.
        CFRunLoopSourceContext sourceCtx = {.version = 0,
                                            .info = NULL,
                                            .retain = NULL,
                                            .release = NULL,
                                            .copyDescription = NULL,
                                            .equal = NULL,
                                            .hash = NULL,
                                            .schedule = NULL,
                                            .cancel = NULL,
                                            .perform = NULL};
        CFRunLoopSourceRef source = CFRunLoopSourceCreate(NULL, 0, &sourceCtx);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
        CFRelease(source);

        while ([_runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        }
        assert(NO);
    }
}

- (NSRunLoop *)runLoop {
    dispatch_group_wait(_waitGroup, DISPATCH_TIME_FOREVER);
    return _runLoop;
}

@end
