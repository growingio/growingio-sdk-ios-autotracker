//
//  ViewImpressionCoexistenceTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "Modules/ImpressionTrack/GrowingImpressionTrack.h"
#import "Modules/ImpressionTrack/Public/UIView+GrowingImpression.h"
#import "Modules/ViewImpression/Public/UIView+GrowingViewImpression.h"
#import "ViewImpressionTestCase.h"

@interface ViewImpressionCoexistenceTests : ViewImpressionTestCase

@end

@implementation ViewImpressionCoexistenceTests

- (void)testImpressionTrackIsDisabledByViewImpression {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackImpression:@"imp_v1"];

    XCTAssertFalse([GrowingImpressionTrack sharedInstance].impTrackActive);
    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testViewImpressionStillWorksWhileImpressionTrackIsPresent {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackImpression:@"imp_v1_coexist"];
    [view growingTrackViewImpression:@"imp_v2_coexist"];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.eventName, @"imp_v2_coexist");
    [self assertNoMoreCustomEventsWithin:0.5];
}

@end
