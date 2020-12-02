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

@implementation GrowingNodeHelper

//当node为列表视图时，返回路径为 TableView/cell[-]，序号在index字段中返回
+ (NSString *)xPathSimilarForNode:(id<GrowingNode>)node {
    if ([node isKindOfClass:[UIView class]]) {
        return [self xPathForView:(UIView*)node similar:YES];
    }else if ([node isKindOfClass:[UIViewController class]]) {
        return [self xPathForViewController:(UIViewController*)node];;
    }
    return nil;
}

+ (NSString *)xPathForNode:(id<GrowingNode>)node {
    if ([node isKindOfClass:[UIView class]]) {
        return [self xPathForView:(UIView*)node similar:NO];
    }else if ([node isKindOfClass:[UIViewController class]]) {
        return [self xPathForViewController:(UIViewController*)node];;
    }
    return nil;
}

+ (NSString *)xPathForView:(UIView *)view similar:(BOOL)isSimilar{
    NSMutableArray *viewPathArray = [NSMutableArray array];
    id<GrowingNode> node = view;
    
    while (node && [node isKindOfClass:[UIView class]]) {
        if (isSimilar) {
            [viewPathArray addObject:node.growingNodeSubSimilarPath];
            isSimilar = NO;
        }else {
            [viewPathArray addObject:node.growingNodeSubPath];
        }
        node = node.growingNodeParent;
    }
    // 当检测到viewController时，会替换成page字段
    // 此时则需要判断是否ignored以及过滤
    if ([node isKindOfClass:[UIViewController class]]) {
        while (node) {
            if ([[GrowingPageManager sharedInstance] isPrivateViewControllerIgnored:(UIViewController *) node]) {
                if (node.growingNodeSubPath.length > 0) [viewPathArray addObject:node.growingNodeSubPath];
            }else {
                GrowingPageGroup *page = [(UIViewController*)node growingPageHelper_getPageObject];
                if (page.isIgnored) {
                    if (node.growingNodeSubPath.length > 0) [viewPathArray addObject:node.growingNodeSubPath];
                }else {
                    [viewPathArray addObject:kGrowingNodeRootPage];
                    break;
                }
            }
            node = node.growingNodeParent;
        }
        //如果遍历到了根节点(即没有parent)，说明所有层级vc都被过滤，则添加IgnorePage
        if (!node) {
            [viewPathArray addObject:kGrowingNodeRootIgnore];
        }
    }
    
    NSString *viewPath = [[[viewPathArray reverseObjectEnumerator] allObjects] componentsJoinedByString:@"/"];
    viewPath = [@"/" stringByAppendingString:viewPath];
    return viewPath;
}


+ (NSString *)xPathForViewController:(UIViewController *)vc {
    NSAssert(vc, @"+xPathForViewController: vc is nil");
    GrowingPageGroup *page = [[GrowingPageManager sharedInstance] findPageByViewController:vc];
    return page.path;
}


@end
