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
#import "NSString+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "UIViewController+GrowingNode.h"


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

/// 获取某个view的xpath
/// @param view 节点
/// @param isSimilar 是否返回相似路径
+ (NSString *)xPathForView:(UIView *)view similar:(BOOL)isSimilar {
    NSMutableArray *viewPathArray = [NSMutableArray array];
    id<GrowingNode> node = view;
    
    while (node && [node isKindOfClass:[UIView class]]) {
        if (isSimilar) {
            if (node.growingNodeSubSimilarPath.length > 0) {
                [viewPathArray addObject:node.growingNodeSubSimilarPath];
                isSimilar = NO;
            }
        }else {
            if (node.growingNodeSubPath.length > 0) [viewPathArray addObject:node.growingNodeSubPath];
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


+ (NSString *)buildElementContentForNode:(id<GrowingNode> _Nonnull)view {
    NSString *content = [view growingNodeContent];
    if (!content) {
        content = @"";
    } else if ([content isKindOfClass:NSDictionary.class]) {
        content = [[(NSDictionary *)content allValues] componentsJoinedByString:@""];
    } else if ([content isKindOfClass:NSArray.class]) {
        content = [(NSArray *)content componentsJoinedByString:@""];
    } else {
        content = content.description;
    }

    if (![content isKindOfClass:NSString.class]) {
        content = @"";
    }

    content = [content growingHelper_safeSubStringWithLength:100];

    if (content.growingHelper_isLegal) {
        content = @"";
    } else {
        content = content.growingHelper_encryptString;
    }

    return content;
}

+ (GrowingViewNode *)getViewNode:(UIView *)view {
    NSPointerArray *weakArray = [NSPointerArray weakObjectsPointerArray];
    GrowingViewNode *viewNode = [self getTopViewNode:view array:weakArray];
    for (int i = weakArray.count - 2; i >= 0; i--) {
        viewNode = [viewNode appendNode:(UIView *)[weakArray pointerAtIndex:i] isRecalculate:NO];
    }
    return viewNode;
}

+ (GrowingViewNode *)getTopViewNode:(UIView *)view array:(NSPointerArray *)weakArray {
    if (weakArray == nil) {
        weakArray = [NSPointerArray weakObjectsPointerArray];
    }
    
    UIView *parent = view;
    do {
        [weakArray addPointer:(void*)parent];
        parent = parent.growingNodeParent;
    } while ([parent isKindOfClass:[UIView class]]);
    
    UIView *rootview = [weakArray pointerAtIndex:weakArray.count - 1];
    NSString *xpath = nil;
    NSString *originXPath = nil;
    
    xpath = [self xPathForView:rootview similar:YES];
    originXPath = [self xPathForView:rootview similar:NO];
    return GrowingViewNode.builder
    .setView(rootview)
    .setIndex(-1)
    .setViewContent([self buildElementContentForNode:rootview])
    .setXPath(xpath)
    .setOriginXPath(originXPath)
    .setNodeType([self getViewNodeType:rootview])
    .build;
}


//文本
static NSString *const kGrowingViewNodeText = @"TEXT";
//按钮
static NSString *const kGrowingViewNodeButton = @"BUTTON";
//输入框
static NSString *const kGrowingViewNodeInput = @"INPUT";
//列表元素 - 这里指TableView中的cell元素
static NSString *const kGrowingViewNodeList = @"LIST";
// WKWebView - webview只做标记用，不参与元素定义。
static NSString *const kGrowingViewNodeWebView = @"WEB_VIEW";

+ (NSString *)getViewNodeType:(UIView *)view {
    // 1. 默认 TEXT
    // 2. 判断特殊类型 并赋值
    // 3. 不属于上述类型，且可以点击，则为 BUTTON
    // 4. 否则以 TEXT 传入
    NSString *nodetype = kGrowingViewNodeText;
    if ([view isKindOfClass:NSClassFromString(@"_UIButtonBarButton")] ||
        [view isKindOfClass:NSClassFromString(@"_UIModernBarButton")]) {
        nodetype = kGrowingViewNodeButton;
    } else if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UISearchBar class]] ||
               [view isKindOfClass:[UITextView class]]) {
        nodetype = kGrowingViewNodeInput;
    } else if ([view isKindOfClass:[UICollectionViewCell class]] || [view isKindOfClass:[UITableViewCell class]]) {
        nodetype = kGrowingViewNodeList;
    } else if ([view isKindOfClass:NSClassFromString(@"WKWebView")]) {
        nodetype = kGrowingViewNodeWebView;
    } else if ([view growingNodeUserInteraction]) {
        nodetype = kGrowingViewNodeButton;
    }
    return nodetype;
}

@end
