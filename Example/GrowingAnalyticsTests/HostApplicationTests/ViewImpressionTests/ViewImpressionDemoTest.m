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
#import "Modules/ViewImpression/Public/GrowingViewImpression.h"

@interface ViewImpressionDemoTest : XCTestCase

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *controller;

@end

@implementation ViewImpressionDemoTest

- (void)setUp {
    [super setUp];
    // 不可重复曝光的记录是模块的全局状态，不清会被同进程里先跑的用例耗掉
    [GrowingViewImpression resetAllViewImpressionState];
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
    self.controller = nil;
    [GrowingViewImpression resetAllViewImpressionState];
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

    [self resetCapturedEvents];
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

/// 逐屏走完整页，每个演示区都应当至少产生一次曝光——
/// 任何一个区块的标记写错，这里就会缺事件
- (void)testEverySectionProducesImpression {
    [self loadDemoPage];

    UIScrollView *page = [self pageScrollView];
    [self pumpRunLoop:2.5];  // 顶部几个区块 + 停留时长 2 秒的那张卡片

    CGFloat viewport = CGRectGetHeight(page.bounds);
    for (CGFloat offset = 0; offset < page.contentSize.height - viewport; offset += viewport / 3) {
        page.contentOffset = CGPointMake(0, offset);
        [self pumpRunLoop:0.35];
    }

    UIScrollView *horizontal = (UIScrollView *)[self descendantOfClass:UIScrollView.class
                                                              matching:^BOOL(UIView *view) {
                                                                  UIScrollView *sv = (UIScrollView *)view;
                                                                  return sv.contentSize.width > sv.contentSize.height;
                                                              }];
    XCTAssertNotNil(horizontal);
    for (CGFloat offset = 0; offset < horizontal.contentSize.width; offset += 200) {
        horizontal.contentOffset = CGPointMake(offset, 0);
        [self pumpRunLoop:0.25];
    }

    for (UIView *view in @[[self rowTableView] ?: NSNull.null, [self badgeTableView] ?: NSNull.null]) {
        if (![view isKindOfClass:UITableView.class]) {
            continue;
        }
        [self scrollPageToView:view dwell:0.3];
        UITableView *table = (UITableView *)view;
        for (CGFloat offset = 0; offset <= 600; offset += 150) {
            table.contentOffset = CGPointMake(0, offset);
            [self pumpRunLoop:0.25];
        }
    }

    NSSet<NSString *> *expected = [NSSet setWithArray:@[
        @"imp_basic",
        @"imp_scale_50",
        @"imp_scale_100",
        @"imp_stay_2s",
        @"imp_once",
        @"imp_slot_a",
        @"imp_slot_b",
        @"imp_update",
        @"imp_horizontal",
        @"imp_list_row",
        @"imp_badge",
    ]];
    NSMutableSet<NSString *> *missing = expected.mutableCopy;
    [missing minusSet:[self capturedEventNames]];
    XCTAssertEqual(missing.count, 0, @"以下演示区没有产生曝光：%@", missing.allObjects);
}

/// 否决开关：shouldTrack 返回 NO 时整页都不应发送
- (void)testVetoSwitchSuppressesImpressions {
    [self loadDemoPage];
    [self vetoSwitch].on = YES;
    [self resetCapturedEvents];

    UIScrollView *page = [self pageScrollView];
    for (CGFloat offset = 0; offset < 1200; offset += 300) {
        page.contentOffset = CGPointMake(0, offset);
        [self pumpRunLoop:0.3];
    }

    // 宿主 App 自身也会发自定义事件（APM 等），只看本页的
    NSMutableSet<NSString *> *impressionEvents = [self capturedEventNames].mutableCopy;
    [impressionEvents filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH 'imp_'"]];
    XCTAssertEqual(impressionEvents.count, 0, @"否决开关打开后仍有曝光：%@", impressionEvents.allObjects);
}

/// 动态属性开关：曝光事件里应当出现回调补充的属性
- (void)testDynamicAttributeSwitchAddsAttribute {
    [self loadDemoPage];
    [self dynamicSwitch].on = YES;
    [self resetCapturedEvents];

    UIScrollView *page = [self pageScrollView];
    page.contentOffset = CGPointMake(0, 400);
    [self pumpRunLoop:0.5];
    page.contentOffset = CGPointZero;
    [self pumpRunLoop:0.5];

    GrowingCustomEvent *event = [self lastEventNamed:@"imp_basic"];
    XCTAssertNotNil(event);
    XCTAssertNotNil(event.attributes[@"dynamic_timestamp"]);
}

/// 移除 slot_a 按钮：同一视图上另一个槽位不受影响
- (void)testRemoveSlotAButtonKeepsOtherSlot {
    [self loadDemoPage];

    UIView *card = [self cardLabeled:@"imp_slot_a + imp_slot_b"];
    XCTAssertNotNil(card);
    [self scrollPageToView:card dwell:0.5];

    NSSet<NSString *> *before = [self capturedEventNames];
    XCTAssertTrue([before containsObject:@"imp_slot_a"]);
    XCTAssertTrue([before containsObject:@"imp_slot_b"]);

    [[self buttonWithTitlePrefix:@"移除 slot_a"] sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self resetCapturedEvents];

    UIScrollView *page = [self pageScrollView];
    page.contentOffset = CGPointZero;
    [self pumpRunLoop:0.4];
    [self scrollPageToView:card dwell:0.5];

    NSSet<NSString *> *after = [self capturedEventNames];
    XCTAssertTrue([after containsObject:@"imp_slot_b"]);
    XCTAssertFalse([after containsObject:@"imp_slot_a"], @"slot_a 已移除却仍在发送");
}

/// 更新属性按钮：不产生新曝光，但下一次曝光带上新值
- (void)testUpdateAttributesButtonDoesNotRefire {
    [self loadDemoPage];

    UIView *card = [self cardLabeled:@"imp_update"];
    XCTAssertNotNil(card);
    [self scrollPageToView:card dwell:0.5];
    XCTAssertNotNil([self lastEventNamed:@"imp_update"]);

    [self resetCapturedEvents];
    [[self buttonWithTitlePrefix:@"更新属性"] sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self pumpRunLoop:0.5];
    XCTAssertNil([self lastEventNamed:@"imp_update"], @"更新属性不应触发重新曝光");

    UIScrollView *page = [self pageScrollView];
    page.contentOffset = CGPointZero;
    [self pumpRunLoop:0.4];
    [self scrollPageToView:card dwell:0.5];

    XCTAssertEqualObjects([self lastEventNamed:@"imp_update"].attributes[@"count"], @"1");
}

/// 重置状态按钮：只曝光一次的元素可以再次曝光
- (void)testResetStateButtonAllowsRefire {
    [self loadDemoPage];

    UIView *card = [self cardLabeled:@"imp_once"];
    XCTAssertNotNil(card);
    [self scrollPageToView:card dwell:0.5];
    XCTAssertNotNil([self lastEventNamed:@"imp_once"]);

    [self resetCapturedEvents];
    [[self buttonWithTitlePrefix:@"重置状态"] sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self pumpRunLoop:0.5];

    XCTAssertNotNil([self lastEventNamed:@"imp_once"], @"重置后应当可以再次曝光");
}

#pragma mark - Helper

/// cleanQueue 是异步的，读一次事件数作为屏障，确保清空先于后续断言生效
- (void)resetCapturedEvents {
    [MockEventQueue.sharedQueue cleanQueue];
    (void)[MockEventQueue.sharedQueue eventCount];
}

- (NSSet<NSString *> *)capturedEventNames {
    NSMutableSet<NSString *> *names = [NSMutableSet set];
    for (GrowingCustomEvent *event in [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom]) {
        [names addObject:event.eventName];
    }
    return names;
}

- (GrowingCustomEvent *)lastEventNamed:(NSString *)eventName {
    GrowingCustomEvent *found = nil;
    for (GrowingCustomEvent *event in [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom]) {
        if ([event.eventName isEqualToString:eventName]) {
            found = event;
        }
    }
    return found;
}

- (UIView *)descendantOfClass:(Class)klass matching:(BOOL (^)(UIView *view))predicate {
    NSMutableArray<UIView *> *queue = [NSMutableArray arrayWithObject:self.controller.view];
    while (queue.count > 0) {
        UIView *view = queue.firstObject;
        [queue removeObjectAtIndex:0];
        if ([view isKindOfClass:klass] && (!predicate || predicate(view))) {
            return view;
        }
        [queue addObjectsFromArray:view.subviews];
    }
    return nil;
}

- (UIButton *)buttonWithTitlePrefix:(NSString *)prefix {
    return (UIButton *)[self descendantOfClass:UIButton.class
                                      matching:^BOOL(UIView *view) {
                                          return [[(UIButton *)view currentTitle] hasPrefix:prefix];
                                      }];
}

- (NSArray<UISwitch *> *)panelSwitches {
    NSMutableArray<UISwitch *> *result = [NSMutableArray array];
    NSMutableArray<UIView *> *queue = [NSMutableArray arrayWithObject:self.controller.view];
    while (queue.count > 0) {
        UIView *view = queue.firstObject;
        [queue removeObjectAtIndex:0];
        if ([view isKindOfClass:UISwitch.class]) {
            [result addObject:(UISwitch *)view];
        }
        [queue addObjectsFromArray:view.subviews];
    }
    return result;
}

/// 顺序与面板一致：第一个是否决开关，第二个是动态属性开关
- (UISwitch *)vetoSwitch {
    return [self panelSwitches].firstObject;
}

- (UISwitch *)dynamicSwitch {
    return [self panelSwitches].lastObject;
}

- (UIView *)cardLabeled:(NSString *)prefix {
    UILabel *label = (UILabel *)[self descendantOfClass:UILabel.class
                                               matching:^BOOL(UIView *view) {
                                                   return [[(UILabel *)view text] hasPrefix:prefix];
                                               }];
    return label.superview;
}

- (void)scrollPageToView:(UIView *)view dwell:(NSTimeInterval)seconds {
    UIScrollView *page = [self pageScrollView];
    CGRect frame = [view convertRect:view.bounds toView:page];
    CGFloat offset = MAX(0, CGRectGetMidY(frame) - CGRectGetHeight(page.bounds) / 2);
    page.contentOffset = CGPointMake(0, MIN(offset, page.contentSize.height - CGRectGetHeight(page.bounds)));
    [self pumpRunLoop:seconds];
}

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

- (UITableView *)rowTableView {
    return (UITableView *)[self descendantOfClass:UITableView.class
                                         matching:^BOOL(UIView *view) {
                                             return view.tag != 1;
                                         }];
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
