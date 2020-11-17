//
//  GrowingEventNodeManager.m
//  GrowingTracker
//
//  Created by GrowingIO on 2018/5/10.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingEventNodeManager.h"

@interface GrowingEventNodeManager()
@property (nonatomic, retain) id<GrowingNode> triggerNode;
@end

@implementation GrowingEventNodeManager

- (instancetype)initWithNode:(id<GrowingNode>)aNode{
    
    if (!aNode) { return nil; }
    
    self.triggerNode = aNode;
    
    BOOL(^checkBlock)(id<GrowingNode> node) = ^BOOL(id<GrowingNode> node) {
        if ([node growingNodeDonotTrack]) {
            return NO;
        }
        
        return YES;
    };
    
    return [self initWithNodeAndParent:aNode checkBlock:checkBlock];
}

@end
