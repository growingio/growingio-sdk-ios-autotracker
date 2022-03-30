//
//  UIApplication+GrowingAutoTrack.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/23.
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

#import "GrowingTrackerCore/Manager/GrowingApplicationEventManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Event/GrowingNodeProtocol.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingNodeHelper.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewClickProvider.h"
#import "GrowingAutotrackerCore/Autotrack/UIApplication+GrowingAutotracker.h"

@implementation UIApplication (GrowingAutotracker)

- (void)growing_sendEvent:(UIEvent *)event {
    [self growing_sendEvent:event];
    //触摸 滑动都会在这里触发
    [[GrowingApplicationEventManager sharedInstance] dispatchApplicationEventSendEvent:event];
}

- (BOOL)growing_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    BOOL result = YES;
    // 切换 tab，采集切换之后的页面信息，所以需要先调用 growing_sendAction 完成切换
    BOOL isTabBar = [target isKindOfClass:UITabBar.class] || [target isKindOfClass:UITabBarController.class];

    if (isTabBar) {
        result = [self growing_sendAction:action to:target from:sender forEvent:event];
    }

    @try {
        // 捕获异常，比如 UITextMultiTapRecognizer 没有实现GrowingNode 相关方法, 如：growingTimeIntervalForLastClick
        [self growing_trackAction:action to:target from:sender forEvent:event];

    } @catch (NSException *exception) {
        GIOLogError(@"%@ catch exception = %@", self, exception);
    }

    if (!isTabBar) {
        result = [self growing_sendAction:action to:target from:sender forEvent:event];
    }

    return result;
}

- (void)growing_trackAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    if ([sender isKindOfClass:UITabBarItem.class] || [sender isKindOfClass:UIBarButtonItem.class] ||
        [sender isKindOfClass:UISegmentedControl.class]) {
        return;
    }

    NSObject<GrowingNode> *node = (NSObject<GrowingNode> *)sender;

    if ([sender isKindOfClass:UISwitch.class] || [sender isKindOfClass:UIStepper.class] ||
        [sender isKindOfClass:UIPageControl.class]) {
        [GrowingViewClickProvider viewOnClick:(UIView*)node];
    } else if ([event isKindOfClass:[UIEvent class]] && event.type == UIEventTypeTouches &&
               [[[event allTouches] anyObject] phase] == UITouchPhaseEnded) {
        [GrowingViewClickProvider viewOnClick:(UIView*)node];
    }

    [[GrowingApplicationEventManager sharedInstance] dispatchApplicationEventSendAction:action
                                                                                     to:target
                                                                                   from:sender
                                                                               forEvent:event];
}

@end
