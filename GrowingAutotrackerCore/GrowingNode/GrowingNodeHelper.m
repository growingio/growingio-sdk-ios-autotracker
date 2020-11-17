//
//  GrowingNodeHelper.m
//  GrowingAnalytics
//
//  Created by sheng on 2020/8/20.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingNodeHelper.h"
#import "UIView+GrowingNode.h"
#import "UIViewController+GrowingNode.h"
#import "GrowingPageManager.h"
#import "GrowingPageGroup.h"
#import "UIViewController+GrowingPageHelper.h"
#import "GrowingCocoaLumberjack.h"

static NSString * const kGrowingNodeRootPage = @"Page";
static NSString * const kGrowingNodeRootIgnore = @"IgnorePage";

static NSTimeInterval kGrowingTrackClickMinTimeInterval = 0.1;

@implementation GrowingNodeHelper

+ (BOOL)isValidClickEventForNode:(id<GrowingNode>)node {
    if (!node) {
        return NO;
    }
    
    NSTimeInterval lastTime = node.growingTimeIntervalForLastClick;
    NSTimeInterval currentTime = [NSProcessInfo processInfo].systemUptime;
    if (lastTime > 0 && (currentTime - lastTime) < kGrowingTrackClickMinTimeInterval) {
        return NO;
    }
    
    return YES;
}

+ (NSString *)xPathForNode:(id<GrowingNode>)node {
    if ([node isKindOfClass:[UIView class]]) {
        return [self xPathForView:(UIView*)node];;
    }else if ([node isKindOfClass:[UIViewController class]]) {
        return [self xPathForViewController:(UIViewController*)node];;
    }
    return nil;
}

+ (NSString *)xPathForView:(UIView *)view {
    NSMutableArray *viewPathArray = [NSMutableArray array];
    id<GrowingNode> node = view;
    id<GrowingNode> parent = nil;
    /**
    1. 先以触发的View向上追溯父View ，直至找到第一个 Page
    2.如果 Page 没被 ignored，然后替换为 /Page，转到 5
    3.如果 Page 被忽略，那么向上追溯 Page （中间的View不再追溯），然后首部 插入 /Page ，转到 5
    4.如果全部被 ignored，首部 插入 /IgnorePage，则转到 5
    5.生成xpath
    */
    do {
        parent = node.growingNodeParent;
        //当时跟视图时
        if (parent) {
            if ([parent isKindOfClass:[UIViewController class]]) {
                if ([[GrowingPageManager sharedInstance] isViewControllerIgnored:(UIViewController*)parent]) {
                    if (parent.growingNodeSubPath.length > 0) [viewPathArray addObject:parent.growingNodeSubPath];
                }else {
                    GrowingPageGroup *page = [self getPageObjectWithViewController:(UIViewController*)parent];
                    if (page.isIgnored) {
                        if (parent.growingNodeSubPath.length > 0) [viewPathArray addObject:parent.growingNodeSubPath];
                    }else {
                        [viewPathArray addObject:kGrowingNodeRootPage];
                        break;
                    }
                }
            }else {
                if (node.growingNodeSubPath.length > 0) [viewPathArray addObject:node.growingNodeSubPath];
            }
        }else {
            [viewPathArray addObject:kGrowingNodeRootIgnore];
        }
        node = parent;
    } while (node);
    
    NSString *viewPath = [[[viewPathArray reverseObjectEnumerator] allObjects] componentsJoinedByString:@"/"];
    viewPath = [@"/" stringByAppendingString:viewPath];
    return viewPath;
}


+ (NSString *)xPathForViewController:(UIViewController *)vc {
    if (!vc) {
        return nil;
    }
    UIViewController <GrowingNode>*current = vc;
    id <GrowingNode> parent = current.growingNodeParent;
    //当为 UIAlertController 时，向上寻找没有被忽略的节点
    while (parent) {
        if ([[GrowingPageManager sharedInstance] isViewControllerIgnored:current]) {
            current = (UIViewController<GrowingNode>*)parent;
        }else {
            GrowingPageGroup *page = [self getPageObjectWithViewController:current];
            if (page.isIgnored) {
                current = (UIViewController<GrowingNode>*)parent;
            }else {
                break;
            }
        }
        parent = parent.growingNodeParent;
    }
    
    GrowingPageGroup *page = [self getPageObjectWithViewController:current];
    
    return page.path;
}


+ (GrowingPageGroup *)getPageObjectWithViewController:(UIViewController *)vc {
    GrowingPageGroup *page = [vc growingPageHelper_getPageObject];
    if (!page) {
        [[GrowingPageManager sharedInstance] createdViewControllerPage:vc];
        page = [vc growingPageHelper_getPageObject];
    }
    return page;
}

@end
