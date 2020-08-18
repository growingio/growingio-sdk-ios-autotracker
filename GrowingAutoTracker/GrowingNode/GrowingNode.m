//
//  GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/12/12.
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

#import "GrowingNode.h"

#import "GrowingPageManager.h"
#import "GrowingPropertyDefine.h"
#import "UIApplication+GrowingHelper.h"
#import "UIApplication+GrowingNode.h"
#import "UIImage+GrowingHelper.h"
#import "UIViewController+GrowingAutoTrack.h"
#import "UIViewController+GrowingNode.h"
#import "UIWindow+GrowingNode.h"

@implementation NSObject (GrowingNode)

static char growingNodeIsBadNodeKey;
- (BOOL)growingNodeIsBadNode {
    return objc_getAssociatedObject(self, &growingNodeIsBadNodeKey) != nil;
}

- (void)setGrowingNodeIsBadNode:(BOOL)growingNodeIsBadNode {
    objc_setAssociatedObject(self, &growingNodeIsBadNodeKey, growingNodeIsBadNode ? @"yes" : nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation GrowingRootNode

- (id)growingNodeAttribute:(NSString *)attrbute {
    return nil;
}

- (id)growingNodeAttribute:(NSString *)attrbute forChild:(id<GrowingNode>)node {
    return nil;
}

- (UIImage *)growingNodeScreenShot:(UIImage *)fullScreenImage {
    return nil;
}

- (UIImage *)growingNodeScreenShotWithScale:(CGFloat)maxScale {
    return nil;
}

+ (instancetype)rootNode {
    static id node = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        node = [[self alloc] init];
    });
    return node;
}

// 原始父节点
- (id<GrowingNode>)growingNodeParent {
    return nil;
}

- (BOOL)growingNodeDonotTrack {
    return NO;
}

- (BOOL)growingNodeDonotCircle {
    return NO;
}

// 值
- (BOOL)growingNodeUserInteraction {
    return NO;
}
- (NSString *)growingNodeName {
    return @"根节点";
}
- (NSString *)growingNodeContent {
    return nil;
}

- (NSDictionary *)growingNodeDataDict {
    return [[[GrowingPageManager sharedInstance] currentViewController] growingNodeDataDict];
}

- (UIWindow *)growingNodeWindow {
    return nil;
}

- (CGRect)growingNodeFrame {
    return CGRectZero;
}

- (NSString *)growingNodeUniqueTag {
    return nil;
}

- (NSArray<id<GrowingNode>> *_Nullable)growingNodeChilds {
    return nil;
}

- (NSIndexPath *)growingNodeIndexPath {
    return nil;
}

- (NSString *)growingNodeSubPath {
    return nil;
}

- (NSString *)growingNodeSubSimilarPath {
    return nil;
}

- (NSInteger)growingNodeKeyIndex {
    return 0;
}

@end
