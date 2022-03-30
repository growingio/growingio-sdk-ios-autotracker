//
//  UISegmentedControlAutotrackTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/2/8.
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

#import "InvocationHelper.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UISegmentedControl+GrowingAutotracker.h"

@interface UISegmentedControlAutotrackTest : XCTestCase

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation UISegmentedControlAutotrackTest

- (void)setUp {
    // dispatch_once
    [GrowingRealAutotracker.new safePerformSelector:@selector(addAutoTrackSwizzles)];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// 这个单测测试初始化Hook，点击事件在ClickEventsTest中测试
- (void)testUISegmentedControlAutotrack {
    Class cls = NSClassFromString(@"GrowingUISegmentedControlObserver");
    id sharedInstance = [cls safePerformSelector:@selector(sharedInstance)];
    XCTAssertNotNil(sharedInstance);
    
    // initWithFrame:
    {
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        XCTAssertTrue([control.allTargets containsObject:sharedInstance]);
    }

    // initWithItems:
    {
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[@"1", @"2"]];
        XCTAssertTrue([control.allTargets containsObject:sharedInstance]);
    }
    
    // 多次 init
    {
        UISegmentedControl *control = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] initWithFrame:CGRectMake(0, 0, 100, 100)];
        XCTAssertTrue([control.allTargets containsObject:sharedInstance]);
    }
}

@end

#pragma clang diagnostic pop
