//
//  ViewImpressionConditionTests.m
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
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "Modules/ViewImpression/Public/GrowingViewImpression.h"
#import "Modules/ViewImpression/Public/UIView+GrowingViewImpression.h"
#import "ViewImpressionTestCase.h"

static const CGRect kOnscreen = {{0, 0}, {375, 100}};
static const CGRect kOffscreen = {{0, 700}, {375, 100}};
/// 一半落在 window 内，可见面积占比 0.5
static const CGRect kHalfOnscreen = {{0, 617}, {375, 100}};

@interface GrowingViewImpression (XCTest)

@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *trackedIdentifiers;

- (void)rememberTrackedIdentifier:(NSString *)identifier;

@end

@interface ViewImpressionConditionTests : ViewImpressionTestCase

@property (nonatomic, copy) GrowingViewImpressionConfig *savedGlobalConfig;

@end

@implementation ViewImpressionConditionTests

- (void)setUp {
    [super setUp];
    self.savedGlobalConfig = GrowingConfigurationManager.sharedInstance.trackConfiguration.viewImpressionConfig;
}

- (void)tearDown {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.viewImpressionConfig = self.savedGlobalConfig;
    [super tearDown];
}

- (GrowingViewImpressionConfig *)configWithStayDuration:(NSTimeInterval)stayDuration {
    return [GrowingViewImpressionConfig configWithViewImpressionScale:0.0f stayDuration:stayDuration repeatable:YES];
}

- (GrowingViewImpressionConfig *)nonRepeatableConfig {
    return [GrowingViewImpressionConfig configWithViewImpressionScale:0.0f stayDuration:0.0 repeatable:NO];
}

#pragma mark - stayDuration

- (void)testStayDurationNotReachedBeforeLeaving {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_stay_leave"
                     attributes:nil
                     identifier:nil
                         config:[self configWithStayDuration:0.5]];

    [self pumpRunLoopFor:0.2];
    view.frame = kOffscreen;

    [self assertNoMoreCustomEventsWithin:0.8];
}

- (void)testStayDurationReachedOnStaticScreen {
    // 界面全程静止，没有任何布局变化，只能靠定时复检收口。
    // 真机上 runloop 的休眠行为与此处不完全一致，静止场景仍需 UI 测试复核
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_stay_reached"
                     attributes:nil
                     identifier:nil
                         config:[self configWithStayDuration:0.3]];

    XCTAssertEqual([self customEventCount], 0);
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.eventName, @"imp_stay_reached");
}

- (void)testRepeatedReentryDoesNotAccumulateRechecks {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_stay_reentry"
                     attributes:nil
                     identifier:nil
                         config:[self configWithStayDuration:0.3]];

    for (NSUInteger i = 0; i < 3; i++) {
        [self pumpRunLoopFor:0.1];
        view.frame = kOffscreen;
        [self pumpRunLoopFor:0.1];
        view.frame = kOnscreen;
    }

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    [self assertNoMoreCustomEventsWithin:0.5];
}

#pragma mark - repeatable

