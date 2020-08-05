//
//  UIApplication+GrowingHelper.m
//  GrowingTracker
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


#import <UIKit/UIKit.h>
#import "UIWindow+GrowingHelper.h"
#import "GrowingWindow.h"
@implementation UIApplication (GrowingHelper)

- (NSArray<UIWindow*>*)growingHelper_allWindows {
    NSArray * array = [self windows];
    UIWindow * keyWindow = [self keyWindow];
    
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

- (NSArray<UIWindow*>*)growingHelper_allWindowsSortedByWindowLevel {
    NSArray *windows = [[UIApplication sharedApplication] growingHelper_allWindows];
    
    NSMutableArray *sortedWindows = [NSMutableArray arrayWithArray:windows];
    [sortedWindows sortWithOptions:NSSortStable
                   usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UIWindow * win1 = obj1;
        UIWindow * win2 = obj2;
        if (win1.windowLevel < win2.windowLevel) {
            return NSOrderedAscending;
        }
        
        if (win1.windowLevel > win2.windowLevel) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    return sortedWindows;
}

- (NSArray<UIWindow*>*)growingHelper_allWindowsWithoutGrowingWindow {
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:self.growingHelper_allWindows];
    for (NSInteger i = windows.count - 1; i >= 0 ; i --) {
        UIWindow *win = windows[i];
        
        if ([win isKindOfClass:[GrowingWindow class]]) {
            [windows removeObjectAtIndex:i];
        }
    }
    return windows;
}

@end
