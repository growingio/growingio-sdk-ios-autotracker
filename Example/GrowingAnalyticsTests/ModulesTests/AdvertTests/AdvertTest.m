//
//  AdvertTest.m
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

#import "GrowingAutotracker.h"
#import "GrowingAdvertising.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

#import "Modules/Advert/Event/GrowingAdvertEventType.h"
#import "Modules/Advert/Event/GrowingActivateEvent.h"
#import "Modules/Advert/Event/GrowingReengageEvent.h"

#import "MockEventQueue.h"

@interface GrowingAdvertising (Internal)

- (void)loadClipboard;

@end

@interface AdvertTest : XCTestCase

@end

@implementation AdvertTest

+ (void)setUp {
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    configuration.urlScheme = @"growing.530c8231345c492d";
    configuration.autoInstall = YES;
    configuration.readClipBoardEnabled = NO;
    configuration.dataCollectionEnabled = NO;
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {

}

- (void)test01SetDataCollectionEnabled {
    // 恢复为未发送激活事件
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(0) forKey:@"GrowingAdvertisingActivateWrote"];
    [userDefaults synchronize];
    
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:YES];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"SetDataCollectionEnabled Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 给 webView 一点时间
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeActivate];
        XCTAssertEqual(events.count, 1);

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test02TrackAppInstall {
    // 恢复为未发送激活事件
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(0) forKey:@"GrowingAdvertisingActivateWrote"];
    [userDefaults synchronize];
    
    // 修改为非自动发送激活
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    trackConfiguration.autoInstall = NO;
    
    [[GrowingAdvertising sharedInstance] trackAppInstall];
}

- (void)test03TrackAppInstallWithAttributes {
    // 恢复为未发送激活事件
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(0) forKey:@"GrowingAdvertisingActivateWrote"];
    [userDefaults synchronize];
    
    // 修改为非自动发送激活
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    trackConfiguration.autoInstall = NO;
    
    [[GrowingAdvertising sharedInstance] trackAppInstallWithAttributes:@{@"key" : @"value"}];
}

- (void)test04SetReadClipBoardEnabled {
    [[GrowingAdvertising sharedInstance] setReadClipBoardEnabled:YES];
}

