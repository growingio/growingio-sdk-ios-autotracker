//
//  GrowingUIKitHelpersTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/19.
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

#import "UIApplication+GrowingHelper.h"
#import "UIControl+GrowingHelper.h"
#import "UIImage+GrowingHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "InvocationHelper.h"

@interface GrowingUIKitHelpersTest : XCTestCase

@end

@implementation GrowingUIKitHelpersTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testUIApplicationHelper {
    UIApplication *application = UIApplication.sharedApplication;
    [application growingHelper_allWindows];
    [application growingHelper_allWindowsSortedByWindowLevel];
    [application growingHelper_allWindowsWithoutGrowingWindow];
}

- (void)testUIControlHelper {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    {
        UIButton *button = [[UIButton alloc] init];
        button.growingHelper_onClick = nil;
        XCTAssertNil(button.growingHelper_onClick);
        __block int a = 1;
        button.growingHelper_onClick = ^{
            a += 1;
        };
        XCTAssertNotNil(button.growingHelper_onClick);
        button.growingHelper_onClick = nil;
        XCTAssertNil(button.growingHelper_onClick);
        button.growingHelper_onClick = ^{
            a += 2;
        };
        XCTAssertNotNil(button.growingHelper_onClick);
        button.growingHelper_onClick = ^{
            a += 3;
        };
        XCTAssertNotNil(button.growingHelper_onClick);
        [button safePerformSelector:@selector(__growingHelper_onClick_handle)];
        XCTAssertEqual(a, 4);
    }
    
    {
        UITextField *textField = [[UITextField alloc] init];
        textField.growingHelper_onTextChange = nil;
        XCTAssertNil(textField.growingHelper_onTextChange);
        __block int a = 1;
        textField.growingHelper_onTextChange = ^{
            a += 1;
        };
        XCTAssertNotNil(textField.growingHelper_onTextChange);
        textField.growingHelper_onTextChange = nil;
        XCTAssertNil(textField.growingHelper_onTextChange);
        textField.growingHelper_onTextChange = ^{
            a += 2;
        };
        XCTAssertNotNil(textField.growingHelper_onTextChange);
        textField.growingHelper_onTextChange = ^{
            a += 3;
        };
        XCTAssertNotNil(textField.growingHelper_onTextChange);
        [textField safePerformSelector:@selector(__growingHelper_onTextChange_handle)];
        XCTAssertEqual(a, 4);
    }
#pragma clang diagnostic pop
}

- (void)testImageHelper {
    UIImage *image = [UIImage new];
    [image growingHelper_JPEG:0.8];
    [image growingHelper_PNG];
    [image growingHelper_Base64JPEG:0.9];
    [image growingHelper_Base64PNG];
    [image growingHelper_getSubImage:CGRectMake(0, 0, 1, 1)];
}

- (void)testUIWindowHelper {
    [[UIWindow new] growingHelper_screenshot:0.8];
    [UIWindow growingHelper_screenshotWithWindows:nil andMaxScale:0.8];
    [UIWindow growingHelper_screenshotWithWindows:nil andMaxScale:0.8 block:nil];
}

- (void)testUIViewHelper {
    UIView *view = [[UIView alloc] init];
    [view growingHelper_screenshot:2.0f];
    [view growingHelper_viewController];
}

@end
