//
//  A2PageEventsTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/7/18.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import <KIF/KIF.h>

#import "GrowingAutotracker.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"

@interface A3PageEventsTest : KIFTestCase

@end

@implementation A3PageEventsTest

+ (void)setUp {
    // userId userKey
    [GrowingAutotracker.sharedInstance setLoginUserId:@"xctest_userId" userKey:@"xctest_userKey"];
    // latitude longitude
    [GrowingAutotracker.sharedInstance setLocation:30.12345 longitude:31.123456];
}

- (void)setUp {
    [[viewTester usingLabel:@"协议/接口"] tap];
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    [[viewTester usingLabel:@"协议/接口"] tap];
}

- (void)test01AutotrackPage {
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[viewTester usingLabel:@"Button"] tap];

    {
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
        XCTAssertGreaterThanOrEqual(events.count, 1);

        GrowingPageEvent *event = (GrowingPageEvent *)events.lastObject;
        XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
        XCTAssertEqualObjects(event.path, @"/页面测试");
        XCTAssertEqualObjects(event.attributes[@"key"], @"value");

        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
        XCTAssertTrue([ManualTrackHelper pageEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    }

    {
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertGreaterThanOrEqual(events.count, 3);

        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.lastObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);

        XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
        XCTAssertEqualObjects(dic[@"textValue"], @"Button");
        XCTAssertEqualObjects(
            dic[@"xpath"],
            @"/UITabBarController/UINavigationController/GrowingAutotrackPageViewController/UIView/UIButton");
        XCTAssertEqualObjects(dic[@"xcontent"], @"/0/0/0/0/0");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    }
}

- (void)test02AutotrackPageDelay {
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [[viewTester usingLabel:@"Button"] tap];

    // 立即点击按钮，由于尚未调用autotrackPage，path字段无值
    {
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertGreaterThanOrEqual(events.count, 3);

        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.lastObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);

        XCTAssertEqualObjects(dic[@"path"], @"");
        XCTAssertEqualObjects(dic[@"textValue"], @"Button");
        XCTAssertEqualObjects(
            dic[@"xpath"],
            @"/UITabBarController/UINavigationController/GrowingAutotrackPageViewController/UIView/UIButton");
        XCTAssertEqualObjects(dic[@"xcontent"], @"/0/0/0/0/0");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], nil);
    }

    // demo中在3.0秒后调用autotrackPage，发送PAGE事件，再次点击按钮，path有值
    XCTestExpectation *expectation = [self expectationWithDescription:@"test02AutotrackPageDelay failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
            XCTAssertGreaterThanOrEqual(events.count, 1);

            GrowingPageEvent *event = (GrowingPageEvent *)events.firstObject;
            XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
            XCTAssertEqualObjects(event.path, @"/页面测试");
            XCTAssertEqualObjects(event.attributes[@"key"], @"value");

            NSDictionary *dic = event.toDictionary;
            XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
            XCTAssertTrue([ManualTrackHelper pageEventCheck:dic]);
            XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
            XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
            XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
        }

        [[viewTester usingLabel:@"Button"] tap];

        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
            XCTAssertGreaterThanOrEqual(events.count, 3);

            GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.lastObject;
            NSDictionary *dic = event.toDictionary;
            XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
            XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
            XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);

            XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
            XCTAssertEqualObjects(dic[@"textValue"], @"Button");
            XCTAssertEqualObjects(
                dic[@"xpath"],
                @"/UITabBarController/UINavigationController/GrowingAutotrackPageViewController/UIView/UIButton");
            XCTAssertEqualObjects(dic[@"xcontent"], @"/0/0/0/0/0");
            XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
        }

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test03AutotrackPageWithoutCallSuperViewDidAppear {
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [[viewTester usingLabel:@"Button"] tap];

    // 不兼容在viewDidLoad调用autotrackPage，却未调用super viewDidAppear的情况
    // 此时不会发送PAGE事件，但会将alias与attributes赋值
    {
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertGreaterThanOrEqual(events.count, 0);
    }

    // path、attributes有值
    {
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertGreaterThanOrEqual(events.count, 3);

        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.lastObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);

        XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
        XCTAssertEqualObjects(dic[@"textValue"], @"Button");
        XCTAssertEqualObjects(
            dic[@"xpath"],
            @"/UITabBarController/UINavigationController/GrowingAutotrackPageViewController/UIView/UIButton");
        XCTAssertEqualObjects(dic[@"xcontent"], @"/0/0/0/0/0");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    }
}

