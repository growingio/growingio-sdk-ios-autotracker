//
//  DeviceInfoTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/31.
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

#import "GrowingDeviceInfo.h"
#import "InvocationHelper.h"

@interface DeviceInfoTest : XCTestCase

@end

@implementation DeviceInfoTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingDeviceInfo {
    [[GrowingDeviceInfo currentDeviceInfo] deviceInfoReported];
    [[GrowingDeviceInfo currentDeviceInfo] pasteboardDeeplinkReported];
    [GrowingDeviceInfo deviceScreenSize];
}

- (void)testGrowingDeviceInfoPrivateMethods {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    GrowingDeviceInfo *deviceInfo = GrowingDeviceInfo.currentDeviceInfo;
    XCTAssertNoThrow([deviceInfo safePerformSelector:@selector(isNewInstall)]);
    XCTAssertNoThrow([deviceInfo safePerformSelector:@selector(isPastedDeeplinkCallback)]);
    XCTAssertNotNil([deviceInfo safePerformSelector:@selector(carrier)]);
    XCTAssertNoThrow([deviceInfo safePerformSelector:@selector(handleStatusBarOrientationChange)]);
    XCTAssertNoThrow([deviceInfo safePerformSelector:@selector(applicationDidBecomeActive)]);
    XCTAssertNoThrow([deviceInfo safePerformSelector:@selector(applicationWillResignActive)]);
    XCTAssertNoThrow([deviceInfo safePerformSelector:@selector(updateAppState)]);
#pragma clang diagnostic pop
}

@end
