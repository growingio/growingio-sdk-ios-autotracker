//
//  UIApplicationAutotrackTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/24.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingServiceManager.h"
#import "GrowingEventDatabaseService.h"
#import "Services/Database/GrowingEventFMDatabase.h"
#import "GrowingAutotrackerCore/Autotrack/UIApplication+GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "InvocationHelper.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"

// 需要有HostApplication，不然UIApplication.sharedApplication为nil

// 可配置growingNodeDonotTrack，从而配置可否生成VIEW_CLICK，以供测试
#define AutotrackXCTestClassDefine(cls)                                         \
@interface Autotrack##cls##_XCTest : cls                                        \
@property(nonatomic, assign) BOOL growingNodeDonotTrack_XCTest;                 \
@end                                                                            \
@implementation Autotrack##cls##_XCTest                                         \
@end                                                                            \
@implementation Autotrack##cls##_XCTest (DonotTrack)                            \
- (BOOL)growingNodeDonotTrack { return self.growingNodeDonotTrack_XCTest; }     \
@end

AutotrackXCTestClassDefine(UITabBarItem)
AutotrackXCTestClassDefine(UIBarButtonItem)
AutotrackXCTestClassDefine(UISegmentedControl)
AutotrackXCTestClassDefine(UISwitch)
AutotrackXCTestClassDefine(UIStepper)
AutotrackXCTestClassDefine(UIPageControl)

@interface UIApplicationAutotrackTest : XCTestCase

@property (nonatomic, strong) UIEvent *event;
@property (nonatomic, strong) AutotrackUITabBarItem_XCTest *tabBarItem;
@property (nonatomic, strong) AutotrackUIBarButtonItem_XCTest *barButtonItem;
@property (nonatomic, strong) AutotrackUISegmentedControl_XCTest *segmentedControl;
@property (nonatomic, strong) AutotrackUISwitch_XCTest *switchT;
@property (nonatomic, strong) AutotrackUIStepper_XCTest *stepper;
@property (nonatomic, strong) AutotrackUIPageControl_XCTest *pageControl;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation UIApplicationAutotrackTest

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
    self.event = UIEvent.new;
}

- (void)tearDown {
}

- (void)testSendEvent {
    [UIApplication.sharedApplication sendEvent:self.event];
}

- (void)testUITabBarAction {
    self.switchT = AutotrackUISwitch_XCTest.new;
    self.switchT.growingNodeDonotTrack_XCTest = NO;

    [UIApplication.sharedApplication sendAction:@selector(class)
                                             to:UITabBar.new
                                           from:self.switchT
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 1);
    };
    [self dispatchInNotMainThread:block];
}

- (void)testUITabBarControllerAction {
    self.switchT = AutotrackUISwitch_XCTest.new;
    self.switchT.growingNodeDonotTrack_XCTest = NO;

    [UIApplication.sharedApplication sendAction:@selector(class)
                                             to:UITabBarController.new
                                           from:self.switchT
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 1);
    };
    [self dispatchInNotMainThread:block];
}

- (void)testUITabBarItemAction {
    self.tabBarItem = AutotrackUITabBarItem_XCTest.new;
    self.tabBarItem.growingNodeDonotTrack_XCTest = NO;

    [UIApplication.sharedApplication sendAction:@selector(tabBarItemAction:)
                                             to:self
                                           from:self.tabBarItem
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 0);
    };
    [self dispatchInNotMainThread:block];
}

- (void)testUIBarButtonItemAction {
    self.barButtonItem = AutotrackUIBarButtonItem_XCTest.new;
    self.barButtonItem.growingNodeDonotTrack_XCTest = NO;
    
    [UIApplication.sharedApplication sendAction:@selector(barButtonItemAction:)
                                             to:self
                                           from:self.barButtonItem
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 0);
    };
    [self dispatchInNotMainThread:block];
}

- (void)testUISegmentedControlAction {
    self.segmentedControl = AutotrackUISegmentedControl_XCTest.new;
    self.segmentedControl.growingNodeDonotTrack_XCTest = NO;
    
    [UIApplication.sharedApplication sendAction:@selector(segmentedControlAction:)
                                             to:self
                                           from:self.segmentedControl
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 0);
    };
    [self dispatchInNotMainThread:block];
}

- (void)testUISwitchAction {
    self.switchT = AutotrackUISwitch_XCTest.new;
    self.switchT.growingNodeDonotTrack_XCTest = NO;
    
    [UIApplication.sharedApplication sendAction:@selector(switchAction:)
                                             to:self
                                           from:self.switchT
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 1);
    };
    [self dispatchInNotMainThread:block];
}

- (void)testUIStepperAction {
    self.stepper = AutotrackUIStepper_XCTest.new;
    self.stepper.growingNodeDonotTrack_XCTest = NO;
    
    [UIApplication.sharedApplication sendAction:@selector(stepperAction:)
                                             to:self
                                           from:self.stepper
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 1);
    };
    [self dispatchInNotMainThread:block];
}

- (void)testUIPageControlAction {
    self.pageControl = AutotrackUIPageControl_XCTest.new;
    self.pageControl.growingNodeDonotTrack_XCTest = NO;
    
    [UIApplication.sharedApplication sendAction:@selector(pageControlAction:)
                                             to:self
                                           from:self.pageControl
                                       forEvent:self.event];
    dispatch_block_t block = ^{
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 1);
    };
    [self dispatchInNotMainThread:block];
}

#pragma mark - Action

- (void)tabBarItemAction:(id)sender {
    XCTAssertEqualObjects(sender, self.tabBarItem);
}

- (void)barButtonItemAction:(id)sender {
    XCTAssertEqualObjects(sender, self.barButtonItem);
}

- (void)segmentedControlAction:(id)sender {
    XCTAssertEqualObjects(sender, self.segmentedControl);
}

- (void)switchAction:(id)sender {
    XCTAssertEqualObjects(sender, self.switchT);
}

- (void)stepperAction:(id)sender {
    XCTAssertEqualObjects(sender, self.stepper);
}

- (void)pageControlAction:(id)sender {
    XCTAssertEqualObjects(sender, self.pageControl);
}

#pragma mark - Private Methods

- (void)dispatchInNotMainThread:(dispatch_block_t)block {
    if (!block) {
        return;
    }
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatchInNotMainThread failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        block();
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:100.0f handler:nil];
}

@end

#pragma clang diagnostic pop
