//
//  DeepLinkTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/6/15.
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
#import "DeepLinkTestHelper.h"

@interface DeepLinkTest : XCTestCase

@end

@implementation DeepLinkTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test01DeeplinkFromSafari_fromBackgroundedApp {
    // 长链-urlscheme无参数
    NSString *url = @"growing.deeplink://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937"
                    @"&tm_click=1654775879497&custom_params=%7B%7D";
    [DeepLinkTestHelper openSafariDeeplink:url terminateFirst:NO];
}

- (void)test02DeeplinkFromSafari_fromBackgroundedApp {
    // 长链-urlscheme带参数
    NSString *url = @"growing.deeplink://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937"
                    @"&tm_click=1654775879497&custom_params=%7B%22key%22%3A%22value%22%2C%22key2%22%3A%22value2%22%7D";
    [DeepLinkTestHelper openSafariDeeplink:url terminateFirst:NO];
}

- (void)test03DeeplinkFromSafari_thatLaunchesTheApp {
    // 长链-urlscheme无参数
    NSString *url = @"growing.deeplink://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937"
                    @"&tm_click=1654775879497&custom_params=%7B%7D";
    [DeepLinkTestHelper openSafariDeeplink:url terminateFirst:YES];
}

- (void)test04DeeplinkFromSafari_thatLaunchesTheApp {
    // 长链-urlscheme带参数
    NSString *url = @"growing.deeplink://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937"
                    @"&tm_click=1654775879497&custom_params=%7B%22key%22%3A%22value%22%2C%22key2%22%3A%22value2%22%7D";
    [DeepLinkTestHelper openSafariDeeplink:url terminateFirst:YES];
}

- (void)test05UniversalLinkFromMessages_fromBackgroundedApp {
    // 短链1-无参数
    NSString *url = @"https://datayi.cn/v8dsd2kdN";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:NO];
}

- (void)test06UniversalLinkFromMessages_fromBackgroundedApp {
    // 短链2-带参数
    NSString *url = @"https://datayi.cn/v8dsd7MWy";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:NO];
}

- (void)test07UniversalLinkFromMessages_fromBackgroundedApp {
    // 长链-universallink无参数
    NSString *url = @"https://datayi.cn/u/AP3BJMA3/d2kdN?link_id=d2kdN&click_id=4878009c-dd0a-4d77-b70f-b003d3bea610"
                    @"&tm_click=1655971050477&custom_params=%7B%7D";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:NO];
}

- (void)test08UniversalLinkFromMessages_fromBackgroundedApp {
    // 长链-universallink带参数
    NSString *url = @"https://datayi.cn/u/AP3BJMA3/dPrj8?link_id=dPrj8&click_id=e943b0fe-6fdd-4187-a8d3-a411e8f503fb"
                    @"&tm_click=1655898560655&custom_params=%7B%22key3%22%3A%22value3%22%2C%22key4%22%3A%22value4%22%7D";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:NO];
}

- (void)test09UniversalLinkFromMessages_thatLaunchesTheApp {
    // 短链1-无参数
    NSString *url = @"https://datayi.cn/v8dsd2kdN";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:YES];
}

- (void)test10UniversalLinkFromMessages_thatLaunchesTheApp {
    // 短链2-带参数
    NSString *url = @"https://datayi.cn/v8dsd7MWy";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:YES];
}

- (void)test11UniversalLinkFromMessages_thatLaunchesTheApp {
    // 长链-universallink无参数
    NSString *url = @"https://datayi.cn/u/AP3BJMA3/d2kdN?link_id=d2kdN&click_id=4878009c-dd0a-4d77-b70f-b003d3bea610"
                    @"&tm_click=1655971050477&custom_params=%7B%7D";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:YES];
}

- (void)test12UniversalLinkFromMessages_thatLaunchesTheApp {
    // 长链-universallink带参数
    NSString *url = @"https://datayi.cn/u/AP3BJMA3/dPrj8?link_id=dPrj8&click_id=e943b0fe-6fdd-4187-a8d3-a411e8f503fb"
                    @"&tm_click=1655898560655&custom_params=%7B%22key3%22%3A%22value3%22%2C%22key4%22%3A%22value4%22%7D";
    [DeepLinkTestHelper openMessagesUniversalLink:url terminateFirst:YES];
}

- (void)test13WebCircleFromSafari_thatLaunchesTheApp {
    // 圈选，测试不会进入GrowingAdvertising逻辑
    NSString *url = @"growing.deeplink://growingio/webservice?serviceType=circle"
                    @"&wsUrl=ws://uat-gdp.growingio.com/app/weDq7mpE/circle/f1bcb578cdc347fc872192b55d2bb764"
                    @"&xctest=DeepLinkTest";
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    [app terminate];
    
    [DeepLinkTestHelper openFromSafari:url];
    XCTAssertTrue([app waitForState:XCUIApplicationStateRunningForeground timeout:15]);
    
    // 不出现deepLinkCallback弹窗
    XCUIElement *testButton = app.buttons[@"XCTest"];
    XCTAssertFalse([testButton waitForExistenceWithTimeout:15]);
}

@end
