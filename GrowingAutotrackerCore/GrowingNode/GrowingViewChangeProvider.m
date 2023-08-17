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
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingNodeHelper.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewNode.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

@implementation GrowingViewChangeProvider

+ (void)viewOnChange:(UIView *)view {
    if ([view growingNodeDonotTrack]) {
        GIOLogDebug(@"viewOnChange %@ is donotTrack", view);
        return;
    }

    GrowingPage *page = [GrowingPageManager.sharedInstance findPageByView:view];
    GrowingPage *autotrackPage = [GrowingPageManager.sharedInstance findAutotrackPageByPage:page];
    GrowingViewNode *node = [GrowingNodeHelper getViewNode:view];

    GrowingViewElementBuilder *builder = GrowingViewElementEvent.builder.setEventType(GrowingEventTypeViewChange)
                                             .setPath(@"")
                                             .setIndex(node.index)
                                             .setTextValue(node.viewContent);
    if (node.isBreak) {
        builder.setXpath(node.xpath).setXcontent(node.xcontent);
    } else {
        NSDictionary *pathInfo = page.pathInfo;
        NSString *pagexpath = pathInfo[@"xpath"];
        NSString *pagexcontent = pathInfo[@"xcontent"];
        builder.setXpath([NSString stringWithFormat:@"%@%@", pagexpath, node.xpath])
            .setXcontent([NSString stringWithFormat:@"%@%@", pagexcontent, node.xcontent]);
    }

    if (autotrackPage) {
        builder.setPath([NSString stringWithFormat:@"/%@", autotrackPage.alias])
            .setAttributes(autotrackPage.attributes);
    }

    [[GrowingEventManager sharedInstance] postEventBuilder:builder];
}

@end
