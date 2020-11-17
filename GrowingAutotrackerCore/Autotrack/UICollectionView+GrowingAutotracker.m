//
//  UICollectionView+GrowingAutoTrack.m
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


#import "UICollectionView+GrowingAutotracker.h"
#import "GrowingSwizzle.h"
#import "GrowingSwizzler.h"
#import "UIView+GrowingNode.h"
#import "GrowingViewClickProvider.h"
@implementation UICollectionView (GrowingAutotracker)

- (void)growing_setDelegate:(id<UICollectionViewDelegate>)delegate {
    
    if ([delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        
        void (^didSelectItemBlock)(id, SEL, id, id) = ^(id view, SEL command, UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                 
            if (collectionView && indexPath) {
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                [GrowingViewClickProvider viewOnClick:cell];
//                [GrowingClickEvent sendEventWithNode:cell
//                                        andEventType:GrowingEventTypeRowSelected];
            }
        };
        
        [GrowingSwizzler growing_swizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:)
                                         onClass:delegate.class
                                       withBlock:didSelectItemBlock
                                           named:@"growing_collectionView_didSelect"];
    }
    
    [self growing_setDelegate:delegate];
}

@end
