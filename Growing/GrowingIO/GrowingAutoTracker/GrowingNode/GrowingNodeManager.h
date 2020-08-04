//
//  GrowingXPathManager.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/9/10.
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
#import <UIKit/UIKit.h>
#import "GrowingNode.h"

@interface GrowingNodeManagerEnumerateContext : NSObject

- (void)stop;
- (void)skipThisChilds;
- (void)onNodeFinish:(void(^)(id<GrowingNode> node))finishBlock;

- (NSString*)xpath;
- (NSInteger)nodeKeyIndex;

- (NSArray<id<GrowingNode>>*)allNodes;
- (id<GrowingNode>)startNode;

- (id)attributeValueForKey:(NSString*)key;

@end

@interface GrowingNodeManager : NSObject

+ (id)recursiveAttributeValueOfNode:(id<GrowingNode>)aNode forKey:(NSString *)key;

- (id<GrowingNode>)nodeAtFirst;

- (instancetype)initWithNodeAndParent:(id<GrowingNode>)aNode
                           checkBlock:(BOOL(^)(id<GrowingNode> node))checkBlock;

@property (nonatomic, readonly) NSInteger maxKeyIndexCount;

- (void)enumerateChildrenUsingBlock:(void (^)(id<GrowingNode> aNode,
                                              GrowingNodeManagerEnumerateContext *context))block;

@end
