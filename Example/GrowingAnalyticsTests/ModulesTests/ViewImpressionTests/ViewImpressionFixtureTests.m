//
//  ViewImpressionFixtureTests.m
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

#import "ViewImpressionTestCase.h"

@interface ViewImpressionFixtureTests : ViewImpressionTestCase

@end

@implementation ViewImpressionFixtureTests

- (void)testWindowIsOnScreen {
    XCTAssertNotNil(self.window);
    XCTAssertFalse(self.window.hidden);
    XCTAssertEqualObjects(self.rootView.window, self.window);
}

- (void)testAddedViewJoinsWindowHierarchy {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 100, 100)];
    XCTAssertEqualObjects(view.window, self.window);
}

- (void)testScrollViewClipsOutOfBoundsSubview {
    UIScrollView *scrollView = [self addScrollViewWithFrame:CGRectMake(0, 100, 375, 200)
                                                contentSize:CGSizeMake(375, 1000)];
    UIView *view = [self addViewWithFrame:CGRectMake(0, 800, 375, 100) toView:scrollView];

    XCTAssertTrue(scrollView.clipsToBounds);
    XCTAssertTrue(
        CGRectIsEmpty(CGRectIntersection([view convertRect:view.bounds toView:scrollView], scrollView.bounds)));
}

- (void)testRunLoopPumpAdvancesTime {
    NSTimeInterval start = CACurrentMediaTime();
    [self pumpRunLoopFor:0.1];
    XCTAssertGreaterThanOrEqual(CACurrentMediaTime() - start, 0.1);
}

@end
