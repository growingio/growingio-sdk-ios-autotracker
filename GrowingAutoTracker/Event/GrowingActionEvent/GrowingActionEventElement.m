//
//  GrowingActionEventElement.m
//  GrowingAutoTracker
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

#import "GrowingActionEventElement.h"

#import "GrowingEventManager.h"
#import "GrowingInstance.h"
#import "GrowingNodeHelper.h"
#import "GrowingNodeManager.h"
#import "NSString+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "UIViewController+GrowingNode.h"

@implementation GrowingActionEventElement

- (instancetype)initWithNode:(id<GrowingNode>)node triggerEventType:(GrowingEventType)eventType {
    if (self = [super init]) {
        _xPath = [GrowingNodeHelper xPathForNode:node];
        _textValue = [self buildElementContentForNode:node];
        _timestamp = GROWGetTimestamp();
        //对于非列表元素，不添加index字段
        if (node.growingNodeIndexPath) {
            _index = [NSString stringWithFormat:@"%d", (int)node.growingNodeKeyIndex];
        }
    }
    return self;
}

- (NSString *)buildElementContentForNode:(id<GrowingNode> _Nonnull)view {
    NSString *content = [view growingNodeContent];
    if (!content) {
        content = @"";
    } else if ([content isKindOfClass:NSDictionary.class]) {
        content = [[(NSDictionary *)content allValues] componentsJoinedByString:@""];
    } else if ([content isKindOfClass:NSArray.class]) {
        content = [(NSArray *)content componentsJoinedByString:@""];
    } else {
        content = content.description;
    }

    if (![content isKindOfClass:NSString.class]) {
        content = @"";
    }

    content = [content growingHelper_safeSubStringWithLength:100];

    if (content.growingHelper_isLegal) {
        content = @"";
    } else {
        content = content.growingHelper_encryptString;
    }

    return content;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithCapacity:5];
    dataDictM[@"xpath"] = self.xPath;
    dataDictM[@"timestamp"] = self.timestamp;
    if (self.textValue.length > 0) {
        dataDictM[@"textValue"] = self.textValue;
    }
    
    dataDictM[@"hyperlink"] = self.hyperLink;
    dataDictM[@"index"] = self.index;

    dataDictM[@"globalSequenceId"] = self.globalSequenceId;
    dataDictM[@"eventSequenceId"] = self.eventSequenceId;

    return dataDictM;
}

@end
