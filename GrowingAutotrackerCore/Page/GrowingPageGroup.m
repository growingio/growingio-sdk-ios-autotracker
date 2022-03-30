//
//  GrowingPageGroup.m
//  GrowingAnalytics
//
// Created by xiangyang on 2020/4/27.
// Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "GrowingAutotrackerCore/Page/GrowingPageGroup.h"

@implementation GrowingPageGroup {
    dispatch_semaphore_t _lock;
}

- (void)addChildrenPage:(GrowingPage *)page {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (![self.childPages.allObjects containsObject:page]) {
        [self.childPages addPointer:(__bridge void *)page];
    }
    dispatch_semaphore_signal(_lock);
}

- (void)removeChildrenPage:(GrowingPage *)page {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.childPages.allObjects enumerateObjectsWithOptions:NSEnumerationReverse
                                                 usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (page == obj) {
            [self.childPages removePointerAtIndex:idx];
            *stop = YES;
        }
    }];
    dispatch_semaphore_signal(_lock);
}

- (instancetype)initWithCarrier:(UIViewController *)carrier {
    if (self = [super initWithCarrier:carrier]) {
        _childPages = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _childPages = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        _lock = dispatch_semaphore_create(1);
    }

    return self;
}

@end
