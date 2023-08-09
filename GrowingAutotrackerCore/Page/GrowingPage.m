//
//  GrowingPage.m
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

#import "GrowingAutotrackerCore/Page/GrowingPage.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "GrowingULTimeUtil.h"

@implementation GrowingPage {
    GROWING_LOCK_DECLARE(lock);
}

#pragma mark - Init

- (instancetype)initWithCarrier:(UIViewController *)carrier {
    self = [super init];
    if (self) {
        _carrier = carrier;
        _showTimestamp = GrowingULTimeUtil.currentTimeMillis;
        _childPages = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        GROWING_LOCK_INIT(lock);
    }

    return self;
}

+ (instancetype)pageWithCarrier:(UIViewController *)carrier {
    return [[self alloc] initWithCarrier:carrier];
}

#pragma mark - Public

- (void)refreshShowTimestamp {
    _showTimestamp = GrowingULTimeUtil.currentTimeMillis;
}

- (void)addChildrenPage:(GrowingPage *)page {
    GROWING_LOCK(lock);
    if (![self.childPages.allObjects containsObject:page]) {
        [self.childPages addPointer:(__bridge void *)page];
    }
    GROWING_UNLOCK(lock);
}

- (void)removeChildrenPage:(GrowingPage *)page {
    GROWING_LOCK(lock);
    [self.childPages.allObjects enumerateObjectsWithOptions:NSEnumerationReverse
                                                 usingBlock:^(NSObject *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                                     if (page == obj) {
                                                         [self.childPages removePointerAtIndex:idx];
                                                         *stop = YES;
                                                     }
                                                 }];
    GROWING_UNLOCK(lock);
}

#pragma mark - Setter & Getter

// 所有属性都通过动态获取，不做内存存储
- (BOOL)isAutotrack {
    return self.carrier.growingPageAlias != nil;
}

- (NSString *)title {
    return self.carrier.growingPageTitle;
}

- (NSDictionary<NSString *, NSString *> *)attributes {
    return self.carrier.growingPageAttributes;
}

- (NSString *)alias {
    return self.carrier.growingPageAlias;
}

- (NSString *)tag {
    UIViewController *parentViewController = self.carrier.parentViewController;
    if (parentViewController == nil) {
        return nil;
    }
    NSArray<UIViewController *> *childs = parentViewController.childViewControllers;
    int index = 0;
    for (UIViewController *child in childs) {
        if (self.carrier == child) {
            break;
        }
        if (self.carrier.class == child.class) {
            index++;
        }
    }
    return [NSString stringWithFormat:@"%d", index];
}

- (NSDictionary *)pathInfo {
    NSPointerArray *pageTree = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    GrowingPage *pageParent = self;
    do {
        [pageTree addPointer:(__bridge void *)pageParent];
        pageParent = pageParent.parent;
    } while (pageParent != nil);

    NSMutableString *xpath = [NSMutableString string];
    NSMutableString *xcontent = [NSMutableString string];
    NSArray *array = pageTree.allObjects;
    for (int i = (int)(array.count - 1); i >= 0; i--) {
        GrowingPage *page = array[i];
        [xpath appendFormat:@"/%@", NSStringFromClass(page.carrier.class)];
        [xcontent appendFormat:@"/%@", page.tag ?: @"0"];
    }

    return @{@"xpath": xpath, @"xcontent": xcontent};
}

@end
