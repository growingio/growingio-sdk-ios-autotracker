//
//  GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/12/12.
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
#import "GrowingTracker.h"
#import "GrowingAutoTracker.h"
#import "GrowingNodeItem.h"
#import "GrowingNodeProtocol.h"

@interface NSObject(GrowingNode)
@property (nonatomic, assign) BOOL growingNodeIsBadNode;
@end

@class GrowingDullNode;

@interface GrowingRootNode : NSObject<GrowingNode>
+ (instancetype)rootNode;
@end

// all properties are set beforehand
@interface GrowingDullNode : NSObject<GrowingNode>
@property (nonatomic, copy, readonly) NSString * growingNodeXPath;
@property (nonatomic, copy, readonly) NSString * growingNodePatternXPath;
@property (nonatomic, assign, readonly) NSInteger growingNodeKeyIndex;
@property (nonatomic, copy, readonly) NSString * growingNodeHyperlink;
@property (nonatomic, copy, readonly) NSString * growingNodeType;
// iOS11之后才使用, 存的safeAreaInsets的值, iOS11之前为nil
@property (nonatomic, strong) NSValue *safeAreaInsetsValue;
@property (nonatomic, assign) BOOL isHybridTrackingEditText;


- (instancetype)initWithName:(NSString *)name
                  andContent:(NSString *)content
          andUserInteraction:(BOOL)userInteraction
                    andFrame:(CGRect)frame
                 andKeyIndex:(NSInteger)keyIndex
                    andXPath:(NSString *)xPath
             andPatternXPath:(NSString *)patternXPath
                andHyperlink:(NSString *)hyperlink
                 andNodeType:(NSString *)nodeType
      andSafeAreaInsetsValue:(NSValue *)safeAreaInsetsValue
    isHybridTrackingEditText:(BOOL)isHybridTrackingEditText;

@end
