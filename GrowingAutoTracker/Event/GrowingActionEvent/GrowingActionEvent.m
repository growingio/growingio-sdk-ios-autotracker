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
#import "GrowingPageManager.h"
#import "GrowingEventManager.h"
#import "GrowingEventNodeManager.h"
#import "GrowingInstance.h"
#import "GrowingNodeManager.h"
#import "GrowingPageEvent.h"
#import "NSString+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingPageHelper.h"
#import "UIView+GrowingHelper.h"
#import "GrowingPageGroup.h"
#import "GrowingNodeHelper.h"
@interface GrowingActionEvent ()

@property (nonatomic, copy, readwrite) NSString *_Nullable query;
@property (nonatomic, copy, readwrite) NSString *_Nonnull pageName;
@property (nonatomic, copy, readwrite) NSString *_Nullable name;
@property (nonatomic, copy, readwrite) NSString *_Nullable objInfo;
@property (nonatomic, copy, readwrite) NSString *_Nullable pageTimestamp;

@property (nonatomic, strong) NSArray<GrowingActionEventElement *> *elements;

@property (nonatomic, copy) NSString *_Nullable hybridDomain;

@end

@implementation GrowingActionEvent

#pragma mark Public Methood

+ (void)sendEventWithNode:(id<GrowingNode>)node
             andEventType:(GrowingEventType)eventType {
    if ([NSThread isMainThread]) {
        // withChild 是否遍历子节点
        [self _sendEventsUnsafeWithNode:node
                              eventType:eventType
                             withChilds:NO];
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
                [self _sendEventsUnsafeWithNode:node
                                      eventType:eventType
                                     withChilds:NO];
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
        UIView *view = (UIView*)node;
        UIViewController *parent = [view growingHelper_viewController];
        NSString *path = [GrowingNodeHelper xPathForViewController:parent];
        pageData = [NSMutableDictionary dictionaryWithObjectsAndKeys:path, @"p", nil];
    }else {
        //错误情况
        NSDictionary *pageData = [[[GrowingPageManager sharedInstance] currentViewController] growingNodeDataDict];
        if (pageData.count != 0) {
            GrowingPageEvent *lastPageEvent =
                [GrowingEventManager shareInstance].lastPageEvent;
            if (lastPageEvent) {
                pageData = [NSMutableDictionary
                    dictionaryWithObjectsAndKeys:lastPageEvent.pageName, @"p", nil];
            }
        }
    }
    [self _sendEventsWithNode:node
                    eventType:eventType
                     pageData:pageData
                   withChilds:withChilds];
}

