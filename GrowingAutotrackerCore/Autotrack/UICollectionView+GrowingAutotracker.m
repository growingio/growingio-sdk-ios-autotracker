//
//  UICollectionView+GrowingAutoTrack.m
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

#import "GrowingAutotrackerCore/Autotrack/UICollectionView+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewClickProvider.h"
#import "GrowingULSwizzle.h"
#import "GrowingULSwizzler.h"

@implementation UICollectionView (GrowingAutotracker)

- (void)growing_setDelegate:(id<UICollectionViewDelegate>)delegate {
    SEL selector = @selector(collectionView:didSelectItemAtIndexPath:);
    id<UICollectionViewDelegate> realDelegate = [GrowingULSwizzle realDelegate:delegate toSelector:selector];
    Class class = realDelegate.class;
    if ([GrowingULSwizzle realDelegateClass:class respondsToSelector:selector]) {
        static const void *key = &key;
        GrowingULSwizzleInstanceMethod(class,
                                       selector,
                                       GUSWReturnType(void),
                                       GUSWArguments(UICollectionView * collectionView, NSIndexPath * indexPath),
                                       GUSWReplacement({
                                           if (collectionView && indexPath) {
                                               UICollectionViewCell *cell =
                                                   [collectionView cellForItemAtIndexPath:indexPath];
                                               if (cell) {
                                                   [GrowingViewClickProvider viewOnClick:cell];
                                               }
                                           }
                                           GUSWCallOriginal(collectionView, indexPath);
                                       }),
                                       GrowingULSwizzleModeOncePerClassAndSuperclasses,
                                       key);
    }

    [self growing_setDelegate:delegate];
}

@end
