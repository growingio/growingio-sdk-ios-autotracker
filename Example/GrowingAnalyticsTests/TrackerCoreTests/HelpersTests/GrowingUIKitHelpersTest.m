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

#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
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
    [application growingHelper_allWindowsWithoutGrowingWindow];
}

- (void)testImageHelper {
    UIImage *image = [UIImage new];
    [image growingHelper_JPEG:0.8];
}

- (void)testUIWindowHelper {
    [UIWindow growingHelper_screenshotWithWindows:nil andMaxScale:0.8];
}

- (void)testUIViewHelper {
    UIView *view = [[UIView alloc] init];
    [view growingHelper_viewController];
}

@end
