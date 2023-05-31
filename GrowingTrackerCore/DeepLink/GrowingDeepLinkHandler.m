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

#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/DeepLink/GrowingWebWatcher.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/LogFormat/GrowingASLLoggerFormat.h"
#import "GrowingTrackerCore/Network/Request/GrowingNetworkConfig.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

@interface GrowingDeepLinkHandler ()

@property (strong, nonatomic, readonly) NSPointerArray *handlers;

@end

@implementation GrowingDeepLinkHandler {
    GROWING_LOCK_DECLARE(lock);
}

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
        GROWING_LOCK_INIT(lock);
    }
    return self;
}

- (void)addHandlersObject:(id)object {
    GROWING_LOCK(lock);
    if (![self.handlers.allObjects containsObject:object]) {
        [self.handlers addPointer:(__bridge void *)object];
    }
    GROWING_UNLOCK(lock);
}

- (void)removeHandlersObject:(id)object {
    GROWING_LOCK(lock);
    [self.handlers.allObjects enumerateObjectsWithOptions:NSEnumerationReverse
                                               usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                                   if (object == obj) {
                                                       [self.handlers removePointerAtIndex:idx];
                                                       *stop = YES;
                                                   }
                                               }];
    GROWING_UNLOCK(lock);
}

- (BOOL)dispatchHandlerUrl:(NSURL *)url {
    GROWING_LOCK(lock);
    for (id object in self.handlers) {
        if ([object respondsToSelector:@selector(growingHandlerUrl:)]) {
            if ([object growingHandlerUrl:url]) {
                // 如果有一个handler处理，则break，不再继续执行后续handler
                break;
            }
        }
    }
    GROWING_UNLOCK(lock);
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
