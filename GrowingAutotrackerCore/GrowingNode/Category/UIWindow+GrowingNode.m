//
//  UIWindow+GrowingNode.m
//  GrowingAnalytics
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

#import "GrowingAutotrackerCore/GrowingNode/Category/UIWindow+GrowingNode.h"

@implementation UIWindow (GrowingNode)

- (id<GrowingNode>)growingNodeParent {
    return self.superview;
}

- (CGRect)growingNodeFrame {
    return CGRectZero;
}

- (BOOL)growingWindowNodeIsInvisible {
    return self.alpha <= 0.001 || self.hidden;
}

- (BOOL)growingNodeDonotCircle {
    return [self growingWindowNodeIsInvisible];
}

- (BOOL)growingViewUserInteraction {
    return NO;
}

@end
