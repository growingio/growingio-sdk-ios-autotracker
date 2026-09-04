//
//  ImpressionTrackTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/4.
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

#import <XCTest/XCTest.h>

#import "Modules/ImpressionTrack/GrowingImpressionTrack.h"
#import "Modules/ImpressionTrack/Public/UIView+GrowingImpression.h"
#import "Modules/ImpressionTrack/UIView+GrowingImpressionInternal.h"

@interface ImpressionTrackTest : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ImpressionTrackTest

- (void)setUp {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];

    // scrollView 只占屏幕的一小块,可视区为 window 坐标系下的 (0, 100, 300, 200)
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, 300, 200)];
    self.scrollView.contentSize = CGSizeMake(300, 1000);
    [self.window addSubview:self.scrollView];
}

- (void)tearDown {
    for (UIView *subView in self.scrollView.subviews) {
        [subView growingStopTrackImpression];
    }
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    self.window.hidden = YES;
    self.window = nil;
}

- (UIView *)addItemAtContentY:(CGFloat)y {
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, y, 100, 50)];
    [self.scrollView addSubview:item];
    return item;
}

#pragma mark - 可见性判定

- (void)testNodeClippedByScrollViewIsInvisible {
    // contentY 400 => window y 500,已在 scrollView 可视区(100~300)之外,但仍落在屏幕内
    UIView *item = [self addItemAtContentY:400];

    XCTAssertTrue(self.scrollView.clipsToBounds);
    CGRect frameInWindow = [item convertRect:item.bounds toView:self.window];
    XCTAssertTrue(CGRectIntersectsRect(UIScreen.mainScreen.bounds, frameInWindow),
                  @"前置条件:元素 frame 仍落在屏幕内,否则测不到祖先裁剪逻辑");

    XCTAssertFalse([item growingImpNodeIsVisible]);
}

- (void)testNodeInsideScrollViewVisibleRectIsVisible {
    UIView *item = [self addItemAtContentY:10];
    XCTAssertTrue([item growingImpNodeIsVisible]);
}

- (void)testNodeBecomesVisibleAfterScrolling {
    UIView *item = [self addItemAtContentY:400];
    XCTAssertFalse([item growingImpNodeIsVisible]);

    self.scrollView.contentOffset = CGPointMake(0, 400);
    XCTAssertTrue([item growingImpNodeIsVisible]);
}

- (void)testNodeOutsideNonClippingAncestorIsVisible {
    // 祖先不裁剪时元素确实会绘制出来,不应判为不可见
    self.scrollView.clipsToBounds = NO;
    UIView *item = [self addItemAtContentY:400];
    XCTAssertTrue([item growingImpNodeIsVisible]);
}

- (void)testNodeWithHiddenAncestorIsInvisible {
    UIView *item = [self addItemAtContentY:10];
    self.scrollView.hidden = YES;
    XCTAssertFalse([item growingImpNodeIsVisible]);
}

- (void)testNodeWithTransparentAncestorIsInvisible {
    UIView *item = [self addItemAtContentY:10];
    self.scrollView.alpha = 0.0;
    XCTAssertFalse([item growingImpNodeIsVisible]);
}

#pragma mark - 曝光去重

- (void)testRetrackWithoutAttributesKeepsTrackedFlag {
    UIView *item = [self addItemAtContentY:10];
    [item growingTrackImpression:@"imp_track_test"];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[GrowingImpressionTrack sharedInstance] performSelector:@selector(impTrack)];
#pragma clang diagnostic pop

    XCTAssertTrue(item.growingIMPTracked);
    XCTAssertNil(item.growingIMPTrackVariable, @"attributes 为 nil 时不应被写成空字典,否则去重判断失效");

    // 重复调用不应重置已曝光标记,否则滚动过程中每帧都会重复曝光
    [item growingTrackImpression:@"imp_track_test"];
    XCTAssertTrue(item.growingIMPTracked);
}

- (void)testRetrackWithSameAttributesKeepsTrackedFlag {
    UIView *item = [self addItemAtContentY:10];
    [item growingTrackImpression:@"imp_track_test" attributes:@{@"key": @"value"}];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[GrowingImpressionTrack sharedInstance] performSelector:@selector(impTrack)];
#pragma clang diagnostic pop

    XCTAssertTrue(item.growingIMPTracked);

    [item growingTrackImpression:@"imp_track_test" attributes:@{@"key": @"value"}];
    XCTAssertTrue(item.growingIMPTracked);
}

@end
