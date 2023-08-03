//
//  GrowingTableAndCell.m
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

#import "GrowingAutotrackerCore/Autotrack/UITableView+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UITableView+GrowingNode.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

@implementation UITableView (GrowingNode)

- (NSArray<id<GrowingNode>> *)growingNodeChilds {
    NSMutableArray *childs = [NSMutableArray array];
    [childs addObjectsFromArray:self.visibleCells];
    
    NSArray<NSIndexPath *> *indexPaths = self.indexPathsForVisibleRows;
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths) {
        [indexSet addIndex:indexPath.section];
    }
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
        UITableViewHeaderFooterView *headerView = [self headerViewForSection:section];
        if (headerView) {
            [childs addObject:headerView];
        }
        UITableViewHeaderFooterView *footerView = [self footerViewForSection:section];
        if (footerView) {
            [childs addObject:footerView];
        }
    }];
    
    if (self.tableFooterView) {
        [childs addObject:self.tableFooterView];
    }
    if (self.tableHeaderView) {
        [childs addObject:self.tableHeaderView];
    }
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
    if (self.growingUniqueTag.length > 0) {
        return self.growingUniqueTag;
    }

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

- (NSArray<id<GrowingNode>> *)growingNodeChilds {
    UIView *cell = self;
    NSMutableArray *childs = [NSMutableArray array];
    for (UIView *v in cell.subviews) {
        if (v == self.selectedBackgroundView) {
            continue;
        } else {
            [childs addObject:v];
        }
    }
    return childs;
}

- (BOOL)growingViewUserInteraction {
    return YES;
}

@end

@implementation UITableViewHeaderFooterView (GrowingNode)

- (NSString *)growingNodeSubIndex {
    UIView *view = self;
    do {
        view = view.superview;
    } while (view && ![view isKindOfClass:[UITableView class]]);

    if (view) {
        UITableView *tableView = (UITableView *)view;
        for (NSInteger i = 0; i < tableView.numberOfSections; i++) {
            if (self == [tableView headerViewForSection:i]) {
                return [NSString stringWithFormat:@"%ld", (long)i];
            }
            if (self == [tableView footerViewForSection:i]) {
                return [NSString stringWithFormat:@"%ld", (long)i];
            }
        }
    }

    return [super growingNodeSubIndex];
}

@end
