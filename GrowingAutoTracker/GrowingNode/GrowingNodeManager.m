//
//  GrowingXPathManager.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/8/4.
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


#import "GrowingNodeManager.h"
#import "NSString+GrowingHelper.h"

#define parentIndexNull NSUIntegerMax

@interface GrowingNodeManagerEnumerateContext ()
@property (nonatomic, assign) BOOL stopAll;
@property (nonatomic, assign) BOOL stopChilds;
@property (nonatomic, retain) NSMutableArray *didEndNodeBlocks;
@property (nonatomic, retain) GrowingNodeManager *manager;

@end

@interface GrowingNodeManagerDataItem : NSObject
/// all indexes display as [n]
@property (nonatomic, copy) NSString *nodeFullPath;
/// the last indexes display as [-]
@property (nonatomic, copy) NSString *nodePatchedPath;
/// up-to-date key index until this node
@property (nonatomic, assign) NSInteger keyIndex;
    
@property (nonatomic, retain) id<GrowingNode> node;
@property (nonatomic, retain)
    NSArray<GrowingNodeItemComponent *> *pathComponents;

@end

@implementation GrowingNodeManagerDataItem
- (NSString *)description {
    return NSStringFromClass([self.node class]);
}
@end

@interface GrowingNodeManager ()

@property (nonatomic, retain) id<GrowingNode> enumItem;
@property (nonatomic, retain)
    NSMutableArray<GrowingNodeManagerDataItem *> *allItems;
@property (nonatomic, retain) NSMutableArray<id<GrowingNode>> *allNodes;
@property (nonatomic, assign) BOOL needUpdateAllItems;
@property (nonatomic, assign) NSInteger needUpdatePathIndex;

@property (nonatomic, copy) BOOL (^checkBlock)(id<GrowingNode> node);

@end

@implementation GrowingNodeManager

- (instancetype)init {
    return nil;
}
- (instancetype)initWithNodeAndParent:(id<GrowingNode>)aNode {
    return nil;
}

- (instancetype)initWithNodeAndParent:(id<GrowingNode>)aNode
                           checkBlock:(BOOL (^)(id<GrowingNode>))checkBlock {
    self = [super init];
    if (self) {
        self.allItems = [[NSMutableArray alloc] initWithCapacity:7];
        self.checkBlock = checkBlock;

        id<GrowingNode> curNode = aNode;
        while (curNode) {
            [self addNodeAtFront:curNode];
            curNode = [curNode growingNodeParent];
        }
        [self updateAllItems];

        if (!self.allItems.count) {
            return nil;
        }

        for (GrowingNodeManagerDataItem *item in self.allItems) {
            if (checkBlock && !checkBlock(item.node)) {
                return nil;
            }
        }
    }
    return self;
}

- (void)enumerateChildrenUsingBlock:
    (void (^)(id<GrowingNode>, GrowingNodeManagerEnumerateContext *))block {
    if (!block || self.allItems.count == 0) {
        return;
    }
    self.enumItem = self.allItems.lastObject.node;

    [self updateAllItems];
    
    [self _enumerateChildrenUsingBlock:block];
    self.enumItem = nil;
}

- (GrowingNodeManagerEnumerateContext*)_enumerateChildrenUsingBlock:(void (^)(id<GrowingNode>,
                                                                              GrowingNodeManagerEnumerateContext *))block
{
    NSUInteger endIndex = self.allItems.count - 1;
    GrowingNodeManagerDataItem *endItem = self.allItems[endIndex];

    GrowingNodeManagerEnumerateContext *context =
        [[GrowingNodeManagerEnumerateContext alloc] init];
    context.manager = self;
    block(endItem.node, context);
    
    if (context.stopAll || context.stopChilds) {
        return context;
    }
    
    NSArray *childs = [endItem.node growingNodeChilds];
    for (int i = 0; i < childs.count; i++) {
        id<GrowingNode> node = childs[i];
        if (!self.checkBlock || self.checkBlock(node)) {
            [self addNodeAtEnd:node];
            GrowingNodeManagerEnumerateContext *childContext = [self _enumerateChildrenUsingBlock:block];
            [self removeNodeItemAtEnd];
            
            if (childContext.stopAll) {
                context.stopAll = YES;
                return context;
            }
        }
    }
    
    return context;
}

