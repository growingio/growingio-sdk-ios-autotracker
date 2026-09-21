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
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
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
        GrowingViewImpressionConfig *nodeConfig = [GrowingViewImpression effectiveConfig:config];
        if (!nodeConfig.isRepeatable && identifier.length == 0) {
            nodeConfig.repeatable = YES;
            GIOLogWarn(
                @"[GrowingViewImpression] 事件 %@ 配置了不可重复曝光但未指定 identifier，"
                @"已按可重复曝光处理",
                eventName);
        }

        NSString *slot = identifier.length > 0 ? identifier : kGrowingViewImpDefaultSlot;
        NSMutableDictionary<NSString *, GrowingViewImpressionNode *> *nodes = [self growingViewImpNodesCreateIfNeeded];

        // 复用场景：同一视图先后承载不同元素，事件名不变而 identifier 变了。
        // 旧槽位若留着，视图下次进入可视区时会带着上一个元素的属性再发一次
        NSMutableArray<NSString *> *staleSlots = nil;
        for (NSString *key in nodes) {
            if ([key isEqualToString:slot] || ![nodes[key].eventName isEqualToString:eventName]) {
                continue;
            }
            staleSlots = staleSlots ?: [NSMutableArray array];
            [staleSlots addObject:key];
        }
        for (NSString *key in staleSlots) {
            nodes[key].recheckToken += 1;
            [nodes removeObjectForKey:key];
        }

        // 列表刷新会对可见元素原样重标一次，内容没变就保留原节点，
        // 否则曝光状态被重置，下一个检测周期必然多发一次
        if ([nodes[slot] matchesEventName:eventName attributes:attributes config:nodeConfig]) {
            [[GrowingViewImpression sharedInstance] addImpressionView:self];
            return;
        }

        GrowingViewImpressionNode *node = [[GrowingViewImpressionNode alloc] init];
        node.eventName = eventName;
        node.attributes = attributes;
        node.identifier = identifier;
        node.config = nodeConfig;

        nodes[slot].recheckToken += 1;
        nodes[slot] = node;
        [[GrowingViewImpression sharedInstance] addImpressionView:self];
    }];
}

- (void)growingViewImpUpdateAttributes:(NSDictionary<NSString *, id> *)attributes identifier:(NSString *)identifier {
    [GrowingDispatchManager dispatchInMainThread:^{
        NSString *slot = identifier.length > 0 ? identifier : kGrowingViewImpDefaultSlot;
        GrowingViewImpressionNode *node = self.growingViewImpNodes[slot];
        if (!node) {
            GIOLogWarn(@"[GrowingViewImpression] 槽位 %@ 尚未标记，属性更新被忽略", slot);
            return;
        }
        node.attributes = attributes;
    }];
}

- (void)growingViewImpUnmarkAll {
    [GrowingDispatchManager dispatchInMainThread:^{
        for (GrowingViewImpressionNode *node in self.growingViewImpNodes.allValues) {
            node.recheckToken += 1;
        }
        objc_setAssociatedObject(self, @selector(growingViewImpNodes), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[GrowingViewImpression sharedInstance] removeImpressionView:self];
    }];
}

- (void)growingViewImpUnmarkSlot:(NSString *)identifier {
    if (identifier.length == 0) {
        return;
    }

    [GrowingDispatchManager dispatchInMainThread:^{
        NSMutableDictionary<NSString *, GrowingViewImpressionNode *> *nodes = self.growingViewImpNodes;
        nodes[identifier].recheckToken += 1;
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
