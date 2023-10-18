//
//  WKWebView+GrowingNode.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/18.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Event/GrowingNodeProtocol.h"
#import "Modules/Hybrid/WKWebView+GrowingNode.h"

@interface UIView (GrowingHybridModule) <GrowingNode>

@end

@implementation WKWebView (GrowingNode)

- (CGRect)growingNodeFrame {
    CGRect rect = [super growingNodeFrame];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets adjust = self.scrollView.adjustedContentInset;
        rect.origin.x += adjust.left;
        rect.origin.y += adjust.top;
        rect.size.width -= (adjust.left + adjust.right);
        rect.size.height -= (adjust.top + adjust.bottom);
    }
    return rect;
}

- (NSArray<id<GrowingNode>> *)growingNodeChilds {
    // 由于WKWebView具有内容视图，不再对其子元素进行遍历
    return nil;
}

@end
