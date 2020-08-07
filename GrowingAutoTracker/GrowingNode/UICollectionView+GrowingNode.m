//
//  GrowingCollectionViewAndCell.m
//  GrowingTracker
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

#import "GrowingAttributesConst.h"
#import "UICollectionView+GrowingNode.h"
#import "UIView+GrowingHelper.h"
#import "UIView+GrowingNode.h"

@implementation UICollectionView (GrowingNode)

- (id)growingNodeAttribute:(NSString *)attrbute {
    if (attrbute == GrowingAttributeIsHorizontalTableKey) {
        if (self.alwaysBounceHorizontal && !self.alwaysBounceVertical) {
            return GrowingAttributeReturnYESKey;
        }
        CGSize boundSize = self.bounds.size;
        CGSize contentSize = self.contentSize;
        if (contentSize.height <= boundSize.height &&
            contentSize.width > boundSize.width) {
            return GrowingAttributeReturnYESKey;
        }
    }
    return nil;
}


- (id)growingNodeAttribute:(NSString *)attrbute forChild:(id<GrowingNode>)node
{
    if (attrbute == GrowingAttributeIsWithinRowOfTableKey)
    {
        // TODO: created cells
//        if ([self.growingHook_allCreatedCells containsObject:node])
//        {
//            return GrowingAttributeReturnYESKey;
//        }
//        if ([self.growingHook_allCreatedHeaders containsObject:node])
//        {
//            return GrowingAttributeReturnYESKey;
//        }
//        if ([self.growingHook_allCreatedFooters containsObject:node])
//        {
//            return GrowingAttributeReturnYESKey;
//        }
    }
    return nil;
}

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    // 对于collectionView我们仅需要返回可见cell
    NSMutableArray *childs = [NSMutableArray array];
    if (@available(iOS 9.0, *)) {
        NSArray *headers = [self visibleSupplementaryViewsOfKind:UICollectionElementKindSectionHeader];
        NSArray *footers = [self visibleSupplementaryViewsOfKind:UICollectionElementKindSectionFooter];
        NSMutableArray *childs = [NSMutableArray array];
        [childs addObjectsFromArray:headers];
        [childs addObjectsFromArray:footers];
    }
    [childs addObjectsFromArray:self.visibleCells];
    return childs;
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
        return
            [NSString stringWithFormat:@"Section[%ld]/%@[%ld]",
                                       (long)indexpath.section,
                                       NSStringFromClass(self.class),
                                       (long)indexpath.row];
        ;
    }
    return [super growingNodeSubPath];
}

- (NSString *)growingNodeSubSimilarPath {
    NSIndexPath *indexpath = [self growingNodeIndexPath];
    if (indexpath) {
        return
            [NSString stringWithFormat:@"Section[%ld]/%@[-]",
                                       (long)indexpath.section,
                                       NSStringFromClass(self.class)];
        ;
    }
    return [super growingNodeSubPath];
}

- (BOOL)growingNodeDonotCircle {
    return [super growingNodeDonotCircle];
}

- (BOOL)growingViewUserInteraction {
    return YES;
}

- (NSString *)growingNodeName {
    __kindof UIView *curView = self;
    UICollectionView *collecitonView = nil;
    while (curView) {
        if ([curView isKindOfClass:[UICollectionView class]]) {
            collecitonView = curView;
        }
        curView = curView.superview;
    }
    if (!collecitonView) {
        return @"列表";
    } else {
        CGSize contentsize = collecitonView.contentSize;
        CGSize frameSize = collecitonView.frame.size;
        BOOL w = ABS(contentsize.width - frameSize.width) > 1;
        BOOL h = ABS(contentsize.height - frameSize.height) > 1;
        if (w && !h) {
            return @"横滑列表项";
        } else if (h && !w) {
            return @"竖滑列表项";
        } else {
            return @"列表项";
        }
    }
}


@end

@interface UICollectionReusableView (GrowingNode) <GrowingNode>

@end

@implementation UICollectionReusableView (GrowingNode)

- (BOOL)growingNodeDonotCircle {
    return [super growingNodeDonotCircle];
}

@end
