//
//  UIView+GrowingViewImpressionInternal.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import <objc/runtime.h>
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "Modules/ViewImpression/GrowingViewImpression+Private.h"
#import "Modules/ViewImpression/UIView+GrowingViewImpressionInternal.h"

@implementation UIView (GrowingViewImpressionInternal)

- (NSMutableDictionary<NSString *, GrowingViewImpressionNode *> *)growingViewImpNodes {
    return objc_getAssociatedObject(self, @selector(growingViewImpNodes));
}

- (NSMutableDictionary<NSString *, GrowingViewImpressionNode *> *)growingViewImpNodesCreateIfNeeded {
    NSMutableDictionary *nodes = self.growingViewImpNodes;
    if (!nodes) {
        nodes = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(growingViewImpNodes), nodes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return nodes;
}

- (void)growingViewImpMark:(NSString *)eventName
                attributes:(NSDictionary<NSString *, id> *)attributes
                identifier:(NSString *)identifier
                    config:(GrowingViewImpressionConfig *)config {
    if (eventName.length == 0) {
        return;
    }

    [GrowingDispatchManager dispatchInMainThread:^{
        GrowingViewImpressionNode *node = [[GrowingViewImpressionNode alloc] init];
        node.eventName = eventName;
        node.attributes = attributes;
        node.identifier = identifier;
        node.config = [GrowingViewImpression effectiveConfig:config];

        NSString *slot = identifier.length > 0 ? identifier : kGrowingViewImpDefaultSlot;
        [self growingViewImpNodesCreateIfNeeded][slot] = node;
        [[GrowingViewImpression sharedInstance] addImpressionView:self];
    }];
}

- (void)growingViewImpUnmarkAll {
    [GrowingDispatchManager dispatchInMainThread:^{
        objc_setAssociatedObject(self, @selector(growingViewImpNodes), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[GrowingViewImpression sharedInstance] removeImpressionView:self];
    }];
}

- (void)growingViewImpUnmarkSlot:(NSString *)identifier {
    if (identifier.length == 0) {
        return;
    }

    [GrowingDispatchManager dispatchInMainThread:^{
        NSMutableDictionary *nodes = self.growingViewImpNodes;
        [nodes removeObjectForKey:identifier];
        if (nodes.count == 0) {
            [self growingViewImpUnmarkAll];
        }
    }];
}

- (BOOL)growingViewImpNodeIsVisibleWithScale:(float)viewImpressionScale {
    if (!self.window || self.hidden || self.alpha < 0.001 || !self.superview) {
        return NO;
    }
    if (CGRectIsEmpty(self.bounds)) {
        return NO;
    }

    // visible 始终停留在 node 的坐标系，每轮开头先转换到 parent 坐标系再裁剪
    CGRect visible = self.bounds;
    UIView *node = self;
    while (node.superview) {
        UIView *parent = node.superview;
        if (parent.hidden || parent.alpha < 0.001) {
            return NO;
        }
        visible = [node convertRect:visible toView:parent];
        if (parent.clipsToBounds || [parent isKindOfClass:[UIScrollView class]]) {
            visible = CGRectIntersection(visible, parent.bounds);
            if (CGRectIsEmpty(visible) || CGRectIsNull(visible)) {
                return NO;
            }
        }
        node = parent;
    }

    // 循环结束时 node 即 window，visible 已在 window 坐标系
    visible = CGRectIntersection(visible, self.window.bounds);
    if (CGRectIsEmpty(visible) || CGRectIsNull(visible)) {
        return NO;
    }

    if (viewImpressionScale <= 0.0f) {
        return YES;
    }
    CGFloat total = CGRectGetWidth(self.bounds) * CGRectGetHeight(self.bounds);
    return total > 0 && (visible.size.width * visible.size.height) >= total * viewImpressionScale;
}

@end
