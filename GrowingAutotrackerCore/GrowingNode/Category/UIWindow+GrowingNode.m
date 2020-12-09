//
//  UIWindow+GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/8/31.
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


#import "GrowingPageManager.h"
#import "UIWindow+GrowingNode.h"
#import "GrowingNode.h"

@implementation UIWindow (GrowingNode)

- (id<GrowingNode>)growingNodeParent {
    if (self.superview) {
        return self.superview;
    } else {
        return nil;
    }
}

- (CGRect)growingNodeFrame {
    return CGRectZero;
}

- (BOOL)growingWindowNodeIsInvisiable {
    return self.alpha <= 0.001 || self.hidden || [self growingNodeIsBadNode];
}

- (BOOL)growingNodeDonotCircle {
    return [self growingWindowNodeIsInvisiable];
}

- (BOOL)growingViewUserInteraction {
    return NO;
}

- (NSString *)growingNodeName {
    return @"页面";
}

- (NSString *)growingViewContent {
    return self.accessibilityLabel;
}

- (NSDictionary *)growingNodeDataDict {
    return nil;
}

- (UIWindow *)growingNodeWindow {
    return self;
}

@end
