//
//  AdvertisingTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/1.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingAdvertising.h"
#import "GrowingAutotracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

#import "Modules/Advertising/Event/GrowingAdEventType.h"
#import "Modules/Advertising/Utils/GrowingAdUtils.h"

#import "MockEventQueue.h"

@interface AdvertisingTest : XCTestCase

@end

@implementation AdvertisingTest

- (void)setUp {
    // 恢复为未发送激活事件
    [GrowingAdUtils setActivateWrote:NO];
    [GrowingAdUtils setActivateSent:NO];
    
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
}

- (void)test00SendActivateEvent {
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
    configuration.dataSourceId = @"test";
    configuration.urlScheme = @"growing.530c8231345c492d";
    configuration.readClipboardEnabled = NO;
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"SendActivateEvent Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 给 webView 一点时间
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeActivate];
        XCTAssertEqual(events.count, 1);

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test01SetDataCollectionEnabled {
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:NO];
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:YES];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"SetDataCollectionEnabled Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 给 webView 一点时间
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeActivate];
        XCTAssertEqual(events.count, 1);

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test02SetReadClipboardEnabled {
    [GrowingAdvertising.sharedInstance setReadClipboardEnabled:YES];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        XCTAssertEqual(configuration.readClipboardEnabled, YES);
    }
    waitUntilDone:YES];
}

@end
