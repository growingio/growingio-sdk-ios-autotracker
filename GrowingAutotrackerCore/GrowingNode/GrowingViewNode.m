//
//  GrowingActionEventElement.m
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

#import "GrowingAutotrackerCore/GrowingNode/GrowingViewNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingNodeHelper.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingNodeProtocol.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingULTimeUtil.h"

@interface GrowingViewNode ()

@property (nonatomic, copy, readwrite) NSString *xpath;
@property (nonatomic, copy, readwrite) NSString *xcontent;
@property (nonatomic, copy, readwrite) NSString *originxcontent;

@end

@implementation GrowingViewNode

- (instancetype)initWithBuilder:(GrowingViewNodeBuilder *)builder {
    if (self = [super init]) {
        _view = builder.view;
        _viewContent = builder.viewContent;
        _xpath = builder.xpath;
        _xcontent = builder.xcontent;
        _originxcontent = builder.originxcontent;
        _clickableParentXpath = builder.clickableParentXpath;
        _clickableParentXcontent = builder.clickableParentXcontent;
        _nodeType = builder.nodeType;
        _index = builder.index;
        _position = builder.position;
        _hasListParent = builder.hasListParent;
        _needRecalculate = builder.needRecalculate;
        if (_needRecalculate) {
            [self recalculate];
        }
    }
    return self;
}

- (void)recalculate {
    __weak typeof(self) weakSelf = self;
    [GrowingNodeHelper
        recalculateXpath:self.view
                   block:^(NSString *_Nonnull xpath, NSString *_Nonnull xcontent, NSString *_Nonnull originxcontent) {
                       __strong typeof(weakSelf) self = weakSelf;
                       self.xpath = xpath;
                       self.xcontent = xcontent;
                       self.originxcontent = originxcontent;
                   }];
}

+ (GrowingViewNodeBuilder *)builder {
    return [[GrowingViewNodeBuilder alloc] init];
}

- (GrowingViewNode *)appendNode:(UIView *)view isRecalculate:(BOOL)recalculate {
    NSString *subpath = view.growingNodeSubPath;
    // 如果节点path不存在，说明被过滤了，除了view之外，全部copy父级属性
    if (!subpath) {
        return GrowingViewNode.builder.setView(view)
            .setIndex(self.index)
            .setXpath(self.xpath)
            .setXcontent(self.xcontent)
            .setOriginXcontent(self.originxcontent)
            .setClickableParentXpath(self.clickableParentXpath)
            .setClickableParentXcontent(self.clickableParentXcontent)
            .setHasListParent(self.hasListParent)
            .setViewContent(self.viewContent)
            .setPosition(self.position)
            .setNodeType(self.nodeType)
            .setNeedRecalculate(recalculate)
            .build;
    }

    BOOL haslistParent = self.hasListParent || [self.view isKindOfClass:[UITableView class]] ||
                         [self.view isKindOfClass:[UICollectionView class]];
    // 是否是相似元素
    BOOL isSimilar = [view isKindOfClass:[UITableViewCell class]] ||
                     [view isKindOfClass:[UICollectionReusableView class]] ||
                     [view isKindOfClass:NSClassFromString(@"UISegment")];
    long index = -1;
    if (isSimilar) {
        index = view.growingNodeKeyIndex;
    } else if (haslistParent) {
        index = self.index;
    }

    NSString *parentXpath = self.view.growingNodeUserInteraction ? self.xpath : self.clickableParentXpath;
    NSString *parentXcontent = self.view.growingNodeUserInteraction ? self.xcontent : self.clickableParentXcontent;
    NSString *content = view.growingNodeContent;

    return GrowingViewNode.builder.setView(view)
        .setIndex((int)index)
        .setXpath([self.xpath stringByAppendingFormat:@"/%@", view.growingNodeSubPath])
        .setXcontent([self.originxcontent stringByAppendingFormat:@"/%@", view.growingNodeSubSimilarIndex])
        .setOriginXcontent([self.originxcontent stringByAppendingFormat:@"/%@", view.growingNodeSubIndex])
        .setClickableParentXpath(parentXpath)
        .setClickableParentXcontent(parentXcontent)
        .setHasListParent(haslistParent)
        .setViewContent(content ? [content growingHelper_safeSubStringWithLength:50] : nil)
        .setPosition((int)view.growingNodeKeyIndex)
        .setNodeType([GrowingNodeHelper getViewNodeType:view])
        .setNeedRecalculate(recalculate)
        .build;
}

@end

@implementation GrowingViewNodeBuilder

- (GrowingViewNodeBuilder * (^)(UIView *value))setView {
    return ^(UIView *value) {
        self->_view = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(NSString *value))setXpath {
    return ^(NSString *value) {
        self->_xpath = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(NSString *value))setXcontent {
    return ^(NSString *value) {
        self->_xcontent = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(NSString *value))setOriginXcontent {
    return ^(NSString *value) {
        self->_originxcontent = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(NSString *value))setClickableParentXpath {
    return ^(NSString *value) {
        self->_clickableParentXpath = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(NSString *value))setClickableParentXcontent {
    return ^(NSString *value) {
        self->_clickableParentXcontent = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(int value))setIndex {
    return ^(int value) {
        self->_index = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(int value))setPosition {
    return ^(int value) {
        self->_position = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(NSString *value))setViewContent {
    return ^(NSString *value) {
        self->_viewContent = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(NSString *value))setNodeType {
    return ^(NSString *value) {
        self->_nodeType = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(BOOL value))setHasListParent {
    return ^(BOOL value) {
        self->_hasListParent = value;
        return self;
    };
}

- (GrowingViewNodeBuilder * (^)(BOOL value))setNeedRecalculate {
    return ^(BOOL value) {
        self->_needRecalculate = value;
        return self;
    };
}

- (GrowingViewNode *)build {
    return [[GrowingViewNode alloc] initWithBuilder:self];
}

@end
