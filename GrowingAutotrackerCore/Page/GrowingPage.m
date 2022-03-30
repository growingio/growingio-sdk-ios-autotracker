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
#import "GrowingAutotrackerCore/Page/GrowingPageGroup.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Page/UIViewController+GrowingPageHelper.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"

@interface GrowingPage ()
@property(nonatomic, copy, readonly) NSString *pathCopy;
@end

@implementation GrowingPage

- (instancetype)initWithCarrier:(UIViewController *)carrier {
    self = [super init];
    if (self) {
        _carrier = carrier;
        _showTimestamp = GrowingTimeUtil.currentTimeMillis;
        _isIgnored = [carrier growingPageHelper_pageDidIgnore];
        _title = [carrier growingPageTitle];
    }

    return self;
}

+ (instancetype)pageWithCarrier:(UIViewController *)carrier {
    return [[self alloc] initWithCarrier:carrier];
}

- (void)refreshShowTimestamp {
    _showTimestamp = GrowingTimeUtil.currentTimeMillis;
}

- (NSString *)name {
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
    GrowingPageGroup *pageParent = self.parent;
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
            //SDK3.0 xpath逻辑调整,仅遍历UIViewController的三层视图
            path = [NSString stringWithFormat:@"*%@", path];
            break;
        }
        NSString *subpath = [NSString stringWithFormat:@"/%@",pageTree[i].name];
        path = [NSString stringWithFormat:@"%@%@",subpath,path];
    }
    _pathCopy = path;
    return self.pathCopy;
}

@end
