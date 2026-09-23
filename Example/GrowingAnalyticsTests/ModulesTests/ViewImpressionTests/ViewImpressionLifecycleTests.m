//
//  ViewImpressionLifecycleTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/22.
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

#import "Modules/ViewImpression/Public/GrowingViewImpression.h"
#import "Modules/ViewImpression/Public/GrowingImpressionConfig.h"
#import "Modules/ViewImpression/Public/UIView+GrowingViewImpression.h"
#import "ViewImpressionTestCase.h"

static const CGRect kOnscreen = {{0, 0}, {375, 100}};

@interface GrowingViewImpression (XCTest)

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

@end

@interface ViewImpressionLifecycleTests : ViewImpressionTestCase

@end

@implementation ViewImpressionLifecycleTests

- (void)tearDown {
    [self becomeActive];
    [super tearDown];
}

/// 直接调用生命周期回调而不广播通知：用例进程里的前后台状态由 XCTest 掌握，
/// 广播无法让 UIApplication 真的退到后台，时序也不可控
- (void)resignActive {
    [[GrowingViewImpression sharedInstance] applicationWillResignActive];
}

- (void)becomeActive {
    [[GrowingViewImpression sharedInstance] applicationDidBecomeActive];
}

- (void)testStillVisibleViewDoesNotRefireAfterReturningToForeground {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingTrackViewImpression:@"imp_foreground"];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [self resignActive];
    [self pumpRunLoopFor:0.3];
    [self becomeActive];

    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testNoImpressionWhileInactive {
    [self resignActive];

    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingTrackViewImpression:@"imp_inactive"];
    [self assertNoMoreCustomEventsWithin:0.5];

    [self becomeActive];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
}

- (void)testStayDurationRestartsAfterReturningToForeground {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingTrackViewImpression:@"imp_stay_foreground"
                     attributes:nil
                     identifier:nil
                         config:[GrowingImpressionConfig configWithImpressionScale:0.0f
                                                                              stayDuration:0.5
                                                                                repeatable:YES]];
    [self pumpRunLoopFor:0.3];
    XCTAssertEqual([self customEventCount], 0);

    [self resignActive];
    [self becomeActive];

    // 此刻已越过退到后台前那次计时的到点时刻，仍未发送，说明计时是从回到前台重新起算的
    [self pumpRunLoopFor:0.35];
    XCTAssertEqual([self customEventCount], 0);

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    [self assertNoMoreCustomEventsWithin:0.3];
}

@end
