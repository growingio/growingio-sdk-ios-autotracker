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

@protocol GrowingNode <NSObject>

@required
/// 一种class类型的node在其父视图中的唯一index位置，eg: UIButton[0] UIButton[1]
/// UILabel[0] UILabel[1]
@property (nonatomic, assign, readonly) NSInteger growingNodeKeyIndex;
/// 完整的xpath由各个node的subPath拼接而成
@property (nonatomic, copy, readonly) NSString *growingNodeSubPath;
/// 完整的xindex由各个node的subIndex拼接而成
@property (nonatomic, copy, readonly) NSString *growingNodeSubIndex;
/// 当同一视图下相同class的两个node点击行为相似
/// 当不需要区分点击哪一个node，仅需要区分点击那种类型时，使用该属性
@property (nonatomic, copy, readonly) NSString *growingNodeSubSimilarIndex;
/// 原始父节点
- (id<GrowingNode> _Nullable)growingNodeParent;
/// 不进行track
- (BOOL)growingNodeDonotTrack;
/// 不进行圈选
- (BOOL)growingNodeDonotCircle;
/// 是否可交互
- (BOOL)growingNodeUserInteraction;
/// 内容
- (NSString *_Nullable)growingNodeContent;
/// 在主window的frame
- (CGRect)growingNodeFrame;

@optional
/// 过滤后的子节点,例如UITableView子节点只需要是cell和footter
- (NSArray<id<GrowingNode>> *_Nullable)growingNodeChilds;

@end
