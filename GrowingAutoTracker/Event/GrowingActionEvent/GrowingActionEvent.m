//
//  GrowingActionEvent.m
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/5/27.
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

#import "GrowingActionEvent.h"

#import "GrowingActionEventElement.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingEventManager.h"
#import "GrowingEventNodeManager.h"
#import "GrowingInstance.h"
#import "GrowingNodeHelper.h"
#import "GrowingNodeManager.h"
#import "GrowingPageEvent.h"
#import "GrowingPageGroup.h"
#import "GrowingPageManager.h"
#import "NSString+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingPageHelper.h"

/// 点击事件的最小时间间隔，默认是 100 毫秒
static NSTimeInterval kGrowingTrackClickMinTimeInterval = 0.1;

@interface GrowingActionEvent ()

@property (nonatomic, copy, readwrite) NSString *_Nullable queryParameters;
@property (nonatomic, copy, readwrite) NSString *_Nonnull pageName;
@property (nonatomic, copy, readwrite) NSString *_Nullable name;
@property (nonatomic, copy, readwrite) NSString *_Nullable objInfo;
@property (nonatomic, copy, readwrite) NSString *_Nullable pageShowTimestamp;

@property (nonatomic, strong) GrowingActionEventElement *element;

@property (nonatomic, copy) NSString *_Nullable hybridDomain;

@end

@implementation GrowingActionEvent

#pragma mark Public Methood

+ (void)sendEventWithNode:(id<GrowingNode>)node andEventType:(GrowingEventType)eventType {
    if ([NSThread isMainThread]) {
        // withChild 是否遍历子节点
        [self _sendEventsUnsafeWithNode:node eventType:eventType withChilds:NO];
    } else {
        __weak id<GrowingNode> weakNode = node;
        dispatch_async(dispatch_get_main_queue(), ^{
            id<GrowingNode> strongNode = weakNode;
            if (!strongNode) {
                return;
            }

            // 混沌商学院有在子线程操作UI引起IMP事件触发时遍历UIView导致crash -
            // JIRA PI-358 这里简单的try/catch处理下, 防止crash
            @try {
                [self _sendEventsUnsafeWithNode:node eventType:eventType withChilds:NO];
            } @catch (NSException *exception) {
                GIOLogInfo(@"[gio] imp exception : %@", exception);
            } @finally {
                // do nothing
            }
        });
    }
}

+ (void)_sendEventsUnsafeWithNode:(id<GrowingNode>)node
                        eventType:(GrowingEventType)eventType
                       withChilds:(BOOL)withChilds {
    if (withChilds == NO && ![self checkNode:node]) {
        return;
    }
    NSDictionary *pageData = nil;

    if ([node isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)node;
        UIViewController *parent = [view growingHelper_viewController];
        NSString *path = [GrowingNodeHelper xPathForViewController:parent];
        GrowingPageGroup *page = [parent growingPageHelper_getPageObject];
        pageData = [NSMutableDictionary
            dictionaryWithObjectsAndKeys:path, @"pageName", page.showTimestamp, @"pageShowTimestamp", nil];
    } else {
        //错误情况
        NSDictionary *pageData = [[[GrowingPageManager sharedInstance] currentViewController] growingNodeDataDict];
        if (pageData.count != 0) {
            GrowingPageEvent *lastPageEvent = [GrowingEventManager shareInstance].lastPageEvent;
            if (lastPageEvent) {
                pageData = [NSMutableDictionary dictionaryWithObjectsAndKeys:lastPageEvent.pageName, @"pageName", nil];
            }
        }
    }
    [self _sendEventsWithNode:node eventType:eventType pageData:pageData withChilds:withChilds];
}

- (_Nullable instancetype)initWithNode:(id<GrowingNode>)view
                              pageData:(NSDictionary *_Nonnull)pageData
                               element:(GrowingActionEventElement *)element {
    if (self = [super initWithTimestamp:nil]) {
        self.pageName = pageData[@"pageName"];
        self.pageShowTimestamp = pageData[@"pageShowTimestamp"];
        // 根据测量协议，点击事件的 p 字段需要拼接父级 p
        // https://growingio.atlassian.net/wiki/spaces/SDK/pages/1120830020/iOS+3.0
        self.element = element;
    }
    return self;
}

