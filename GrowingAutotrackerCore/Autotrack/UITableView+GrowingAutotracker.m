//
//  UITableView+GrowingAutoTrack.m
//  GrowingAutoTracker
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


#import "UITableView+GrowingAutotracker.h"
#import "GrowingSwizzle.h"
#import "GrowingSwizzler.h"
#import "UIView+GrowingNode.h"
#import "GrowingViewClickProvider.h"

@implementation UITableView (GrowingAutotracker)

- (void)growing_setDelegate:(id<UITableViewDelegate>)delegate {
    SEL selector = @selector(tableView:didSelectRowAtIndexPath:);
    id realDelegate = [GrowingSwizzler realDelegateFromSelector:selector proxy:delegate];
    if ([realDelegate respondsToSelector:selector]) {
        
        void (^didSelectBlock)(id, SEL, id, id) = ^(id view, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
                                                 
            if (tableView && indexPath) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [GrowingViewClickProvider viewOnClick:cell];
            }
        };
        [GrowingSwizzler growing_swizzleSelector:selector
                                         onClass:[realDelegate class]
                                       withBlock:didSelectBlock
                                           named:@"growing_tableView_didSelect"];
    }
    
    [self growing_setDelegate:delegate];
}

@end

