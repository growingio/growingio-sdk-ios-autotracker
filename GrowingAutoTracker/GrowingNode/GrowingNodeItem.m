//
//  GrowingNodeItem.m
//  GrowingTracker
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


#import "GrowingNodeItem.h"
#import "GrowingNode.h"

#define __indexNotDefine -100
#define __indexNotFound  -101

@implementation GrowingNodeItemComponent

- (instancetype)initWithPath:(NSString*)path index:(NSInteger)index isKeyIndex:(BOOL)isKeyIndex
{
    self = [super init];
    if (self)
    {
        self.index = index;
        self.pathComponent = path;
        self.isKeyIndex = (index < 0 ? NO : isKeyIndex);
        self.userDefinedTag = nil;
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path index:(NSInteger)index
{
    return [self initWithPath:path index:index isKeyIndex:NO];
}

- (instancetype)initWithPath:(NSString *)path
{
    return [self initWithPath:path index:__indexNotDefine isKeyIndex:NO];
}

- (instancetype)init
{
    return [self initWithPath:nil index:__indexNotDefine isKeyIndex:NO];
}

+ (NSInteger)indexNotDefine
{
    return __indexNotDefine;
}

+ (NSInteger)indexNotFound
{
    return __indexNotFound;
}

@end

@implementation GrowingNodeItem

- (instancetype)initWithNode:(id<GrowingNode>)node pathComponents:(NSArray<GrowingNodeItemComponent *> *)pathComponents
{
    self = [super init];
    if (self)
    {
        self.node = node;
        self.pathComponents = [pathComponents copy];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithNode:nil pathComponents:nil];
}

- (NSString*)description
{
    return NSStringFromClass([self.node class]);
}

@end
