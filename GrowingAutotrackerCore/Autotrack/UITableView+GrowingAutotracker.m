//
//  UITableView+GrowingAutoTrack.m
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

#import "GrowingAutotrackerCore/Autotrack/UITableView+GrowingAutotracker.h"
#import "GrowingTrackerCore/Swizzle/GrowingSwizzle.h"
#import "GrowingTrackerCore/Swizzle/GrowingSwizzler.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewClickProvider.h"

@implementation UITableView (GrowingAutotracker)

- (void)growing_setDelegate:(id<UITableViewDelegate>)delegate {
    SEL selector = @selector(tableView:didSelectRowAtIndexPath:);
    id<UITableViewDelegate> realDelegate = [GrowingSwizzler realDelegate:delegate toSelector:selector];
    Class class = realDelegate.class;
    if ([GrowingSwizzler realDelegateClass:class respondsToSelector:selector]) {

        void (^didSelectBlock)(id, SEL, id, id) = ^(id view, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
                                                 
            if (tableView && indexPath) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    [GrowingViewClickProvider viewOnClick:cell];
                }
            }
        };
        [GrowingSwizzler growing_swizzleSelector:selector
                                         onClass:class
                                       withBlock:didSelectBlock
                                           named:@"growing_tableView_didSelect"];
    }
    
    [self growing_setDelegate:delegate];
}

@end