- (void)testNonRepeatableSuppressesSecondViewWithSameIdentifier {
    UIView *first = [self addViewWithFrame:kOnscreen];
    [first growingMarkImpression:@"imp_sku" attributes:nil identifier:@"sku_1" config:[self nonRepeatableConfig]];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [first growingUnmarkImpression];
    [first removeFromSuperview];

    UIView *second = [self addViewWithFrame:kOnscreen];
    [second growingMarkImpression:@"imp_sku" attributes:nil identifier:@"sku_1" config:[self nonRepeatableConfig]];

    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testNonRepeatableAllowsDifferentIdentifierOnReusedView {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_sku" attributes:nil identifier:@"sku_1" config:[self nonRepeatableConfig]];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [view growingUnmarkImpression];
    [view growingMarkImpression:@"imp_sku" attributes:nil identifier:@"sku_2" config:[self nonRepeatableConfig]];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
}

- (void)testNonRepeatableWithoutIdentifierIsDowngraded {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_no_identifier" attributes:nil identifier:nil config:[self nonRepeatableConfig]];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    view.frame = kOffscreen;
    [self pumpRunLoopFor:0.3];
    view.frame = kOnscreen;

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
}

- (void)testNonRepeatableRecordIgnoresEventName {
    UIView *first = [self addViewWithFrame:kOnscreen];
    [first growingMarkImpression:@"imp_name_a" attributes:nil identifier:@"sku_1" config:[self nonRepeatableConfig]];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [first growingUnmarkImpression];
    [first removeFromSuperview];

    UIView *second = [self addViewWithFrame:kOnscreen];
    [second growingMarkImpression:@"imp_name_b" attributes:nil identifier:@"sku_1" config:[self nonRepeatableConfig]];

    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testResetStateOnlyAffectsMatchingIdentifier {
    UIView *first = [self addViewWithFrame:kOnscreen];
    UIView *second = [self addViewWithFrame:kOnscreen];
    [first growingMarkImpression:@"imp_reset_a" attributes:nil identifier:@"sku_a" config:[self nonRepeatableConfig]];
    [second growingMarkImpression:@"imp_reset_b" attributes:nil identifier:@"sku_b" config:[self nonRepeatableConfig]];
    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);

    [GrowingViewImpression resetImpressionStateWithIdentifier:@"sku_a"];

    XCTAssertTrue([self waitForCustomEventCount:3 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.eventName, @"imp_reset_a");
    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testResetStateWithIdentifierAllowsRefire {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_reset" attributes:nil identifier:@"sku_reset" config:[self nonRepeatableConfig]];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [GrowingViewImpression resetImpressionStateWithIdentifier:@"sku_reset"];
    [view growingMarkImpression:@"imp_reset" attributes:nil identifier:@"sku_reset" config:[self nonRepeatableConfig]];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
}

- (void)testResetAllStateAllowsRefire {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_reset_all"
                     attributes:nil
                     identifier:@"sku_reset_all"
                         config:[self nonRepeatableConfig]];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [GrowingViewImpression resetAllImpressionState];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
}

- (void)testTrackedIdentifiersEvictOldestBeyondCapacity {
    GrowingViewImpression *impression = [GrowingViewImpression sharedInstance];
    [impression.trackedIdentifiers removeAllObjects];

    for (NSUInteger i = 0; i < 10001; i++) {
        [impression rememberTrackedIdentifier:[NSString stringWithFormat:@"sku_%lu", (unsigned long)i]];
    }

    XCTAssertEqual(impression.trackedIdentifiers.count, 10000);
    XCTAssertFalse([impression.trackedIdentifiers containsObject:@"sku_0"]);
    XCTAssertTrue([impression.trackedIdentifiers containsObject:@"sku_10000"]);

    [impression.trackedIdentifiers removeAllObjects];
}

#pragma mark - identifier

- (void)testMultipleSlotsOnOneView {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_slot_a" attributes:nil identifier:@"a" config:nil];
    [view growingMarkImpression:@"imp_slot_b" attributes:nil identifier:@"b" config:nil];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
}

- (void)testUnmarkWithIdentifierOnlyRemovesThatSlot {
    UIView *view = [self addViewWithFrame:kOffscreen];
    [view growingMarkImpression:@"imp_slot_a" attributes:nil identifier:@"a" config:nil];
    [view growingMarkImpression:@"imp_slot_b" attributes:nil identifier:@"b" config:nil];
    [view growingUnmarkImpressionWithIdentifier:@"a"];

    view.frame = kOnscreen;

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.eventName, @"imp_slot_b");
    [self assertNoMoreCustomEventsWithin:0.5];
}

#pragma mark - update attributes

- (void)testUpdateAttributesDoesNotRefire {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_update" attributes:@{@"key": @"old"} identifier:nil config:nil];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.attributes[@"key"], @"old");

    [view growingUpdateImpressionAttributes:@{@"key": @"new"} identifier:nil];
    [self assertNoMoreCustomEventsWithin:0.5];
}

- (void)testUpdatedAttributesTakeEffectOnNextImpression {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_update_next" attributes:@{@"key": @"old"} identifier:nil config:nil];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [view growingUpdateImpressionAttributes:@{@"key": @"new"} identifier:nil];
    view.frame = kOffscreen;
    [self pumpRunLoopFor:0.3];
    view.frame = kOnscreen;

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.attributes[@"key"], @"new");
}

- (void)testRemarkingWithPreUpdateAttributesRefires {
    UIView *view = [self addViewWithFrame:kOnscreen];
    [view growingMarkImpression:@"imp_update_remark" attributes:@{@"key": @"old"} identifier:nil config:nil];
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);

    [view growingUpdateImpressionAttributes:@{@"key": @"new"} identifier:nil];
    [view growingMarkImpression:@"imp_update_remark" attributes:@{@"key": @"old"} identifier:nil config:nil];

    XCTAssertTrue([self waitForCustomEventCount:2 timeout:2.0]);
    XCTAssertEqualObjects(self.lastCustomEvent.attributes[@"key"], @"old");
}

#pragma mark - config priority

- (void)testElementConfigAppliesWhenGlobalConfigIsAbsent {
    UIView *view = [self addViewWithFrame:kHalfOnscreen];
    GrowingViewImpressionConfig *config = [GrowingViewImpressionConfig configWithViewImpressionScale:0.9f
                                                                                        stayDuration:0.0
                                                                                          repeatable:YES];
    [view growingMarkImpression:@"imp_scale" attributes:nil identifier:nil config:config];

    [self assertNoMoreCustomEventsWithin:0.5];

    view.frame = kOnscreen;
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
}

- (void)testGlobalConfigAppliesWhenElementConfigIsNil {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.viewImpressionConfig =
        [GrowingViewImpressionConfig configWithViewImpressionScale:0.9f stayDuration:0.0 repeatable:YES];

    UIView *view = [self addViewWithFrame:kHalfOnscreen];
    [view growingMarkImpression:@"imp_global_scale" attributes:nil identifier:nil config:nil];

    [self assertNoMoreCustomEventsWithin:0.5];

    view.frame = kOnscreen;
    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
}

- (void)testElementConfigOverridesGlobalConfig {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.viewImpressionConfig =
        [GrowingViewImpressionConfig configWithViewImpressionScale:0.9f stayDuration:0.0 repeatable:YES];

    UIView *view = [self addViewWithFrame:kHalfOnscreen];
    GrowingViewImpressionConfig *config = [GrowingViewImpressionConfig configWithViewImpressionScale:0.0f
                                                                                        stayDuration:0.0
                                                                                          repeatable:YES];
    [view growingMarkImpression:@"imp_scale_override" attributes:nil identifier:nil config:config];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
}

@end
