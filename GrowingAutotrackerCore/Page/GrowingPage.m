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
#import "GrowingULTimeUtil.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

@interface GrowingPage ()


@property (nonatomic, copy) NSString *pathName;


@property (nonatomic, copy, readonly) NSString *pathCopy;

@end

@implementation GrowingPage {
    GROWING_LOCK_DECLARE(lock);
}

#pragma mark - Init

- (instancetype)initWithCarrier:(UIViewController *)carrier {
    self = [super init];
    if (self) {
        _carrier = carrier;
        _showTimestamp = GrowingULTimeUtil.currentTimeMillis;
        _title = [carrier growingPageTitle];
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

- (NSString *)pathName {
    if (self.carrier == nil) {
        return nil;
    }

    if (![NSString growingHelper_isBlankString:self.alias]) {
        return self.alias;
    }

    NSString *clazz = NSStringFromClass(self.carrier.class);
    NSString *tag = self.tag;
    if (tag == nil) {
        return clazz;
    } else {
        return [NSString stringWithFormat:@"%@[%@]", clazz, tag];
    }
}

- (NSString *)tag {
    if (self.carrier == nil) {
        return nil;
    }
    UIViewController *parentViewController = self.carrier.parentViewController;
    if (parentViewController == nil) {
        return nil;
    }
    NSArray<UIViewController *> *childs = parentViewController.childViewControllers;
    int index = 0;
    for (UIViewController *child in childs) {
        if (self.carrier == child) {
            return [NSString stringWithFormat:@"%d", index];
        }

        if (self.carrier.class == child.class) {
            index++;
        }
    }
    return nil;
}

- (NSString *)path {
    if (self.pathCopy != nil) {
        return self.pathCopy;
    }

    if (self.alias != nil) {
        _pathCopy = [NSString stringWithFormat:@"/%@", self.alias];
        return self.pathCopy;
    }

    NSMutableArray<GrowingPage *> *pageTree = [NSMutableArray array];
    [pageTree addObject:self];
    GrowingPage *pageParent = self.parent;
    while (pageParent != nil) {
        [pageTree addObject:pageParent];
        if (![NSString growingHelper_isBlankString:pageParent.alias]) {
            break;
        }
        pageParent = pageParent.parent;
    }
    NSString *path = [NSString string];
    for (NSInteger i = 0; i < pageTree.count; ++i) {
        if (i >= 3) {
            // SDK3.0 xpath逻辑调整,仅遍历UIViewController的三层视图
            path = [NSString stringWithFormat:@"*%@", path];
            break;
        }
        NSString *subpath = [NSString stringWithFormat:@"/%@", pageTree[i].pathName];
        path = [NSString stringWithFormat:@"%@%@", subpath, path];
    }
    _pathCopy = path;
    return self.pathCopy;
}

@end
