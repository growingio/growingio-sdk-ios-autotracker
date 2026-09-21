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

@end

@implementation ViewImpressionDemoTest

- (void)setUp {
    [super setUp];
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
    [MockEventQueue.sharedQueue cleanQueue];
    [super tearDown];
}

/// 守住 demo 页与 storyboard 的接线：场景标识、自定义类、页面内的曝光标记
- (void)testDemoPageProducesImpressions {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UICatalogTests" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewImpressionDemo"];
    XCTAssertEqualObjects(NSStringFromClass(controller.class), @"GIOViewImpressionViewController");

    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    [controller.view layoutIfNeeded];

    XCTAssertTrue([MockEventQueue.sharedQueue waitForEventsFor:GrowingEventTypeCustom count:1 timeout:5.0]);

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    NSMutableSet<NSString *> *eventNames = [NSMutableSet set];
    for (GrowingCustomEvent *event in events) {
        [eventNames addObject:event.eventName];
    }
    XCTAssertTrue([eventNames containsObject:@"imp_basic"], @"实际捕获：%@", eventNames);
}

@end
