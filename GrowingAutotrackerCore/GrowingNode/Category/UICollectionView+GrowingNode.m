//
//  GrowingCollectionViewAndCell.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/8/27.
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

#import <pthread.h>
#import "GrowingAutotrackerCore/GrowingNode/Category/UICollectionView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

@implementation UICollectionView (GrowingNode)

- (NSArray<id<GrowingNode>> *)growingNodeChilds {
    // 对于collectionView我们仅需要返回可见cell
    NSMutableArray *children = [NSMutableArray array];
    if (@available(iOS 9.0, *)) {
        NSArray *headers = [self visibleSupplementaryViewsOfKind:UICollectionElementKindSectionHeader];
        NSArray *footers = [self visibleSupplementaryViewsOfKind:UICollectionElementKindSectionFooter];
        [children addObjectsFromArray:headers];
        [children addObjectsFromArray:footers];
    }
    [children addObjectsFromArray:self.visibleCells];
    return children;
}

- (NSString *)growingViewContent {
    return nil;
}

@end

@implementation UICollectionViewCell (GrowingNode)

- (NSInteger)growingNodeKeyIndex {
    return self.growingNodeIndexPath.row;
}

- (NSIndexPath *)growingNodeIndexPath {
    UICollectionView *collectionView = (UICollectionView *)[self superview];
    if ([collectionView isKindOfClass:UICollectionView.class]) {
        NSIndexPath *indexPath = [collectionView indexPathForCell:self];
        return indexPath;
    }
    return nil;
}

- (NSString *)growingNodeSubPath {
    NSIndexPath *indexpath = [self growingNodeIndexPath];
    if (indexpath) {
        return [NSString stringWithFormat:@"Section/%@", NSStringFromClass(self.class)];
    }
    return [super growingNodeSubPath];
}

- (NSString *)growingNodeSubIndex {
    NSIndexPath *indexpath = [self growingNodeIndexPath];
    if (indexpath) {
        return [NSString stringWithFormat:@"%ld/%ld", (long)indexpath.section, (long)indexpath.row];
    }
    return [super growingNodeSubIndex];
}

- (NSString *)growingNodeSubSimilarIndex {
    NSIndexPath *indexpath = [self growingNodeIndexPath];
    if (indexpath) {
        return [NSString stringWithFormat:@"%ld/-", (long)indexpath.section];
    }
    return [super growingNodeSubIndex];
}

- (BOOL)growingViewUserInteraction {
    return YES;
}

@end
