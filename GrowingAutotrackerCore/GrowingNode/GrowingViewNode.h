//
//  GrowingActionEventElement.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/5/29.
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

#import <UIKit/UIKit.h>
#import "GrowingBaseEvent.h"
#import "GrowingTrackerCore/Event/GrowingNodeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingViewNodeBuilder;

@interface GrowingViewNode : NSObject

@property (nonatomic, weak, readonly) UIView *view;
@property (nonatomic, copy, readonly) NSString *_Nullable viewContent;
@property (nonatomic, copy, readonly) NSString *xpath;
@property (nonatomic, copy, readonly) NSString *xcontent;
// 原始的位置组
@property (nonatomic, copy, readonly) NSString *originxcontent;
// 可点击的父节点xpath
@property (nonatomic, copy, readonly) NSString *clickableParentXpath;
@property (nonatomic, copy, readonly) NSString *clickableParentXcontent;
@property (nonatomic, copy, readonly) NSString *_Nullable nodeType;
// 如果有父节点，且父节点为列表，则index有值，和父节点一致，否则为-1
@property (nonatomic, assign, readonly) int index;
@property (nonatomic, assign, readonly) BOOL hasListParent;
// xpath/xcontent会被uniqueTag截断
@property (nonatomic, assign, readonly) BOOL isBreak;
// 当圈选时，从上至下的路径不一定和正常事件(从下至上)的路径一致，我们需要从新计算xpath
@property (nonatomic, assign, readonly) BOOL needRecalculate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithBuilder:(GrowingViewNodeBuilder *)builder;
+ (GrowingViewNodeBuilder *)builder;

// viewNode next需要依赖上一个来生成
- (GrowingViewNode *)appendNode:(UIView *)view isRecalculate:(BOOL)recalculate;

@end

@interface GrowingViewNodeBuilder : NSObject

@property (nonatomic, strong, readonly) UIView *view;
@property (nonatomic, copy, readonly) NSString *_Nullable viewContent;
@property (nonatomic, copy, readonly) NSString *xpath;
@property (nonatomic, copy, readonly) NSString *xcontent;
// 原始的位置组
@property (nonatomic, copy, readonly) NSString *originxcontent;
// 可点击的父节点xpath
@property (nonatomic, copy, readonly) NSString *clickableParentXpath;
@property (nonatomic, copy, readonly) NSString *clickableParentXcontent;
@property (nonatomic, copy, readonly) NSString *_Nullable nodeType;
// 如果有父节点，且父节点为列表，则index有值，和父节点一致，否则为-1
@property (nonatomic, assign, readonly) int index;
@property (nonatomic, assign, readonly) BOOL hasListParent;
@property (nonatomic, assign, readonly) BOOL isBreak;
@property (nonatomic, assign, readonly) BOOL needRecalculate;

- (GrowingViewNodeBuilder * (^)(UIView *value))setView;
- (GrowingViewNodeBuilder * (^)(NSString *value))setXpath;
- (GrowingViewNodeBuilder * (^)(NSString *value))setXcontent;
- (GrowingViewNodeBuilder * (^)(NSString *value))setOriginXcontent;
- (GrowingViewNodeBuilder * (^)(NSString *value))setClickableParentXpath;
- (GrowingViewNodeBuilder * (^)(NSString *value))setClickableParentXcontent;
- (GrowingViewNodeBuilder * (^)(int value))setIndex;
- (GrowingViewNodeBuilder * (^)(NSString *value))setViewContent;
- (GrowingViewNodeBuilder * (^)(NSString *value))setNodeType;
- (GrowingViewNodeBuilder * (^)(BOOL value))setHasListParent;
- (GrowingViewNodeBuilder * (^)(BOOL value))setIsBreak;
- (GrowingViewNodeBuilder * (^)(BOOL value))setNeedRecalculate;
- (GrowingViewNode *)build;

@end

NS_ASSUME_NONNULL_END
