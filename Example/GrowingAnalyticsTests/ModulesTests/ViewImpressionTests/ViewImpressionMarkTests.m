//
//  ViewImpressionMarkTests.m
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
#import "Modules/ViewImpression/Public/GrowingViewImpressionConfig.h"
#import "Modules/ViewImpression/Public/UIView+GrowingViewImpression.h"
#import "ViewImpressionTestCase.h"

@interface ViewImpressionMarkTests : ViewImpressionTestCase

@end

@implementation ViewImpressionMarkTests

- (void)testVisibleViewSendsImpression {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_visible"];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.eventName, @"imp_visible");
}

- (void)testAttributesAreCarriedIntoEvent {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_attributes" attributes:@{@"key": @"value"}];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.attributes[@"key"], @"value");
}

- (void)testOffscreenViewSendsNothing {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 700, 375, 100)];
    [view growingMarkImpression:@"imp_offscreen"];

    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testViewSendsAfterMovingOnscreen {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 700, 375, 100)];
    [view growingMarkImpression:@"imp_move"];
    [self assertNoMoreCustomEventsWithin:0.3];

    view.frame = CGRectMake(0, 0, 375, 100);
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
}

- (void)testStillVisibleViewSendsOnlyOnce {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_once"];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testViewSendsAgainAfterLeavingAndReentering {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_reenter"];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    view.frame = CGRectMake(0, 700, 375, 100);
    [self pumpRunLoopFor:0.3];
    view.frame = CGRectMake(0, 0, 375, 100);

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
}

- (void)testUnmarkStopsImpression {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 700, 375, 100)];
    [view growingMarkImpression:@"imp_unmark"];
    [view growingUnmarkImpression];

    view.frame = CGRectMake(0, 0, 375, 100);
    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testEmptyEventNameIsIgnored {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@""];

    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testMarkOnNonKeyWindowView {
    UIWindow *another = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    another.rootViewController = [[UIViewController alloc] init];
    another.hidden = NO;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 100)];
    [another.rootViewController.view addSubview:view];

    [view growingMarkImpression:@"imp_other_window"];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.eventName, @"imp_other_window");

    [view growingUnmarkImpression];
    another.hidden = YES;
}

- (void)testRemarkingWithSameContentDoesNotRefire {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_remark" attributes:@{@"key": @"value"}];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [view growingMarkImpression:@"imp_remark" attributes:@{@"key": @"value"}];

    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testRemarkingWithDifferentAttributesRefires {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_remark_attributes" attributes:@{@"key": @"old"}];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [view growingMarkImpression:@"imp_remark_attributes" attributes:@{@"key": @"new"}];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.attributes[@"key"], @"new");
}

- (void)testRemarkingWithDifferentEventNameRefires {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_remark_name_a"];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [view growingMarkImpression:@"imp_remark_name_b"];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.eventName, @"imp_remark_name_b");
}

- (void)testRemarkingWithDifferentConfigRefires {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_remark_config" attributes:nil identifier:nil config:nil];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    GrowingViewImpressionConfig *config = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                        stayDuration:0.0
                                                                                          repeatable:YES];
    [view growingMarkImpression:@"imp_remark_config" attributes:nil identifier:nil config:config];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
}

- (void)testReusedViewWithNewIdentifierDropsPreviousSlot {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingMarkImpression:@"imp_row" attributes:@{@"row": @(1)} identifier:@"row_1" config:nil];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    view.frame = CGRectMake(0, 700, 375, 100);
    [self pumpRunLoopFor:0.3];

    [view growingMarkImpression:@"imp_row" attributes:@{@"row": @(2)} identifier:@"row_2" config:nil];
    view.frame = CGRectMake(0, 0, 375, 100);
    [self pumpRunLoopFor:0.6];

    XCTAssertEqual([self customEventCount], 2);
    XCTAssertEqualObjects(self.lastCustomEvent.attributes[@"row"], @"2");
}

- (void)testReusedCellSubviewWithNewIdentifierDropsPreviousSlot {
    UIView *cell = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    UIView *badge = [self addViewWithFrame:CGRectMake(0, 0, 60, 20) toView:cell];
    [badge growingMarkImpression:@"imp_badge" attributes:@{@"goods": @"a"} identifier:@"goods_a" config:nil];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    cell.frame = CGRectMake(0, 700, 375, 100);
    [self pumpRunLoopFor:0.3];

    [badge growingMarkImpression:@"imp_badge" attributes:@{@"goods": @"b"} identifier:@"goods_b" config:nil];
    cell.frame = CGRectMake(0, 0, 375, 100);
    [self pumpRunLoopFor:0.6];

    XCTAssertEqual([self customEventCount], 2);
    XCTAssertEqualObjects(self.lastCustomEvent.attributes[@"goods"], @"b");
}

- (void)testDifferentEventNamesOnOneViewSurviveRemarking {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 700, 375, 100)];
    [view growingMarkImpression:@"imp_card" attributes:nil identifier:@"card_1" config:nil];
    [view growingMarkImpression:@"imp_badge" attributes:nil identifier:@"badge_1" config:nil];
    [view growingMarkImpression:@"imp_card" attributes:nil identifier:@"card_2" config:nil];

    view.frame = CGRectMake(0, 0, 375, 100);
    [self pumpRunLoopFor:0.6];

    XCTAssertEqual([self customEventCount], 2);
}

- (void)testDeallocatedViewLeavesDetectionSet {
    __weak UIView *weakView = nil;
    @autoreleasepool {
        UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
        [view growingMarkImpression:@"imp_dealloc"];
        XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
        weakView = view;
        [view removeFromSuperview];
    }

    [self pumpRunLoopFor:0.3];
    XCTAssertNil(weakView);
}

@end
