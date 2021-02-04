//
// UtilsTest.m
// ExampleTests
//
//  Created by gio on 2021/1/28.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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


#import "UtilsTest.h"
#import "GrowingArgumentChecker.h"
#import "GrowingConfigurationManager.h"
#import "GrowingStatusBarEventManager.h"
@implementation UtilsTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test1IsIllegal {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    if([GrowingArgumentChecker isIllegalEventName:@""])
    {
        NSLog(@"isIllegalEventName yes");
    }
    else
    {
        NSLog(@"测试不通过");
        XCTAssertEqual(1, 0);
    }
    if([GrowingArgumentChecker isIllegalEventName:@"n_GsDxNYdHowd"])
    {
        NSLog(@"测试不通过");
        XCTAssertEqual(1, 0);
    }
    else
    {
        NSLog(@"isIllegalEventName no");
    }//   @"k_a1SVcCoybn9Kw" : @"v_6yj9quXB9tQ3"
    if([GrowingArgumentChecker isIllegalAttributes:nil])
    {
        NSLog(@"isIllegalAttributes yes");
    }
    else
    {
        NSLog(@"测试不通过");
        XCTAssertEqual(1, 0);
    }
    if([GrowingArgumentChecker isIllegalAttributes:@{@"k_a1SVcCoybn9Kw:":@"v_6yj9quXB9tQ3:", @1:@2}])
    {
        NSLog(@"isIllegalAttributes yes");
    }
    else
    {
        NSLog(@"测试不通过");
        XCTAssertEqual(1, 0);
    }
    
}



- (void)test2URLScheme {
    if(![[GrowingConfigurationManager sharedInstance] urlScheme])
    {
        NSLog(@"测试不通过,获取urlScheme失败或者未设置");
        XCTAssertEqual(1, 0);
    }
    NSLog(@"urlScheme: %@",[[GrowingConfigurationManager sharedInstance] urlScheme]);
    
}





@end
