//
//  ViewImpressionVisibilityTests.m
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

#import "Modules/ViewImpression/UIView+GrowingViewImpressionInternal.h"
#import "ViewImpressionTestCase.h"

@interface ViewImpressionVisibilityTests : ViewImpressionTestCase

@end

@implementation ViewImpressionVisibilityTests

- (void)testFullyVisibleView {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];

    XCTAssertTrue([view growingViewImpNodeIsVisibleWithScale:0.0f]);
    XCTAssertTrue([view growingViewImpNodeIsVisibleWithScale:0.5f]);
    XCTAssertTrue([view growingViewImpNodeIsVisibleWithScale:1.0f]);
}

- (void)testHiddenView {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    view.hidden = YES;

    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.0f]);
}

- (void)testTransparentView {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    view.alpha = 0.0;

    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.0f]);
}

- (void)testViewOutOfWindowHierarchy {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 100)];

    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.0f]);
}

- (void)testEmptyBounds {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 0, 0)];

    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.0f]);
}

- (void)testHiddenAncestor {
    UIView *container = [self addViewWithFrame:CGRectMake(0, 0, 375, 200)];
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100) toView:container];
    container.hidden = YES;

    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.0f]);
}

- (void)testViewCompletelyBelowWindow {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 700, 375, 100)];

    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.0f]);
}

- (void)testScaleThresholdOnPartiallyVisibleView {
    // window 高 667，视图从 617 起高 100，正好露出一半
    UIView *view = [self addViewWithFrame:CGRectMake(0, 617, 375, 100)];

    XCTAssertTrue([view growingViewImpNodeIsVisibleWithScale:0.0f]);
    XCTAssertTrue([view growingViewImpNodeIsVisibleWithScale:0.5f]);
    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.6f]);
    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:1.0f]);
}

- (void)testClippedByScrollViewWhileStillWithinWindow {
    UIScrollView *scrollView = [self addScrollViewWithFrame:CGRectMake(0, 100, 375, 200)
                                                contentSize:CGSizeMake(375, 1000)];
    UIView *view = [self addViewWithFrame:CGRectMake(0, 400, 375, 100) toView:scrollView];

    // 视图在 window 坐标系内完整落在屏幕中，只按屏幕求交会误判为可见
    CGRect frameInWindow = [view convertRect:view.bounds toView:self.window];
    XCTAssertTrue(CGRectContainsRect(self.window.bounds, frameInWindow));

    XCTAssertFalse([view growingViewImpNodeIsVisibleWithScale:0.0f]);
}

- (void)testVisibleAfterScrollingIntoContainer {
    UIScrollView *scrollView = [self addScrollViewWithFrame:CGRectMake(0, 100, 375, 200)
                                                contentSize:CGSizeMake(375, 1000)];
    UIView *view = [self addViewWithFrame:CGRectMake(0, 400, 375, 100) toView:scrollView];
    scrollView.contentOffset = CGPointMake(0, 400);

    XCTAssertTrue([view growingViewImpNodeIsVisibleWithScale:1.0f]);
}

- (void)testAncestorWithoutClippingDoesNotCut {
    UIView *container = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    container.clipsToBounds = NO;
    UIView *view = [self addViewWithFrame:CGRectMake(0, 150, 375, 100) toView:container];

    XCTAssertTrue([view growingViewImpNodeIsVisibleWithScale:1.0f]);
}

@end