- (void)test04AutotrackPageDelayWithoutCallSuperViewDidAppear {
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [[viewTester usingLabel:@"Button"] tap];

    // 立即点击按钮，走findPageByView内部的补page逻辑，由于尚未调用autotrackPage，path字段无值
    {
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertGreaterThanOrEqual(events.count, 3);

        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.lastObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);

        XCTAssertEqualObjects(dic[@"path"], @"");
        XCTAssertEqualObjects(dic[@"textValue"], @"Button");
        XCTAssertEqualObjects(
            dic[@"xpath"],
            @"/UITabBarController/UINavigationController/GrowingAutotrackPageViewController/UIView/UIButton");
        XCTAssertEqualObjects(dic[@"xcontent"], @"/0/0/0/0/0");
        XCTAssertEqualObjects(dic[@"attributes"][@"key"], nil);
    }

    // demo中在3.0秒后调用autotrackPage，由于实际上已经过了viewDidAppear生命周期，所以sdk内部可判断发送PAGE事件，再次点击按钮，path有值
    XCTestExpectation *expectation = [self expectationWithDescription:@"test02AutotrackPageDelay failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
            XCTAssertGreaterThanOrEqual(events.count, 1);

            GrowingPageEvent *event = (GrowingPageEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
            XCTAssertEqualObjects(event.path, @"/页面测试");
            XCTAssertEqualObjects(event.attributes[@"key"], @"value");

            NSDictionary *dic = event.toDictionary;
            XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
            XCTAssertTrue([ManualTrackHelper pageEventCheck:dic]);
            XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
            XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
            XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
        }

        [[viewTester usingLabel:@"Button"] tap];

        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
            XCTAssertGreaterThanOrEqual(events.count, 3);

            GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.lastObject;
            NSDictionary *dic = event.toDictionary;
            XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
            XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
            XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);

            XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
            XCTAssertEqualObjects(dic[@"textValue"], @"Button");
            XCTAssertEqualObjects(
                dic[@"xpath"],
                @"/UITabBarController/UINavigationController/GrowingAutotrackPageViewController/UIView/UIButton");
            XCTAssertEqualObjects(dic[@"xcontent"], @"/0/0/0/0/0");
            XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
        }

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test05AutotrackPageDelayWithoutCallSuperViewDidAppear {
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [[viewTester usingLabel:@"Button"] tap];

    // 不点击按钮，走autotrackPage内部的补page逻辑

    // demo中在3.0秒后调用autotrackPage，由于实际上已经过了viewDidAppear生命周期，所以sdk内部可判断发送PAGE事件，再次点击按钮，path有值
    XCTestExpectation *expectation = [self expectationWithDescription:@"test02AutotrackPageDelay failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
            XCTAssertGreaterThanOrEqual(events.count, 1);

            GrowingPageEvent *event = (GrowingPageEvent *)events.lastObject;
            XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
            XCTAssertEqualObjects(event.path, @"/页面测试");
            XCTAssertEqualObjects(event.attributes[@"key"], @"value");

            NSDictionary *dic = event.toDictionary;
            XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
            XCTAssertTrue([ManualTrackHelper pageEventCheck:dic]);
            XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
            XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
            XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
        }

        [[viewTester usingLabel:@"Button"] tap];

        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
            XCTAssertGreaterThanOrEqual(events.count, 3);

            GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.lastObject;
            NSDictionary *dic = event.toDictionary;
            XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
            XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
            XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);

            XCTAssertEqualObjects(dic[@"path"], @"/页面测试");
            XCTAssertEqualObjects(dic[@"textValue"], @"Button");
            XCTAssertEqualObjects(
                dic[@"xpath"],
                @"/UITabBarController/UINavigationController/GrowingAutotrackPageViewController/UIView/UIButton");
            XCTAssertEqualObjects(dic[@"xcontent"], @"/0/0/0/0/0");
            XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
        }

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

@end
