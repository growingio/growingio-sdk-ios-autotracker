//
// GrowingDeepLinkHandler.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/30.
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


#import "GrowingDeepLinkHandler.h"
#import "NSURL+GrowingHelper.h"
#import "GrowingNetworkConfig.h"
#import "GrowingLogger.h"
#import "GrowingASLLoggerFormat.h"
#import "GrowingWebWatcher.h"
//#import "GrowingMobileDebugger.h"

@interface GrowingDeepLinkHandler ()

@property(strong, nonatomic, readonly) NSPointerArray *handlers;
@property(strong, nonatomic, readonly) NSLock *lock;
@end

@implementation GrowingDeepLinkHandler

+ (instancetype)sharedInstance {
    static GrowingDeepLinkHandler *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[GrowingDeepLinkHandler alloc] init];
    });
    return handler;
}

- (instancetype)init {
    if (self = [super init]) {
        _handlers = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)addHandlersObject:(id)object {
    [self.lock lock];
    if (![self.handlers.allObjects containsObject:object]) {
        [self.handlers addPointer:(__bridge void *)object];
    }
    [self.lock unlock];
}

- (void)removeHandlersObject:(id)object {
    [self.lock lock];
    [self.handlers.allObjects
            enumerateObjectsWithOptions:NSEnumerationReverse
                             usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                 if (object == obj) {
                                     [self.handlers removePointerAtIndex:idx];
                                     *stop = YES;
                                 }
                             }];
    [self.lock unlock];
}

- (BOOL)dispatchHandlerUrl:(NSURL *)url {
    [self.lock lock];
    for (id object in self.handlers) {
        if ([object respondsToSelector:@selector(growingHandlerUrl:)]) {
            if ([object growingHandlerUrl:url]) {
                //如果有一个handler处理，则break，不再继续执行后续handler
                break;
            }
        }
    }
    [self.lock unlock];
    return YES;
}

+ (BOOL)handlerUrl:(NSURL *)url {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:[GrowingWebWatcher sharedInstance]];
    });
    return [[self sharedInstance] dispatchHandlerUrl:url];
}

@end