+ (instancetype)recursiveAttributeValueOfNode:(id<GrowingNode>)aNode
                             forKey:(NSString *)key {
    GrowingNodeManager *manager = [[self alloc] initWithNodeAndParent:aNode];
    __block id attribute = nil;
    [manager enumerateChildrenUsingBlock:^(
                 id<GrowingNode> aNode,
                 GrowingNodeManagerEnumerateContext *context) {
        [context stop];
        attribute = [context attributeValueForKey:key];
    }];
    return attribute;
}

#pragma mark - 添加删除

// 添加
- (void)addNodeAtFront:(id<GrowingNode>)aNode {
    GrowingNodeManagerDataItem *item =
        [[GrowingNodeManagerDataItem alloc] init];
    item.node = aNode;
    [self.allItems insertObject:item atIndex:0];
    self.needUpdateAllItems = YES;
}

- (void)addNodeAtEnd:(id<GrowingNode>)aNode {
    [self updateAllItems];

    GrowingNodeManagerDataItem *dataItem =
        [[GrowingNodeManagerDataItem alloc] init];
    dataItem.node = aNode;
    [self.allItems addObject:dataItem];
    self.needUpdatePathIndex =
        MIN(self.needUpdatePathIndex, self.allItems.count - 1);
}

- (void)updateAllItemXpath {
    [self updateAllItemXpathByIndex:self.needUpdatePathIndex];
}

- (void)updateAllItemXpathByIndex:(NSUInteger)index {
    if (index >= self.allItems.count) {
        return;
    }
    self.needUpdatePathIndex = self.allItems.count;

    NSMutableString *lastNodeFullPath =
        [[NSMutableString alloc] initWithString:@""];
    NSMutableString *lastNodePatchedPath = [[NSMutableString alloc] initWithString:@""];
    NSInteger keyIndex = [GrowingNodeItemComponent indexNotDefine];
    if (index > 0) {
        NSString *lastItemFullPath = [self.allItems[index - 1] nodeFullPath];
        if (lastItemFullPath.length) {
            [lastNodeFullPath appendString:lastItemFullPath];
        }
        NSString *lastItemPatchedPath = [self.allItems[index - 1] nodePatchedPath];
        if (lastItemPatchedPath.length)
        {
            [lastNodePatchedPath appendString:lastItemPatchedPath];
        }
        keyIndex = [self.allItems[index - 1] keyIndex];
    }

    for (NSUInteger i = MAX(0, index); i < self.allItems.count; i++) {
        GrowingNodeManagerDataItem *dataItem = self.allItems[i];

        //如果唯一标识存在，则前面的xpath不需要了，以唯一标识开始
        if (dataItem.node.growingNodeUniqueTag) {
            lastNodeFullPath = [NSMutableString stringWithFormat:@"%@",dataItem.node.growingNodeUniqueTag];
            lastNodePatchedPath = [lastNodeFullPath mutableCopy];
        }else {
            
            if (i == self.allItems.count - 1) {
                [lastNodePatchedPath
                appendFormat:@"/%@", dataItem.node.growingNodeSubSimilarPath];
                //如果最后一个节点为list节点，则设置index,因为其similarPath返回为[-]
                if (dataItem.node.growingNodeIndexPath) {
                    keyIndex = dataItem.node.growingNodeKeyIndex;
                }
            }else {
                [lastNodePatchedPath
                appendFormat:@"%@%@",(i == 0)?@"":@"/", dataItem.node.growingNodeSubPath];
            }
            [lastNodeFullPath
            appendFormat:@"%@%@",(i == 0)?@"":@"/", dataItem.node.growingNodeSubPath];
        }
        dataItem.nodePatchedPath = lastNodePatchedPath;
        dataItem.nodeFullPath = lastNodeFullPath;
        dataItem.keyIndex = keyIndex;
    }
}

