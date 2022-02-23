//
// GrowingStatusBarEventManager.m
// GrowingAnalytics
//
//  Created by sheng on 2020/12/28.
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


#import "GrowingStatusBarEventManager.h"

@interface GrowingStatusBarEventManager ()

@property (strong, nonatomic, readonly) NSPointerArray *observers;
@property (strong, nonatomic, readonly) NSLock *observerLock;

@end

@implementation GrowingStatusBarEventManager

+ (instancetype)sharedInstance {
    static GrowingStatusBarEventManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
        
        _sharedInstance->_observers = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        _sharedInstance->_observerLock = [[NSLock alloc] init];
    });

    return _sharedInstance;
}

// for safe sharedInstance
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

- (void)addStatusBarObserver:(id<GrowingStatusBarEventProtocol>)delegate {
    [self.observerLock lock];
    if (![self.observers.allObjects containsObject:delegate]) {
        [self.observers addPointer:(__bridge void *)delegate];
    }
    [self.observerLock unlock];
}

- (void)removeStatusBarObserver:(id<GrowingStatusBarEventProtocol>)delegate {
    [self.observerLock lock];
    [self.observers.allObjects enumerateObjectsWithOptions:NSEnumerationReverse
                                                usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                                    if (delegate == obj) {
                                                        [self.observers removePointerAtIndex:idx];
                                                        *stop = YES;
                                                    }
                                                }];
    [self.observerLock unlock];
}

- (void)dispatchTapStatusBar:(id)gesture {
    [self.observerLock lock];
    for (id observer in self.observers) {
        if ([observer respondsToSelector:@selector(didTapStatusBar:)]) {
            [observer didTapStatusBar:gesture];
        }
    }
    [self.observerLock unlock];
}

@end