- (_Nullable instancetype)initWithNode:(id<GrowingNode>)view
                              pageData:(NSDictionary *_Nonnull)pageData
                              elements:(NSArray<GrowingActionEventElement *> *)
                                           elements {
    if (self = [super initWithTimestamp:nil]) {
        self.pageName = pageData[@"p"];
        self.pageTimestamp = pageData[@"ptm"];
//        // 根据测量协议，点击事件的 p 字段需要拼接父级 p
//        // https://growingio.atlassian.net/wiki/spaces/SDK/pages/1120830020/iOS+3.0
//        NSString *realPage = [self pageNameWithNode:view];
        self.elements = elements;
//        self.pageName = realPage;
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
//    __block BOOL isFirst = YES;

    NSMutableArray<GrowingActionEventElement *> *elements =
        [NSMutableArray arrayWithCapacity:5];
    
    GrowingActionEventElement *element =
        [[GrowingActionEventElement alloc] initWithNode:triggerNode
                                       triggerEventType:eventType];
    [elements addObject:element];
    
//    [manager enumerateChildrenUsingBlock:^(
//                 id<GrowingNode> aNode,
//                 GrowingNodeManagerEnumerateContext *context) {
//        if (!withChilds) {
//            [context stop];
//        }
//
//        BOOL needTrack = NO;
//        BOOL userInActionNeedTrack = YES;
//        // 只捕获子views的可响应事件的一级node
//        if ([aNode growingNodeUserInteraction]) {
//            if (isFirst) {
//                isFirst = NO;
//                needTrack = YES;
//            } else {
//                userInActionNeedTrack = NO;
//                [context skipThisChilds];
//            }
//        }
//
//        if (([aNode growingNodeContent] || needTrack) &&
//            userInActionNeedTrack) {
//            GrowingActionEventElement *element =
//                [[GrowingActionEventElement alloc] initWithNode:aNode
//                                             nodeManagerContext:context
//                                               triggerEventType:eventType];
//            [elements addObject:element];
//        }
//    }];

    GrowingEvent *event = [[self alloc] initWithNode:triggerNode
                                            pageData:pageData
                                            elements:elements];
    if (event) {
        [[GrowingEventManager shareInstance] addEvent:event
                                             thisNode:triggerNode
                                          triggerNode:triggerNode
                                          withContext:nil];
    }
}

+ (instancetype)hybridActionEventWithDataDict:(NSDictionary *)dataDict {
    NSNumber *timestamp = dataDict[@"ptm"];

    GrowingActionEvent *actionEvent =
        [[self alloc] initWithTimestamp:timestamp];
    actionEvent.pageName = dataDict[@"p"];
    actionEvent.query = dataDict[@"q"];
    actionEvent.hybridDomain = dataDict[@"d"];

    NSArray<NSDictionary *> *elementDicts = dataDict[@"e"];
    NSMutableArray<GrowingActionEventElement *> *elementsM =
        [NSMutableArray arrayWithCapacity:2];

    for (NSDictionary *elementDict in elementDicts) {
        GrowingActionEventElement *element =
            [[GrowingActionEventElement alloc] init];
        element.hyperLink = elementDict[@"h"];
        element.index = elementDict[@"i"];
        element.content = elementDict[@"v"];
        element.xPath = elementDict[@"x"];
        element.timestamp = elementDict[@"tm"];

        [elementsM addObject:element];
    }

    actionEvent.elements = elementsM;

    return actionEvent;
}

#pragma mark GrowingEventCountable

- (NSInteger)nextGlobalSequenceWithBase:(NSInteger)base
                                andStep:(NSInteger)step {
    NSInteger baseSeq = (base > 0) ? base : 0;
    NSInteger baseStep = (step > 0) ? step : 1;

    NSInteger result = baseSeq + baseStep;

    for (GrowingActionEventElement *element in self.elements) {
        element.globalSequenceId = [NSNumber numberWithInteger:result];
        result += baseStep;
    }

    return result;
}

- (NSInteger)nextEventSequenceWithBase:(NSInteger)base andStep:(NSInteger)step {
    NSInteger baseSeq = (base > 0) ? base : 0;
    NSInteger baseStep = (step > 0) ? step : 1;

    NSInteger result = baseSeq + baseStep;
    for (GrowingActionEventElement *element in self.elements) {
        element.eventSequenceId = [NSNumber numberWithInteger:result];
        result += baseStep;
    }

    return result;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM =
        [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];

    // sub element will fill these two field
    if ([dataDictM valueForKey:@"gesid"]) {
        [dataDictM removeObjectForKey:@"gesid"];
    }

    if ([dataDictM valueForKey:@"esid"]) {
        [dataDictM removeObjectForKey:@"esid"];
    }

    dataDictM[@"q"] = self.query;
    dataDictM[@"p"] = self.pageName;
    dataDictM[@"d"] = self.hybridDomain ?: self.domain;

    NSMutableArray *eles = [NSMutableArray arrayWithCapacity:5];
    for (GrowingActionEventElement *element in self.elements) {
        [eles addObject:element.toDictionary];
    }
    if (eles.count > 0) {
        dataDictM[@"e"] = eles;
    }

    return dataDictM;
}

@end
