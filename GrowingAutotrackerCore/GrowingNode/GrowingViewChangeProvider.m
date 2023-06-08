//
//  GrowingViewChangeProvider.m
//  GrowingAnalytics
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

#import "GrowingAutotrackerCore/GrowingNode/GrowingViewChangeProvider.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingNodeHelper.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewNode.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogMacros.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

@implementation GrowingViewChangeProvider

+ (void)viewOnChange:(UIView *)view {
    if ([view growingNodeDonotTrack]) {
        GIOLogDebug(@"viewOnChange %@ is donotTrack", view);
        return;
    }
    GrowingPage *page = [[GrowingPageManager sharedInstance] findPageByView:view];
    if (!page) {
        page = [[GrowingPageManager sharedInstance] currentPage];
    }
    GrowingViewNode *node = [GrowingNodeHelper getViewNode:view];
    [self sendChangeEvent:page viewNode:node];
}

+ (void)sendChangeEvent:(GrowingPage *)page viewNode:(GrowingViewNode *)node {
    GrowingViewElementBuilder *builder = GrowingViewElementEvent.builder.setEventType(GrowingEventTypeViewChange)
                                             .setPath(page.path)
                                             .setXpath(node.xPath)
                                             .setIndex(node.index)
                                             .setTextValue(node.viewContent);

    if ([GrowingPageManager.sharedInstance pageNeedAutotrack:page.carrier]) {
        builder.setAttributes([page.carrier growingPageAttributes]);
    }

    [[GrowingEventManager sharedInstance] postEventBuilder:builder];
}

@end
