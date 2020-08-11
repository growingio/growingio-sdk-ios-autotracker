//
//  GrowingTableAndCell.m
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

#import "GrowingAttributesConst.h"
#import "UITableView+GrowingAutoTrack.h"
#import "UITableView+GrowingNode.h"
#import "UIView+GrowingHelper.h"

@implementation UITableView (GrowingNode)

- (id)growingNodeAttribute:(NSString *)attrbute {
    if (attrbute == GrowingAttributeIsHorizontalTableKey) {
        CGRect rect = CGRectMake(0, 0, 10, 20);
        rect = [self convertRect:rect toView:self.window];
        if (rect.size.width > rect.size.height) {
            // ignore the improportional scale
            return GrowingAttributeReturnYESKey;
        }
    }
    return nil;
}


- (id)growingNodeAttribute:(NSString *)attrbute forChild:(id<GrowingNode>)node
{
    if (attrbute == GrowingAttributeIsWithinRowOfTableKey)
    {
        // TODO: create cells
//        if ([self.growingHook_allCreatedCells containsObject:node])
//        {
//            return GrowingAttributeReturnYESKey;
//        }
    }
    return nil;
}

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    // 对于collectionView我们仅需要返回可见cell
    NSMutableArray *childs = [NSMutableArray array];
    [childs addObjectsFromArray:self.visibleCells];
    return childs;
}

@end

@implementation UITableViewCell (GrowingNode)

- (NSInteger)growingNodeKeyIndex {
    return [self growingNodeIndexPath].row;
}

- (NSIndexPath *)growingNodeIndexPath {
    UITableView *tableView = (UITableView *)[self superview];
    do {
        if ([tableView isKindOfClass:UITableView.class]) {
            NSIndexPath *indexPath = [tableView indexPathForCell:self];
            return indexPath;
        }
    } while ((tableView = (UITableView *)[tableView superview]));
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
    }
    return [super growingNodeSubPath];
}


- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    // 对于collectionView我们仅需要返回可见cell
    UIView * cell = self;
    NSMutableArray *childs = [NSMutableArray array];
    for (UIView * v in cell.subviews) {
        if (v == self.selectedBackgroundView) {
            continue;
        } else {
            [childs addObject:v];
        }
    }
    return childs;
}

- (BOOL)growingNodeUserInteraction {
    return YES;
}

- (NSString *)growingNodeName {
    __kindof UIView *curView = self;
    UITableView *tableView = nil;
    while (curView != nil) {
        if ([curView isKindOfClass:[UITableView class]]) {
            tableView = curView;
            break;
        }
        curView = curView.superview;
    }
    if (tableView == nil) {
        return @"列表项";
    }
    return
        [tableView growingNodeAttribute:GrowingAttributeIsHorizontalTableKey] ==
                GrowingAttributeReturnYESKey
            ? @"横滑列表项"
            : @"竖滑列表项";
}

- (BOOL)growingNodeDonotCircle {
    return [super growingNodeDonotCircle];
}


@end
