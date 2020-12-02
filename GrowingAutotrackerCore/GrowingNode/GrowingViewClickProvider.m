//
// GrowingViewClickProvider.m
// GrowingAnalytics-Autotracker-AutotrackerCore-Tracker-TrackerCore
//
//  Created by sheng on 2020/11/16.
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


#import "GrowingViewClickProvider.h"
#import "GrowingEventManager.h"
#import "GrowingViewElementEvent.h"
#import "GrowingViewNode.h"
#import "GrowingPageManager.h"

@implementation GrowingViewClickProvider

+ (void)viewOnClick:(UIView *)view {
    GrowingPageGroup *page = [[GrowingPageManager sharedInstance] findPageByView:view];
    if (!page) {
        page = [[GrowingPageManager sharedInstance] currentPage];
    }
    GrowingViewNode *node = [[GrowingViewNode alloc] initWithNode:view];
    [self sendClickEvent:page viewNode:node];
}

+ (void)sendClickEvent:(GrowingPageGroup *)page viewNode:(GrowingViewNode *)node{
    [[GrowingEventManager shareInstance] postEventBuidler:GrowingViewElementEvent.builder.setEventType(GrowingEventTypeViewClick)
     .setPath(page.path)
     .setPageShowTimestamp(page.showTimestamp)
     .setXpath(node.xPath)
     .setIndex(node.index)
     .setTextValue(node.textValue)];
}

@end
