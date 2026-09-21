//
//  ViewImpressionDemoTest.m
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

#import <XCTest/XCTest.h>

#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "MockEventQueue.h"

@interface ViewImpressionDemoTest : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *controller;

@end

@implementation ViewImpressionDemoTest

- (void)setUp {
    [super setUp];
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
    self.controller = nil;
    [MockEventQueue.sharedQueue cleanQueue];
    [super tearDown];
}

/// 守住 demo 页与 storyboard 的接线：场景标识、自定义类、页面内的曝光标记
- (void)testDemoPageProducesImpressions {
    [self loadDemoPage];

    XCTAssertTrue([MockEventQueue.sharedQueue waitForEventsFor:GrowingEventTypeCustom count:1 timeout:5.0]);

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    NSMutableSet<NSString *> *eventNames = [NSMutableSet set];
    for (GrowingCustomEvent *event in events) {
        [eventNames addObject:event.eventName];
    }
    XCTAssertTrue([eventNames containsObject:@"imp_basic"], @"实际捕获：%@", eventNames);
}

/// 复用 cell 的子视图：滚动列表让角标视图被反复复用，
/// 每个商品的角标应当只曝光一次，不会带着上一行的属性重复发送
- (void)testReusedCellSubviewProducesOneImpressionPerGoods {
    [self loadDemoPage];

    UIScrollView *page = [self pageScrollView];
    UITableView *badgeList = [self badgeTableView];
    XCTAssertNotNil(badgeList);

    CGRect listFrame = [badgeList convertRect:badgeList.bounds toView:page];
    page.contentOffset = CGPointMake(0, listFrame.origin.y - 20);
    [self pumpRunLoop:0.4];

    [MockEventQueue.sharedQueue cleanQueue];
    for (NSInteger offset = 0; offset <= 900; offset += 150) {
        badgeList.contentOffset = CGPointMake(0, offset);
        [self pumpRunLoop:0.3];
    }

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    NSMutableArray<NSString *> *badgeGoods = [NSMutableArray array];
    for (GrowingCustomEvent *event in events) {
        if ([event.eventName isEqualToString:@"imp_badge"]) {
            [badgeGoods addObject:event.attributes[@"goods_id"]];
        }
    }

    XCTAssertGreaterThan(badgeGoods.count, 0, @"角标没有产生任何曝光");
    XCTAssertEqual(badgeGoods.count,
                   [NSSet setWithArray:badgeGoods].count,
                   @"出现重复的 goods_id，说明复用视图上残留了旧槽位：%@",
                   badgeGoods);
}

#pragma mark - Helper

- (void)loadDemoPage {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UICatalogTests" bundle:nil];
    self.controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewImpressionDemo"];
    XCTAssertEqualObjects(NSStringFromClass(self.controller.class), @"GIOViewImpressionViewController");

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    self.window.rootViewController = self.controller;
    [self.window makeKeyAndVisible];
    [self.controller.view layoutIfNeeded];
}

- (UIScrollView *)pageScrollView {
    for (UIView *view in self.controller.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class] && ![view isKindOfClass:UITableView.class]) {
            return (UIScrollView *)view;
        }
    }
    return nil;
}

- (UITableView *)badgeTableView {
    NSMutableArray<UIView *> *queue = [NSMutableArray arrayWithObject:self.controller.view];
    while (queue.count > 0) {
        UIView *view = queue.firstObject;
        [queue removeObjectAtIndex:0];
        if ([view isKindOfClass:UITableView.class] && view.tag == 1) {
            return (UITableView *)view;
        }
        [queue addObjectsFromArray:view.subviews];
    }
    return nil;
}

- (void)pumpRunLoop:(NSTimeInterval)seconds {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:seconds];
    while (deadline.timeIntervalSinceNow > 0) {
        NSDate *slice = [NSDate dateWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[deadline earlierDate:slice]];
    }
}

@end
