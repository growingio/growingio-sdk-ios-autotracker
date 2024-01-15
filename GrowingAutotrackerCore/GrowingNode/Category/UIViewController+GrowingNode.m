//
//  UIViewController+GrowingNode.m
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

#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIViewController+GrowingNode.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingULApplication.h"

@implementation UIViewController (GrowingNode)

- (CGRect)growingNodeFrame {
    CGRect rect = self.view.growingNodeFrame;
    // 是否全屏显示
    // 当ViewController全屏显示时，如果被NavigationController包裹,其frame大小高度应减去导航栏的高度
    BOOL isFullScreenShow =
        CGPointEqualToPoint(rect.origin, CGPointMake(0, 0)) &&
        CGSizeEqualToSize(rect.size, UIScreen.mainScreen.bounds.size);
    if (isFullScreenShow) {
        UIViewController *parentVC = self.parentViewController;
        CGFloat statusBarHeight = [[GrowingULApplication sharedApplication] growingul_statusBarHeight];
        while (parentVC) {
            if ([parentVC isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navi = (UINavigationController *)parentVC;
                if (!navi.navigationBar.window || navi.navigationBar.hidden || navi.navigationBar.alpha < 0.001 ||
                    !navi.navigationBar.superview) {
                    break;
                }
                rect.origin.y += (navi.navigationBar.frame.size.height + statusBarHeight);
                rect.size.height -= (navi.navigationBar.frame.size.height + statusBarHeight);
            }

            if ([parentVC isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabbarvc = (UITabBarController *)parentVC;
                if (!tabbarvc.tabBar.window || tabbarvc.tabBar.hidden || tabbarvc.tabBar.alpha < 0.001 ||
                    !tabbarvc.tabBar.superview) {
                    break;
                    ;
                }
                rect.size.height -= tabbarvc.tabBar.frame.size.height;
            }
            parentVC = parentVC.parentViewController;
        }
    }
    return rect;
}

- (id<GrowingNode>)growingNodeParent {
    if (![self isViewLoaded]) {
        return nil;
    }
    // UIResponder关系为
    // UIApplication/UIWindowScene/_UIAlertControllerShimPresenterWindow/UITransitionView/UIAlertController/AlertView
    // UIAlertController的presentingViewController 为 UIApplicationRotationFollowingController
    // 取最上层的视图控制器，则无法使用上面两种方式。
    if ([self isKindOfClass:UIAlertController.class]) {
        return [[GrowingPageManager sharedInstance] currentPage].carrier;
    } else {
        return self.parentViewController;
    }
}

#pragma mark - xpath
- (NSInteger)growingNodeKeyIndex {
    NSString *classString = NSStringFromClass(self.class);
    NSArray *subResponder = [(UIViewController *)self parentViewController].childViewControllers;

    NSInteger count = 0;
    NSInteger index = -1;
    for (UIResponder *res in subResponder) {
        if ([classString isEqualToString:NSStringFromClass(res.class)]) {
            count++;
        }
        if (res == self) {
            index = count - 1;
        }
    }
    // 单个 UIViewController 拼接路径，不需要序号
    if (![self isKindOfClass:UIAlertController.class] && count == 1) {
        index = -1;
    }
    return index;
}

- (NSString *)growingNodeSubPath {
    return NSStringFromClass(self.class);
}

- (NSString *)growingNodeSubIndex {
    NSInteger index = [self growingNodeKeyIndex];
    return index < 0 ? @"0" : [NSString stringWithFormat:@"%ld", (long)index];
}

- (NSString *)growingNodeSubSimilarIndex {
    return [self growingNodeSubIndex];
}

@end
