//
//  UITapGestureRecognizerAutotrackTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/2/7.
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


#import <KIF/KIF.h>

#import "GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "ManualTrackHelper.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingAutotrackerCore/Autotrack/UITapGestureRecognizer+GrowingAutotracker.h"

// 使用"click请求"页面，测试-[UITapGestureRecognizer growing_initWithCoder:]函数

@interface UITapGestureRecognizerAutotrackTest : KIFTestCase

@end

@implementation UITapGestureRecognizerAutotrackTest

- (void)beforeAll {
    // userId userKey
    [GrowingAutotracker.sharedInstance setLoginUserId:@"xctest_userId" userKey:@"xctest_userKey"];
    // latitude longitude
    [GrowingAutotracker.sharedInstance setLocation:30.12345 longitude:31.123456];
    
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"CLICK请求"] tap];
    [viewTester waitForTimeInterval:1];
}

- (void)afterAll {
    [[viewTester usingLabel:@"协议/接口"] tap];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    
}

- (void)testTapGestureHook {
    // initWithCoder:
    {
        [[viewTester usingLabel:@"singleTapView"] tap];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 1);
        
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    }

    [MockEventQueue.sharedQueue cleanQueue];

    // initWithTarget:action:
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(class)];
        [[viewTester usingLabel:@"doubleTapView"].view addGestureRecognizer:tap];
        [[viewTester usingLabel:@"doubleTapView"] tap];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 1);
        
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    }
}

@end