// 移除
- (void)removeNodeItemAtEnd {
    [self.allItems removeLastObject];
}

- (NSMutableArray<GrowingNodeManagerDataItem *> *)replaceAllItems:
    (NSMutableArray<GrowingNodeManagerDataItem *> *)newAllItems {
    NSMutableArray<GrowingNodeManagerDataItem *> *oldAllItems = self.allItems;
    self.allItems = newAllItems;

    self.needUpdateAllItems = YES;
    [self updateAllItems];
    if (self.allItems.count == 0) {
        self.allItems = oldAllItems;
        return nil;
    }

    self.needUpdatePathIndex = 0;
    [self updateAllItemXpath];

    return oldAllItems;
}

- (NSUInteger)nodeCount {
    return self.allItems.count;
}

- (NSString *)nodePathAtEnd {
    [self updateAllItems];
    [self updateAllItemXpath];
    return [self.allItems.lastObject nodePatchedPath];
}

- (NSInteger)nodeKeyIndexAtEnd {
    [self updateAllItems];
    [self updateAllItemXpath];
    return [self.allItems.lastObject keyIndex];
}

- (NSString *)nodePathAtIndex:(NSUInteger)index {
    [self updateAllItems];
    [self updateAllItemXpath];
    return [self.allItems[index] nodeFullPath];
}

- (GrowingNodeManagerDataItem *)itemAtIndex:(NSUInteger)index {
    [self updateAllItems];
    return self.allItems[index];
}

- (GrowingNodeManagerDataItem *)itemAtEnd {
    [self updateAllItems];
    return self.allItems.lastObject;
}

- (GrowingNodeManagerDataItem *)itemAtFirst {
    [self updateAllItems];
    return self.allItems.firstObject;
}

- (id<GrowingNode>)nodeAtFirst {
    return [[self itemAtFirst] node];
}

- (void)updateAllItems {
    if (!self.needUpdateAllItems) {
        return;
    }
    self.needUpdateAllItems = NO;
    //TODO:过滤你的items,从中去除不必要的item
    return;
}

@end

@implementation GrowingNodeManagerEnumerateContext

- (id)attributeValueForKey:(NSString *)key {
    NSArray *nodes = [self allNodes];
    id ret = nil;
    id<GrowingNode> lastNode = nil;
    id<GrowingNode> curNode = nil;
    for (NSInteger i = nodes.count - 1; i >= 0; i--) {
        curNode = nodes[i];
        ret = [curNode growingNodeAttribute:key];
        if (ret) {
            break;
        }
        if (lastNode) {
            ret = [curNode growingNodeAttribute:key forChild:lastNode];
            if (ret) {
                break;
            }
        }

        lastNode = curNode;
    }
    return ret;
}

- (NSArray<id<GrowingNode>> *)allNodes {
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    [self.manager.allItems
        enumerateObjectsUsingBlock:^(GrowingNodeManagerDataItem *_Nonnull obj,
                                     NSUInteger idx, BOOL *_Nonnull stop) {
            [nodes addObject:obj.node];
        }];
    return nodes;
}

- (id<GrowingNode>)startNode {
    return self.manager.enumItem;
}

- (void)stop {
    self.stopAll = YES;
}

- (void)skipThisChilds {
    self.stopChilds = YES;
}

- (void)onNodeFinish:(void (^)(id<GrowingNode>))finishBlock {
    if (!self.didEndNodeBlocks) {
        self.didEndNodeBlocks = [[NSMutableArray alloc] init];
    }
    [self.didEndNodeBlocks addObject:finishBlock];
}

- (NSString *)xpath {
    return [self.manager nodePathAtEnd];
}

- (NSInteger)nodeKeyIndex {
    return [self.manager nodeKeyIndexAtEnd];
}

@end
