//
//  GrowingNodeItem.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 16/1/6.
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

@protocol GrowingNode;

@interface GrowingNodeItemComponent : NSObject

+ (NSInteger)indexNotDefine;
+ (NSInteger)indexNotFound;

@property (nonatomic, copy) NSString  *pathComponent;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isKeyIndex;
@property (nonatomic, copy) NSString  *userDefinedTag;
@property (nonatomic, copy) NSString  *growingAccessibilityID;

- (instancetype)initWithPath:(NSString*)path;
- (instancetype)initWithPath:(NSString*)path index:(NSInteger)index;
- (instancetype)initWithPath:(NSString*)path index:(NSInteger)index isKeyIndex:(BOOL)isKeyIndex;

@end

@interface GrowingNodeItem : NSObject

@property (nonatomic, retain) id<GrowingNode> node;
@property (nonatomic, retain) NSArray<GrowingNodeItemComponent*> *pathComponents;

- (instancetype)initWithNode:(id<GrowingNode>)node pathComponents:(NSArray<GrowingNodeItemComponent*>*)pathComponents;

@end


#define GrowingNodeForeachMacroOne(PATH)                                                \
[[GrowingNodeItemComponent alloc] initWithPath:PATH]

#define GrowingNodeForeachMacroTwo(PATH,INDEX)                                          \
[[GrowingNodeItemComponent alloc] initWithPath:PATH index:INDEX]

#define GrowingNodeForeachMacroThree(PATH,INDEX,ISKEYINDEX)                             \
[[GrowingNodeItemComponent alloc] initWithPath:PATH index:INDEX isKeyIndex:ISKEYINDEX]

#define GrowingNodeForeach(index,var)                                                   \
metamacro_if_eq(1,metamacro_argcount var)                                   \
(GrowingNodeForeachMacroOne var)                                            \
(GrowingNodeForeach2(index,var))                                            \
,

#define GrowingNodeForeach2(index,var)                                                  \
metamacro_if_eq(2,metamacro_argcount var)                                   \
(GrowingNodeForeachMacroTwo var)                                            \
(GrowingNodeForeachMacroThree var)                                          \

#define GrowingNodePath(...)                                                            \
[[GrowingNodeItem alloc] initWithNode:metamacro_head(__VA_ARGS__) pathComponents:@[ metamacro_foreach(GrowingNodeForeach, ,metamacro_tail(__VA_ARGS__)) ]]

/* GrowingNodePath usage:
 * GrowingNodePath ( growingNode,
 *                  (pc1_path, pc1_index, pc1_isKeyIndex)
 *                  (pc2_path, pc2_index, pc2_isKeyIndex) ... )
 * note that pc?_isKeyIndex can be absent
 * note that pc?_index and pc?_isKeyIndex can be absent
 */
