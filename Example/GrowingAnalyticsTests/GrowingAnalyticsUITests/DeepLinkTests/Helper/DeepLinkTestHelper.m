//
//  DeepLinkTestHelper.m
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

#import "DeepLinkTestHelper.h"
#import <XCTest/XCTest.h>

// 参考自: https://swiftrocks.com/ui-testing-deeplinks-and-universal-links-in-ios
@implementation DeepLinkTestHelper

+ (void)openSafariDeeplink:(NSString *)urlString terminateFirst:(BOOL)terminateFirst {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    if (terminateFirst) {
        [app terminate];
    }
    
    [self openFromSafari:[NSString stringWithFormat:@"%@&xctest=DeepLinkTest", urlString]];
    XCTAssertTrue([app waitForState:XCUIApplicationStateRunningForeground timeout:5]);
    
    XCUIElement *testButton = app.buttons[@"XCTest"];
    XCTAssertTrue([testButton waitForExistenceWithTimeout:5]);
    [testButton tap];
}

+ (void)openFromSafari:(NSString *)urlString {
    XCUIApplication *safari = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.mobilesafari"];
    [safari launch];
    XCTAssertTrue([safari waitForState:XCUIApplicationStateRunningForeground timeout:5]);
    
    XCUIElementQuery *buttonsQuery = [safari.buttons matchingIdentifier:@"Continue"];
    if (buttonsQuery.count> 0) {
        XCUIElement *firstLaunchContinueButton = [buttonsQuery elementBoundByIndex:0];
        if (firstLaunchContinueButton.exists) {
            [firstLaunchContinueButton tap];
        }
    }
    
    [safari.textFields[@"TabBarItemTitle"] tap];
    
    XCUIElementQuery *buttonsQuery2 = [safari.buttons matchingIdentifier:@"Continue"];
    if (buttonsQuery2.count > 0) {
        XCUIElement *keyboardTutorialButton = [buttonsQuery2 elementBoundByIndex:0];
        if (keyboardTutorialButton.exists) {
            [keyboardTutorialButton tap];
        }
    }
    
    [safari typeText:urlString];
    XCUIElement *goButton = safari.buttons[@"go"];
    XCTAssertTrue([goButton waitForExistenceWithTimeout:2]);
    [goButton tap];
    
    XCUIElement *confirmationButton = safari.buttons[@"Open"];
    XCTAssertTrue([confirmationButton waitForExistenceWithTimeout:10]);
    [confirmationButton tap];
}

+ (void)openMessagesUniversalLink:(NSString *)urlString terminateFirst:(BOOL)terminateFirst {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    if (terminateFirst) {
        [app terminate];
    }
    
    [self openFromMessages:[NSString stringWithFormat:@"%@&xctest=DeepLinkTest", urlString]];
    XCTAssertTrue([app waitForState:XCUIApplicationStateRunningForeground timeout:5]);
    
    XCUIElement *testButton = app.buttons[@"XCTest"];
    XCTAssertTrue([testButton waitForExistenceWithTimeout:5]);
    [testButton tap];
}

+ (void)openFromMessages:(NSString *)urlString {
    XCUIApplication *messages = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.MobileSMS"];
    [messages launch];
    XCTAssertTrue([messages waitForState:XCUIApplicationStateRunningForeground timeout:5]);

    XCUIElement *continueButton = messages.buttons[@"Continue"];
    if (continueButton.exists) {
        [continueButton tap];
    }
    
    XCUIElement *okButton = messages.buttons[@"OK"];
    if (okButton.exists) {
        [okButton tap];
    }

    XCUIElement *cancelButton = messages.navigationBars.buttons[@"Cancel"];
    if (cancelButton.exists) {
        [cancelButton tap];
    }
    
    XCUIElement *chat = [messages.cells firstMatch];
    XCTAssertTrue([chat waitForExistenceWithTimeout:5]);
    [chat tap];
    
    [messages.textFields[@"iMessage"] tap];
    
    XCUIElement *keyboardTutorialButton = messages.buttons[@"Continue"];
    if (keyboardTutorialButton.exists) {
        [keyboardTutorialButton tap];
    }
    
    [messages typeText:[NSString stringWithFormat:@"Link: %@", urlString]];
    XCUIElement *sendButton = messages.buttons[@"Send"];
    if (sendButton.exists) {
        [sendButton tap];
    }
    
    XCUIElement *bubble = [messages.links firstMatch];
    XCTAssertTrue([bubble waitForExistenceWithTimeout:5]);
    sleep(5);
    [bubble tap];
}

@end
