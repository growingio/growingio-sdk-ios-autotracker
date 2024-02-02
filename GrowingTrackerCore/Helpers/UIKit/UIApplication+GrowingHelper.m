//
//  UIApplication+GrowingHelper.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 12/3/15.
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

#import "GrowingTargetConditionals.h"

#if Growing_USE_UIKIT
#import "GrowingTrackerCore/GrowingWindow.h"
#import "GrowingTrackerCore/Helpers/UIKit/UIApplication+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/UIKit/UIWindow+GrowingHelper.h"

@implementation UIApplication (GrowingHelper)

/// 当使用UIAlertView时，系统会创建一个_UIAlertControllerShimPresenterWindow
/// 并且调用[self windows]时，该数组中没有这个_UIAlertControllerShimPresenterWindow
/// 我们需要将其加入数组中
- (NSArray<UIWindow *> *)growingHelper_allWindows {
    NSArray *array = [self windows];
    UIWindow *keyWindow = [self keyWindow];

    if (!keyWindow) {
        return array;
    }

    if (!array.count) {
        return @[keyWindow];
    }

    if ([array containsObject:keyWindow]) {
        return array;
    }

    return [array arrayByAddingObject:keyWindow];
}

- (NSArray<UIWindow *> *)growingHelper_allWindowsWithoutGrowingWindow {
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:self.growingHelper_allWindows];
    for (NSInteger i = windows.count - 1; i >= 0; i--) {
        UIWindow *win = windows[i];

        if ([win isKindOfClass:[GrowingWindow class]]) {
            [windows removeObjectAtIndex:i];
        }
    }
    return windows;
}

@end
#endif
