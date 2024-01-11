//
// GrowingScreenshotProvider.h
// GrowingAnalytics
//
//  Created by sheng on 2023/5/9.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Services/Screenshot/GrowingScreenshotProvider.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "GrowingULSwizzle.h"
#import "Services/Screenshot/UIApplication+Screenshot.h"

GrowingService(GrowingScreenshotService, GrowingScreenshotProvider)

@interface GrowingScreenshotProvider ()

@property (strong, nonatomic, readonly) NSPointerArray *observers;

@end

@implementation GrowingScreenshotProvider {
    GROWING_LOCK_DECLARE(lock);
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _observers = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        GROWING_LOCK_INIT(lock);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

#pragma mark - GrowingApplicationEventProtocol

- (void)addApplicationEventObserver:(id<GrowingApplicationEventProtocol>)delegate {
    GROWING_LOCK(lock);
    if (![self.observers.allObjects containsObject:delegate]) {
        [self.observers addPointer:(__bridge void *)delegate];
    }
    GROWING_UNLOCK(lock);
}

- (void)removeApplicationEventObserver:(id<GrowingApplicationEventProtocol>)delegate {
    GROWING_LOCK(lock);
    [self.observers.allObjects enumerateObjectsWithOptions:NSEnumerationReverse
                                                usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                                    if (delegate == obj) {
                                                        [self.observers removePointerAtIndex:idx];
                                                        *stop = YES;
                                                    }
                                                }];
    GROWING_UNLOCK(lock);
}

- (void)dispatchApplicationEventSendEvent:(UIEvent *)event {
    GROWING_LOCK(lock);
    for (id observer in self.observers) {
        if ([observer respondsToSelector:@selector(growingApplicationEventSendEvent:)]) {
            [observer growingApplicationEventSendEvent:event];
        }
    }
    GROWING_UNLOCK(lock);
}

#pragma mark - GrowingBaseService

+ (BOOL)singleton {
    return YES;
}

#pragma mark - GrowingScreenshotService

- (UIImage *)screenshot {
    CGFloat scale = MIN([UIScreen mainScreen].scale, 2);
    NSArray *windows = [UIApplication sharedApplication].growingHelper_allWindowsWithoutGrowingWindow;
    windows = [windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *obj1, UIWindow *obj2) {
        if (obj1.windowLevel == obj2.windowLevel) {
            return NSOrderedSame;
        } else if (obj1.windowLevel > obj2.windowLevel) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];

    UIImage *image = [UIWindow growingHelper_screenshotWithWindows:windows andMaxScale:scale];
    return image;
}

- (void)addSendEventSwizzle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // UIApplication
        NSError *error = NULL;
        [UIApplication growingul_swizzleMethod:@selector(sendEvent:)
                                    withMethod:@selector(growing_sendEvent:)
                                         error:&error];
        if (error) {
            GIOLogError(@"Failed to swizzle UIApplication sendEvent. Details: %@", error);
        }
    });
}

@end
