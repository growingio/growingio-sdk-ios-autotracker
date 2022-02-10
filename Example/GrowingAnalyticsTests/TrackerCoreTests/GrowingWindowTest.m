//
//  GrowingWindowTest.m
//  GrowingAnalytics
//
//  Created by sheng on 2021/12/20.
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

#import "GrowingWindow.h"

@interface GrowingWindowTest : XCTestCase

@end

@implementation GrowingWindowTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingWindowViewController {
    GrowingWindow *window = [[GrowingWindow alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            [UIScreen mainScreen].bounds.size.width,
                                                                            [UIScreen mainScreen].bounds.size.height)];
    XCTAssertTrue(window.rootViewController.shouldAutorotate);
    XCTAssertEqual(window.rootViewController.supportedInterfaceOrientations, UIInterfaceOrientationMaskAll);
    XCTAssertEqual(window.rootViewController.preferredInterfaceOrientationForPresentation, [[UIApplication sharedApplication]statusBarOrientation]);
}

- (void)testGrowingWindow {
    GrowingWindow *window = [[GrowingWindow alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            [UIScreen mainScreen].bounds.size.width,
                                                                            [UIScreen mainScreen].bounds.size.height)];

    XCTAssertTrue([window.rootViewController isKindOfClass:NSClassFromString(@"GrowingWindowViewController")]);
    [window setHidden:YES];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class cls = NSClassFromString(@"GrowingWindowContentView");
    id sharedInstance = [cls performSelector:NSSelectorFromString(@"sharedInstance")];
    NSMutableArray *array = [sharedInstance performSelector:NSSelectorFromString(@"childWindowView")];
    for (UIView *obj in array) {
        XCTAssertTrue(obj == window);
    }
    XCTAssertNoThrow([sharedInstance hitTest:CGPointMake(0, 0) withEvent:nil]);


    GrowingWindowView *windowView = [[GrowingWindowView alloc] init];
    windowView.growingViewLevel = 2;
    XCTAssertEqual(windowView.growingViewLevel, 2);
    
    XCTAssertNoThrow([window hitTest:CGPointMake(0, 0) withEvent:nil]);
    XCTAssertFalse([window performSelector:NSSelectorFromString(@"growingNodeIsBadNode")]);
#pragma clang diagnostic pop
}

@end
