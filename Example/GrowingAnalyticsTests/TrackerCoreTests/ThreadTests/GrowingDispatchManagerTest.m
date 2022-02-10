//
//  GrowingDispatchManagerTest.m
//  GrowingAnalytics
//
//  Created by sheng on 2021/12/22.
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

#import "GrowingDispatchManager.h"
#import "GrowingThread.h"

@interface GrowingDispatchManagerTest : XCTestCase

@end

@implementation GrowingDispatchManagerTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingDispatchManager {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertTrue([[NSThread currentThread] isEqual:[GrowingThread sharedThread]]);
    }];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertTrue([[NSThread currentThread] isEqual:[GrowingThread sharedThread]]);
        [GrowingDispatchManager dispatchInGrowingThread:^{
            XCTAssertTrue([[NSThread currentThread] isEqual:[GrowingThread sharedThread]]);
        }];
    }];

    __block int i = 0;
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertTrue([[NSThread currentThread] isEqual:[GrowingThread sharedThread]]);
        i = 1;
    } waitUntilDone:YES];

    XCTAssertTrue(i == 1);

    [GrowingDispatchManager dispatchInMainThread:^{
        XCTAssertTrue([NSThread isMainThread]);
    }];
    
    [GrowingDispatchManager trackApiSel:@selector(test) dispatchInMainThread:^{
        XCTAssertTrue([NSThread isMainThread]);
    }];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [GrowingDispatchManager dispatchInMainThread:^{
            XCTAssertTrue([NSThread isMainThread]);
        }];
        
        [GrowingDispatchManager trackApiSel:@selector(test) dispatchInMainThread:^{
            XCTAssertTrue([NSThread isMainThread]);
        }];
    } waitUntilDone:YES];

    [GrowingDispatchManager dispatchInLowThread:^{
        int i = strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), "io.growing.low");
        XCTAssertTrue(i == 0);
    }];
}

- (void)testGrowingThread {
    XCTAssertNotNil([GrowingThread sharedThread]);
    XCTAssertNotNil([GrowingThread sharedThread].runLoop);
}

@end
