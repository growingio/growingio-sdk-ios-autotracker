//
//  FileStorageTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/30.
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
#import "GrowingUserDefaults.h"
#import "GrowingFileStorage.h"

@interface FileStorageTest : XCTestCase

@end

@implementation FileStorageTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingUserDefaults {
    [[GrowingUserDefaults sharedInstance] setValue:@"testToken" forKey:@"_refreshToken"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGrowingUserDefaults Test failed"];
    [GrowingDispatchManager dispatchInLowThread:^{
        NSString *token = [[GrowingUserDefaults sharedInstance] valueForKey:@"_refreshToken"];
        XCTAssertEqualObjects(token, @"testToken");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30.0f handler:nil];
}

- (void)testGrowingFileStorage {
    {
        XCTAssertNotNil([[GrowingFileStorage alloc] init]);
        XCTAssertNotNil([[GrowingFileStorage alloc] initWithName:@"testGrowingFileStorage"]);
        XCTAssertNotNil([[GrowingFileStorage alloc] initWithName:@"testGrowingFileStorage"
                                                       directory:GrowingUserDirectoryDocuments]);
        XCTAssertNotNil([[GrowingFileStorage alloc] initWithName:@"testGrowingFileStorage"
                                                       directory:GrowingUserDirectoryDocuments
                                                          crypto:nil]);
    }
    
    {
        GrowingFileStorage *storage = [[GrowingFileStorage alloc] initWithName:@"testGrowingFileStorage"];
        [storage resetAll];
        [storage removeKey:@"testKey"];
        [storage setArray:@[ @"testa", @"testb"] forKey:@"testKey"];
        [storage arrayForKey:@"testKey"];
        [storage setNumber:@1 forKey:@"testKeyNum"];
        XCTAssertNotNil([storage numberForKey:@"testKeyNum"]);
    }
}

@end
