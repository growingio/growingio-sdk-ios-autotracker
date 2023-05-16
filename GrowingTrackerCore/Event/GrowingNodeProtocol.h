//
//  GrowingNodeProtocol.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2018/5/10.
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

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, GrowingElementEventCategory) {
    GrowingElementEventCategoryClick = 2,
    GrowingElementEventCategoryContentChange = 4,
    // submit事件, 一般由H5触发该事件
    GrowingElementEventCategorySubmit = 8,
    // If new entry is added, make sure to update
    // 'GrowingElementEventCategoryAll' as well
    GrowingElementEventCategoryAll = 15,
};

@protocol GrowingNode <NSObject>

@required
/// 一种class类型的node在其父视图中的唯一index位置，eg: UIButton[0] UIButton[1]
/// UILabel[0] UILabel[1]
@property (nonatomic, assign, readonly) NSInteger growingNodeKeyIndex;
/// 只有UITableView UICollectionView才有的indexpath
@property (nonatomic, assign, readonly) NSIndexPath * _Nullable growingNodeIndexPath;
/// 完整的xpath由各个node的subPath拼接而成
@property (nonatomic, copy, readonly) NSString * _Nullable growingNodeSubPath;
/// 当同一视图下相同class的两个node点击行为相似
/// 当不需要区分点击哪一个node，仅需要区分点击那种类型时，使用该属性
@property (nonatomic, copy, readonly) NSString * _Nullable growingNodeSubSimilarPath;

// 原始父节点
- (id <GrowingNode> _Nullable)growingNodeParent;
// 过滤后的子节点,例如UITableView子节点只需要是cell和footter
- (NSArray <id<GrowingNode>> * _Nullable)growingNodeChilds;
/// 不进行track
- (BOOL)growingNodeDonotTrack;

/// 不进行圈选
- (BOOL)growingNodeDonotCircle;

// 值
- (BOOL)growingNodeUserInteraction;

- (NSString * _Nullable)growingNodeContent;

- (NSDictionary * _Nullable)growingNodeDataDict;

- (CGRect)growingNodeFrame;

// 唯一标识某个view，客户可通过 growingAttributesUniqueTag 设置
- (NSString * _Nullable)growingNodeUniqueTag;

@optional

// GrowingElementEventCategoryAll if not implemented
- (GrowingElementEventCategory)growingNodeEligibleEventCategory;

- (BOOL)growingImpNodeIsVisible;

@end

#pragma mark GrowingAddEventContext

@protocol GrowingAddEventContext <NSObject>

@required

- (NSArray<id<GrowingNode>> *_Nullable)contextNodes;
- (id<GrowingNode> _Nullable)keyNode;

@end
