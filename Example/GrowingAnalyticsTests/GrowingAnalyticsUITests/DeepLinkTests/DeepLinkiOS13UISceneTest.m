//
//  DeepLinkiOS13UISceneTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/6/15.
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
#import "DeepLinkTestHelper.h"

@interface DeepLinkiOS13UISceneTest : XCTestCase

@end

@implementation DeepLinkiOS13UISceneTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test01DeeplinkFromSafari_fromBackgroundedApp {
    [DeepLinkTestHelper openSafariDeeplink:NO];
}

- (void)test02DeeplinkFromSafari_thatLaunchesTheApp {
    [DeepLinkTestHelper openSafariDeeplink:YES];
}

- (void)test03UniversalLinkFromMessages_fromBackgroundedApp {
    [DeepLinkTestHelper openMessagesUniversalLink:NO];
}

- (void)test04UniversalLinkFromMessages_thatLaunchesTheApp {
    [DeepLinkTestHelper openMessagesUniversalLink:YES];
}

@end
