//
// GrowingWebCircleElement.m
// GrowingAnalytics
//
//  Created by sheng on 2020/12/8.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/WebCircle/GrowingWebCircleElement.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

@implementation GrowingWebCircleElement

+ (GrowingWebCircleElementBuilder *)builder {
    return [[GrowingWebCircleElementBuilder alloc] init];
}

- (instancetype)initWithBuilder:(GrowingWebCircleElementBuilder *)builder {
    if (self = [super init]) {
        _rect = builder.rect;
        _zLevel = builder.zLevel;
        _content = builder.content;
        _xpath = builder.xpath;
        _nodeType = builder.nodeType;
        _isContainer = builder.isContainer;
        _index = builder.index;
        _parentXPath = builder.parentXPath;
        _page = builder.page;
        _domain = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    CGFloat scale = MIN([UIScreen mainScreen].scale, 2);
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    dataDict[@"left"] = [NSNumber numberWithInt:(int)(self.rect.origin.x * scale)];
    dataDict[@"top"] = [NSNumber numberWithInt:(int)(self.rect.origin.y * scale)];
    dataDict[@"width"] = [NSNumber numberWithInt:(int)(self.rect.size.width * scale)];
    dataDict[@"height"] = [NSNumber numberWithInt:(int)(self.rect.size.height * scale)];
    dataDict[@"zLevel"] = @(self.zLevel);
    dataDict[@"content"] = self.content;
    dataDict[@"xpath"] = self.xpath;
    dataDict[@"nodeType"] = self.nodeType;
    dataDict[@"isContainer"] = @(self.isContainer);
    dataDict[@"index"] = self.index >= 0 ? @(self.index):nil;
    dataDict[@"parentXPath"] = self.parentXPath;
    dataDict[@"page"] = self.page;
    dataDict[@"domain"] = self.domain;
    return [dataDict copy];
}


@end


@implementation GrowingWebCircleElementBuilder

- (GrowingWebCircleElementBuilder *(^)(CGRect value))setRect {
    return ^(CGRect value) {
        self->_rect = value;
        return self;
    };
}
- (GrowingWebCircleElementBuilder *(^)(int value))setZLevel {
    return ^(int value) {
        self->_zLevel = value;
        return self;
    };
}
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setContent {
    return ^(NSString *value) {
        self->_content = value;
        return self;
    };
}
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setXpath {
    return ^(NSString *value) {
        self->_xpath = value;
        return self;
    };
}
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setNodeType {
    return ^(NSString *value) {
        self->_nodeType = value;
        return self;
    };
}

- (GrowingWebCircleElementBuilder *(^)(NSString *value))setParentXPath {
    return ^(NSString *value) {
        self->_parentXPath = value;
        return self;
    };
}

- (GrowingWebCircleElementBuilder *(^)(BOOL value))setIsContainer {
    return ^(BOOL value) {
        self->_isContainer = value;
        return self;
    };
}
- (GrowingWebCircleElementBuilder *(^)(int value))setIndex {
    return ^(int value) {
        self->_index = value;
        return self;
    };
}

- (GrowingWebCircleElementBuilder *(^)(NSString *value))setPage {
    return ^(NSString *value) {
        self->_page = value;
        return self;
    };
}

- (GrowingWebCircleElement *)build {
    return [[GrowingWebCircleElement alloc] initWithBuilder:self];
}

@end