- (void)test05DoDeeplinkByUrl_DeepLink {
    // deeplink
    id block = ^(NSDictionary * _Nullable params, NSTimeInterval processTime, NSError * _Nullable error) {
        
    };

    NSString *deeplink = @"growing.deeplink://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937"
                         @"&tm_click=1654775879497&custom_params=%7B%22key%22%3A%22value%22%2C%22key2%22%3A%22value2%22%7D";
    [[GrowingAdvertising sharedInstance] doDeeplinkByUrl:[NSURL URLWithString:deeplink]
                                                callback:block];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"DoDeeplinkByUrl_DeepLink Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 给 webView 一点时间
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeReengage];
        XCTAssertEqual(events.count, 1);
        
        GrowingReengageEvent *event = (GrowingReengageEvent *)events.firstObject;
        NSDictionary *eventDic = event.toDictionary;
        NSDictionary *custom_params = eventDic[@"var"];
        XCTAssertEqualObjects(eventDic[@"link_id"], @"dMbpE");
        XCTAssertEqualObjects(eventDic[@"click_id"], @"85b9310f-d903-4b02-ae7d-3b696e730937");
        XCTAssertEqualObjects(eventDic[@"tm_click"], @"1654775879497");
        XCTAssertEqualObjects(eventDic[@"rngg_mch"], @"url_scheme");
        XCTAssertEqualObjects(custom_params[@"key"], @"value");
        XCTAssertEqualObjects(custom_params[@"key2"], @"value2");

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test06DoDeeplinkByUrl_UniversalLink {
    // universal link
    id block = ^(NSDictionary * _Nullable params, NSTimeInterval processTime, NSError * _Nullable error) {
        
    };

    NSString *universallink = @"https://datayi.cn/v8dsd7MWy";
    [[GrowingAdvertising sharedInstance] doDeeplinkByUrl:[NSURL URLWithString:universallink]
                                                callback:block];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"DoDeeplinkByUrl_UniversalLink Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 给 webView 一点时间
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeReengage];
        XCTAssertEqual(events.count, 1);
        
        GrowingReengageEvent *event = (GrowingReengageEvent *)events.firstObject;
        NSDictionary *eventDic = event.toDictionary;
        XCTAssertEqualObjects(eventDic[@"rngg_mch"], @"universal_link");

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test07DoDeeplinkByUrl_InvaildLink {
    // invaild link
    id block = ^(NSDictionary * _Nullable params, NSTimeInterval processTime, NSError * _Nullable error) {
        
    };

    NSString *invaildlink = @"https://www.baidu.com";
    [[GrowingAdvertising sharedInstance] doDeeplinkByUrl:[NSURL URLWithString:invaildlink]
                                                callback:block];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"DoDeeplinkByUrl_InvaildLink Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 给 webView 一点时间
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeReengage];
        XCTAssertEqual(events.count, 0);

        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test08LoadClipboard {
    NSString *string = @"‌‌‌‌‌‌‌‌‌‍‍‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‍‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‍‌‌‌‌‌‌‌‌‌‍‍‍‌‍‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‍‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‍‌‌‌‌‌‌‌‌‌‍‌‍‍‍‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‌‌‌‌‌‌‌‌‌‍‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‍‌‍‌‍‍‍‌‌‌‌‌‌‌‌‌‍‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‍‌‌‌‌‌‌‌‌‌‍‌‍‍‍‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‍‌‍‍‍‍‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‍‌‍‍‍‍‍‌‌‌‌‌‌‌‌‌‍‍‍‌‌‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‍‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‍‌‌‌‌‌‌‌‌‌‍‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‌‌‌‌‌‌‌‌‌‍‌‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‍‌‌‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‌‌‍‍‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‌‍‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‍‌‌‌‌‌‌‌‌‌‍‌‌‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‌‌‍‌‌‌‌‌‌‌‌‌‍‍‌‍‍‌‌‌‌‌‌‌‌‌‌‌‍‍‍‌‍‌‍‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‍‌‌‍‌‌‌‌‌‌‌‌‌‌‌‍‌‌‍‌‍‌‌‌‌‌‌‌‌‌‌‍‍‌‍‍‍‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‌‌‍‌‌‌‍‌‌‌‌‌‌‌‌‌‌‍‍‍‍‍‌‍‌‌‌‌‌‌‌‌‌‍‍‍‍‍‌‍"; // encrypted
    [UIPasteboard generalPasteboard].string = string;
    
    // 恢复为未发送激活事件
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(0) forKey:@"GrowingAdvertisingActivateWrote"];
    [userDefaults synchronize];
    
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    // 修改为自动发送激活
    trackConfiguration.autoInstall = YES;
    // 可读取剪贴板数据
    trackConfiguration.readClipBoardEnabled = YES;
    // 可采集数据
    trackConfiguration.dataCollectionEnabled = YES;

    [[GrowingAdvertising sharedInstance] loadClipboard];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"loadClipboard Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 给 webView 一点时间
        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeActivate];
            XCTAssertEqual(events.count, 1);
            
            GrowingActivateEvent *event = (GrowingActivateEvent *)events.firstObject;
            NSDictionary *eventDic = event.toDictionary;
            XCTAssertEqualObjects(eventDic[@"link_id"], @"d7MWy");
            XCTAssertEqualObjects(eventDic[@"click_id"], @"5a49666e-6b86-4346-bc82-b0184983183b");
            XCTAssertEqualObjects(eventDic[@"tm_click"], @"1662098687481");
            XCTAssertEqualObjects(eventDic[@"cl"], @"defer");
        }
        
        {
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeReengage];
            XCTAssertEqual(events.count, 1);
            
            GrowingReengageEvent *event = (GrowingReengageEvent *)events.firstObject;
            NSDictionary *eventDic = event.toDictionary;
            NSDictionary *custom_params = eventDic[@"var"];
            XCTAssertEqualObjects(eventDic[@"rngg_mch"], @"universal_link");
            XCTAssertEqualObjects(eventDic[@"link_id"], @"d7MWy");
            XCTAssertEqualObjects(eventDic[@"click_id"], @"5a49666e-6b86-4346-bc82-b0184983183b");
            XCTAssertEqualObjects(eventDic[@"tm_click"], @"1662098687481");
            XCTAssertEqualObjects(custom_params[@"key"], @"value");
            XCTAssertEqualObjects(custom_params[@"key2"], @"value2");
        }
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

@end
