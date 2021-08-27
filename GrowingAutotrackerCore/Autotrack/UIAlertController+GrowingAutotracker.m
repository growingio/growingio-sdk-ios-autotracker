//
//  UIAlertController+GrowingAutoTrack.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/30.
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


#import "UIAlertController+GrowingAutotracker.h"
#import "NSObject+GrowingIvarHelper.h"
#import "GrowingSwizzle.h"
#import "UIView+GrowingNode.h"
#import "GrowingEventManager.h"
#import "GrowingViewClickProvider.h"

@implementation UIAlertController (GrowingAutotracker)

- (void)growing_dismissAnimated:(BOOL)animated triggeringAction:(UIAlertAction *)action {
    
    [self sendClickEventForAction:action];

    [self growing_dismissAnimated:animated triggeringAction:action];
}

- (void)growing_dismissAnimated:(BOOL)animated
               triggeringAction:(UIAlertAction *)action
  triggeredByPopoverDimmingView:(UIView *)view
              dismissCompletion:(id)completion {
    
    [self sendClickEventForAction:action];
    
    [self growing_dismissAnimated:animated
                 triggeringAction:action
    triggeredByPopoverDimmingView:view
                dismissCompletion:completion];
}

- (void)sendClickEventForAction:(UIAlertAction *)action {
    NSMapTable *allButton = [self growing_allActionViews];
    for (UIView *btn in allButton.keyEnumerator) {
        if (action == [UIAlertController growing_actionForActionView:btn]) {
            [GrowingViewClickProvider viewOnClick:btn];
            break;
        }
    }
}

+ (UIAlertAction *)growing_actionForActionView:(UIView*)actionView {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *viewSelectorString = [NSString stringWithFormat:@"a%@ion%@w", @"ct", @"Vie"];
    SEL selector = NSSelectorFromString(viewSelectorString);
    if ([actionView respondsToSelector:selector]) {
        actionView = [actionView performSelector:selector];
    }
#pragma clang diagnostic pop
    UIAlertAction *action = nil;
    if ([actionView respondsToSelector:@selector(action)])
    {
        action =[actionView performSelector:@selector(action)];
    }
    return action;
}

- (NSMapTable *)growing_allActionViews {
    UICollectionView *collectionView = [self growing_collectionView];
    NSMapTable *retMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory
                                                    capacity:4];
    // ios9以及以下
    if (collectionView) {
        [[collectionView indexPathsForVisibleItems] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj,
                                                                                 NSUInteger idx,
                                                                                 BOOL * _Nonnull stop) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:obj];
            if (cell) {
                [retMap setObject:[NSNumber numberWithInteger:obj.row] forKey:cell];
            }
        }];
    } else { //  ios10以及以上
        NSArray *views = nil;
        if ([self.view growingHelper_getIvar:"_actionViews" outObj:&views]) {
            [views enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [retMap setObject:[NSNumber numberWithInteger:idx] forKey:obj];
            }];
        }
    }
    return retMap;
}

- (UICollectionView*)growing_collectionView {
    return [self growing_alertViewCollectionView:self.view];
}

- (UICollectionView*)growing_alertViewCollectionView:(UIView*)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UICollectionView class]]) {
            return (UICollectionView*)subview;
        } else {
            UICollectionView *ret = [self growing_alertViewCollectionView:subview];
            if (ret) {
                return ret;
            }
        }
    }
    return nil;
}

@end
