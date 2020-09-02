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
static NSString * const kGrowingNodeRootAlert = @"UIAlert";

@implementation GrowingNodeHelper

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
    do {
        id<GrowingNode> parent = node.growingNodeParent;
        //当时跟视图时
        //1. 如果是UIAlertViewController, /UIAlert/...
        //2. 如果是UIViewController, /Page/...
        if ([parent isKindOfClass:[UIAlertController class]]) {
            [viewPathArray addObject:kGrowingNodeRootAlert];
            break;
        }else if ([parent isKindOfClass:[UIViewController class]]) {
            UIViewController *parentVC = (UIViewController*)parent;
            UIView *nodeView = (UIView*)node;
            //1. VC.view 包含node 或者相等
            if ([nodeView isEqual:parentVC.view] || [nodeView isDescendantOfView:parentVC.view]) {
                [viewPathArray addObject:kGrowingNodeRootPage];
            }else {
                [viewPathArray addObject:node.growingNodeSubPath];
            }
            break;
        }
        
        [viewPathArray addObject:node.growingNodeSubPath];
        node = parent;
    } while (node);
    NSString *viewPath = [[[viewPathArray reverseObjectEnumerator] allObjects] componentsJoinedByString:@"/"];
    viewPath = [@"/" stringByAppendingString:viewPath];
    return viewPath;
}


+ (NSString *)xPathForViewController:(UIViewController *)vc {
    UIViewController <GrowingNode>*parent = vc;
    //当为 UIAlertController 时，向上寻找没有被忽略的节点
    while ([parent isKindOfClass:[UIAlertController class]]  || parent.growingPageIgnorePolicy == GrowingIgnoreSelf || parent.growingPageIgnorePolicy == GrowingIgnoreAll) {
        parent = parent.growingNodeParent;
    }
    //如果没有父VC，自己也被忽略，那么取自己
    if (!parent) {
        parent = vc;
    }
    GrowingPageGroup *page = [parent growingPageHelper_getPageObject];
    if (!page) {
        [[GrowingPageManager sharedInstance] createdViewControllerPage:parent];
        page = [parent growingPageHelper_getPageObject];
    }
    return page.path;
}


@end
