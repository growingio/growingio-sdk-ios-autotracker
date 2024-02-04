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

#import "GrowingAutotrackerCore/GrowingNode/GrowingNodeHelper.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTargetConditionals.h"

static NSString *const kGrowingNodeRootPage = @"Page";
static NSString *const kGrowingNodeRootIgnore = @"IgnorePage";

@implementation GrowingNodeHelper

+ (void)recalculateXpath:(UIView *)view
                   block:(void (^)(NSString *xpath, NSString *xcontent, NSString *originxcontent))block {
    id<GrowingNode> node = view;
    NSMutableArray *viewPathArray = [NSMutableArray array];
    NSMutableArray *xcontentArray = [NSMutableArray array];
    NSMutableArray *originxcontentArray = [NSMutableArray array];
    BOOL hasSimilarIndexInside = NO;
    while (node && [node isKindOfClass:[UIView class]]) {
        if ([self isIgnoredPrivateView:node]) {
            node = node.growingNodeParent;
            continue;
        }

        BOOL isSimilar = [node isKindOfClass:[UITableViewCell class]] ||
                         [node isKindOfClass:[UICollectionReusableView class]] ||
                         [node isKindOfClass:NSClassFromString(@"UISegment")];

        [originxcontentArray addObject:node.growingNodeSubIndex];
        if (isSimilar && !hasSimilarIndexInside) {
            [xcontentArray addObject:node.growingNodeSubSimilarIndex];
            hasSimilarIndexInside = YES;
        } else {
            [xcontentArray addObject:node.growingNodeSubIndex];
        }

        NSString *uniqueTag = ((UIView *)node).growingUniqueTag;
        if (uniqueTag && uniqueTag.length > 0) {
            [viewPathArray addObject:uniqueTag];
            node = nil;
        } else {
            [viewPathArray addObject:node.growingNodeSubPath];
            node = node.growingNodeParent;
        }
    }

    NSString * (^toStringBlock)(NSArray *) = ^(NSArray *array) {
        NSArray *reverse = array.reverseObjectEnumerator.allObjects;
        return [NSString stringWithFormat:@"/%@", [reverse componentsJoinedByString:@"/"]];
    };

    NSString *xpath = toStringBlock(viewPathArray);
    NSString *xcontent = toStringBlock(xcontentArray);
    NSString *originxcontent = toStringBlock(originxcontentArray);
    if (block) {
        block(xpath, xcontent, originxcontent);
    }
}

+ (GrowingViewNode *)getViewNode:(UIView *)view {
    NSPointerArray *weakArray = [NSPointerArray weakObjectsPointerArray];
    GrowingViewNode *viewNode = [self getTopViewNode:view array:weakArray];
    for (int i = (int)weakArray.count - 2; i >= 0; i--) {
        UIView *parent = [weakArray pointerAtIndex:i];
        if (parent) {
            viewNode = [viewNode appendNode:parent isRecalculate:NO];
        }
    }
    return viewNode;
}

+ (GrowingViewNode *)getTopViewNode:(UIView *)view array:(NSPointerArray *)weakArray {
    id<GrowingNode> parent = view;
    do {
        if (![self isIgnoredPrivateView:parent]) {
            [weakArray addPointer:(void *)parent];
        }
        parent = parent.growingNodeParent;
    } while ([parent isKindOfClass:[UIView class]]);

    UIView *rootview = [weakArray pointerAtIndex:weakArray.count - 1];
    return GrowingViewNode.builder.setView(rootview)
        .setIndex(-1)
        .setViewContent(rootview.growingNodeContent)
        .setXpath([NSString stringWithFormat:@"/%@", rootview.growingNodeSubPath])
        .setXcontent([NSString stringWithFormat:@"/%@", rootview.growingNodeSubSimilarIndex])
        .setOriginXcontent([NSString stringWithFormat:@"/%@", rootview.growingNodeSubIndex])
        .setNodeType([self getViewNodeType:rootview])
        .build;
}

+ (BOOL)isIgnoredPrivateView:(id<GrowingNode>)view {
    NSArray<NSString *> *ignoredViews =
        @[@"_UIAlertControllerPhoneTVMacView", @"_UIAlertControllerView", @"UITableViewWrapperView"];
    return [ignoredViews containsObject:NSStringFromClass(view.class)];
}

// 文本
static NSString *const kGrowingViewNodeText = @"TEXT";
// 按钮
static NSString *const kGrowingViewNodeButton = @"BUTTON";
// 输入框
static NSString *const kGrowingViewNodeInput = @"INPUT";
// 列表元素 - 这里指TableView中的cell元素
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
#if Growing_OS_IOS || Growing_OS_MACCATALYST || Growing_OS_VISION
    } else if ([view isKindOfClass:[UISlider class]]) {
        nodetype = kGrowingViewNodeInput;
#endif
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
