//
//  UINavigationController+GrowingNode.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/9/10.
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

#import <objc/runtime.h>
#import "GrowingAutotrackerCore/GrowingNode/Category/UIApplication+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UINavigationController+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"

@implementation UINavigationController (GrowingNode)

- (CGRect)growingNodeFrame {
    CGRect rect = self.view.growingNodeFrame;
    BOOL isFullScreenShow =
        CGPointEqualToPoint(rect.origin, CGPointMake(0, 0)) &&
        CGSizeEqualToSize(rect.size, [UIApplication sharedApplication].growingMainWindow.bounds.size);
    if (isFullScreenShow && self.parentViewController &&
        [self.parentViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarvc = (UITabBarController *)self.parentViewController;
        rect.size.height -= tabbarvc.tabBar.frame.size.height;
    }

    return rect;
}

@end
