//
//  ViewImpressionTestCase.m
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
#import "GrowingAutotracker.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "MockEventQueue.h"
#import "Modules/ViewImpression/Public/GrowingViewImpression.h"

static const CGFloat kWindowWidth = 375.0f;
static const CGFloat kWindowHeight = 667.0f;

@interface ViewImpressionTestCase ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *rootView;

@end

@implementation ViewImpressionTestCase

+ (void)setUp {
    [super setUp];

    // 整套用例跑时 SDK 已由 A0GrowingAnalyticsTest 启动，单独跑本组用例时在此补启动，
    // 否则模块的 growingModInit 不会执行，检测循环不存在
    if (![GrowingAutotracker isInitializedSuccessfully]) {
        GrowingAutotrackConfiguration *configuration =
            [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
        configuration.dataSourceId = @"test";
        configuration.urlScheme = @"growing.xctest";
        [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
    }
}

- (void)setUp {
    [super setUp];

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];
    self.rootView = self.window.rootViewController.view;
    self.rootView.frame = self.window.bounds;

    [MockEventQueue.sharedQueue cleanQueue];
    [GrowingViewImpression resetAllImpressionState];
}

- (void)tearDown {
    self.window.hidden = YES;
    self.rootView = nil;
    self.window = nil;
    [MockEventQueue.sharedQueue cleanQueue];

    [super tearDown];
}

- (UIView *)addViewWithFrame:(CGRect)frame {
    return [self addViewWithFrame:frame toView:self.rootView];
}

- (UIView *)addViewWithFrame:(CGRect)frame toView:(UIView *)parent {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = UIColor.redColor;
    [parent addSubview:view];
    return view;
}

- (UIScrollView *)addScrollViewWithFrame:(CGRect)frame contentSize:(CGSize)contentSize {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.contentSize = contentSize;
    scrollView.clipsToBounds = YES;
    [self.rootView addSubview:scrollView];
    return scrollView;
}

- (void)pumpRunLoopFor:(NSTimeInterval)seconds {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:seconds];
    while (deadline.timeIntervalSinceNow > 0) {
        // 每片都让 runloop 真正进入等待，检测循环所依赖的 BeforeWaiting 才会触发
        NSDate *slice = [NSDate dateWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[deadline earlierDate:slice]];
    }
}

- (BOOL)waitForCustomEventCount:(NSUInteger)count timeout:(NSTimeInterval)timeout {
    return [MockEventQueue.sharedQueue waitForEventsFor:GrowingEventTypeCustom count:count timeout:timeout];
}

- (NSUInteger)customEventCount {
    return [MockEventQueue.sharedQueue eventCountFor:GrowingEventTypeCustom];
}

- (nullable GrowingCustomEvent *)lastCustomEvent {
    return (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
}

- (void)assertNoMoreCustomEventsWithin:(NSTimeInterval)seconds {
    NSUInteger before = [self customEventCount];
    [self pumpRunLoopFor:seconds];
    XCTAssertEqual([self customEventCount], before);
}

@end
