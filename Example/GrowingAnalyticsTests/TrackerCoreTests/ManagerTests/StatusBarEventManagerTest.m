//
//  StatusBarEventManagerTest.m
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

#import "GrowingStatusBarEventManager.h"

@interface StatusBarEventManagerTest : XCTestCase <GrowingStatusBarEventProtocol>

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation StatusBarEventManagerTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.tap = [[UITapGestureRecognizer alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingStatusBarEventManager {
    GrowingStatusBarEventManager *manager = GrowingStatusBarEventManager.sharedInstance;
    XCTAssertNotNil(manager);
    
    // for safe sharedInstance
    GrowingStatusBarEventManager *manager2 = [[GrowingStatusBarEventManager alloc] init];
    XCTAssertEqualObjects(manager, manager2);
    XCTAssertEqualObjects(manager, manager.copy);
    XCTAssertEqualObjects(manager, manager.mutableCopy);

    XCTAssertNoThrow([manager addStatusBarObserver:self]);
    XCTAssertNoThrow([manager dispatchTapStatusBar:self.tap]);
    XCTAssertNoThrow([manager removeStatusBarObserver:self]);
}

#pragma mark - GrowingStatusBarEventProtocol

- (void)didTapStatusBar:(id)gesture {
    XCTAssertEqualObjects(self.tap, gesture);
}

@end