+ (BOOL)checkNode:(id<GrowingNode>)aNode {
    if ([aNode respondsToSelector:@selector(growingNodeEligibleEventCategory)]) {
        GrowingElementEventCategory c = [aNode growingNodeEligibleEventCategory];
        if (!(c & GrowingElementEventCategoryClick)) {
            return NO;
        }
    }
    return [aNode growingNodeUserInteraction];
}

+ (void)_sendEventsWithNode:(id<GrowingNode>)triggerNode
                  eventType:(GrowingEventType)eventType
                   pageData:(NSDictionary *)pageData
                 withChilds:(BOOL)withChilds {
    GrowingActionEventElement *element = [[GrowingActionEventElement alloc] initWithNode:triggerNode
                                                                        triggerEventType:eventType];

    GrowingEvent *event = [[self alloc] initWithNode:triggerNode pageData:pageData element:element];
    if (event) {
        [[GrowingEventManager shareInstance] addEvent:event
                                             thisNode:triggerNode
                                          triggerNode:triggerNode
                                          withContext:nil];
    }
}

+ (instancetype)hybridActionEventWithDataDict:(NSDictionary *)dataDict {
    NSNumber *timestamp = dataDict[@"pageShowTimestamp"];

    GrowingActionEvent *actionEvent = [[self alloc] initWithTimestamp:timestamp];
    actionEvent.pageName = dataDict[@"pageName"];
    actionEvent.queryParameters = dataDict[@"queryParameters"];
    actionEvent.hybridDomain = dataDict[@"domain"];

    GrowingActionEventElement *element = [[GrowingActionEventElement alloc] init];
    element.hyperLink = dataDict[@"hyperlink"];
    element.index = dataDict[@"index"];
    element.textValue = dataDict[@"textValue"];
    element.xPath = dataDict[@"xpath"];
    element.timestamp = dataDict[@"timestamp"];

    actionEvent.element = element;

    return actionEvent;
}

+ (BOOL)isValidClickEventForNode:(id<GrowingNode>)node {
    if (!node) {
        return NO;
    }
    
    NSTimeInterval lastTime = node.growingTimeIntervalForLastClick;
    NSTimeInterval currentTime = [NSProcessInfo processInfo].systemUptime;
    if (lastTime > 0 && (currentTime - lastTime) < kGrowingTrackClickMinTimeInterval) {
        return NO;
    }
    
    return YES;
}

#pragma mark GrowingEventCountable

- (NSInteger)nextGlobalSequenceWithBase:(NSInteger)base andStep:(NSInteger)step {
    NSInteger baseSeq = (base > 0) ? base : 0;
    NSInteger baseStep = (step > 0) ? step : 1;

    NSInteger result = baseSeq + baseStep;

    self.element.globalSequenceId = [NSNumber numberWithInteger:result];
    result += baseStep;
    return result;
}

- (NSInteger)nextEventSequenceWithBase:(NSInteger)base andStep:(NSInteger)step {
    NSInteger baseSeq = (base > 0) ? base : 0;
    NSInteger baseStep = (step > 0) ? step : 1;

    NSInteger result = baseSeq + baseStep;
    self.element.eventSequenceId = [NSNumber numberWithInteger:result];
    result += baseStep;
    return result;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];

    // sub element will fill these two field
    if ([dataDictM valueForKey:@"globalSequenceId"]) {
        [dataDictM removeObjectForKey:@"globalSequenceId"];
    }

    if ([dataDictM valueForKey:@"eventSequenceId"]) {
        [dataDictM removeObjectForKey:@"eventSequenceId"];
    }
    if (self.pageShowTimestamp) {
        dataDictM[@"pageShowTimestamp"] = self.pageShowTimestamp;
    }
    dataDictM[@"queryParameters"] = self.queryParameters;
    dataDictM[@"pageName"] = self.pageName;
    dataDictM[@"domain"] = self.hybridDomain ?: self.domain;
    if (self.element) {
        [dataDictM addEntriesFromDictionary:self.element.toDictionary];
    }
    return dataDictM;
}

@end
