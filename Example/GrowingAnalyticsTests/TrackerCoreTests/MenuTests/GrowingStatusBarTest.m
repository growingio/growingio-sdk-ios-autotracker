//
//  GrowingStatusBarTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/18.
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

#import "GrowingTrackerCore/Menu/GrowingStatusBar.h"
#import "InvocationHelper.h"

@interface GrowingStatusBarTest : XCTestCase

@end

@implementation GrowingStatusBarTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingStatusBar {
    GrowingStatusBar *statusBar = [[GrowingStatusBar alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 20)];
    [statusBar setNeedsLayout];
    [statusBar layoutIfNeeded];
    [statusBar hitTest:CGPointMake(0, 0) withEvent:nil];
    [statusBar setOnButtonClick:^{
        
    }];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [statusBar safePerformSelector:@selector(didTapStatusBar:)];
    XCTAssertEqual([statusBar safePerformSelector:@selector(growingNodeIsBadNode)], @(NO));
#pragma clang diagnostic pop
    statusBar = nil;
}


@end
