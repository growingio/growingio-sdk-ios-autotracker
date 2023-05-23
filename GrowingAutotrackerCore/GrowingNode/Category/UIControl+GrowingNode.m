//
//  UIButton+Growing.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 5/7/15.
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

#import "GrowingAutotrackerCore/GrowingNode/Category/UIControl+GrowingNode.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Public/GrowingBaseEvent.h"

@implementation UIControl(Growing)

- (BOOL)growingViewUserInteraction
{
    return self.enabled && self.allTargets.count > 0;
}

- (NSString *)growingViewContent
{
    NSMutableArray<UIView*> *unvisted = [[NSMutableArray alloc] init];
    
    if (self.subviews.count) {
        [unvisted addObjectsFromArray:self.subviews];
    } else {
        UIView *container = self.superview;
        if (container) {
            for (UIView *view in container.subviews) {
                if (view == self) break;
                if (CGRectContainsRect(self.frame, view.frame)) {
                    [unvisted addObject:view];
                }
            }
        }
    }

    // TODO: Improve the logic and performance using DFS
    while (unvisted.count) {
        UIView *current = unvisted.firstObject;
        [unvisted removeObject:current];
        if ([current isKindOfClass:[UILabel class]] && [current growingViewContent].length) {
            return [current growingViewContent];
        }
        if ([current isKindOfClass:[UIImageView class]] && [(UIImageView *)current growingViewContent].length) {
            return [(UIImageView *)current growingViewContent];
        }
        if (current.subviews.count) {
            unvisted = [[current.subviews arrayByAddingObjectsFromArray:unvisted] mutableCopy];
        }
    }

    return nil;
}

@end
