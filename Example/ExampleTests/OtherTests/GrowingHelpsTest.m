//
// GrowingHelpsTest.m
// ExampleTests
//
//  Created by gio on 2021/2/2.
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
#import <UIKit/UIKit.h>
#import "GrowingHelpsTest.h"
#import "NSArray+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "UIImage+GrowingHelper.h"
#import "UIWindow+GrowingHelper.h"
#import "UIView+GrowingHelper.h"


@implementation GrowingHelpsTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test1GrowingHelper_jsonString {
    //growingHelper_jsonString
    NSArray *data = @[@"1",@"2",@"3",@"4"];
    NSString *jsonString = [data growingHelper_jsonString];
    NSLog(@"%@",jsonString);
    //["1","2","3",4,"3"]
    XCTAssertEqualObjects(@"[\"1\",\"2\",\"3\",\"4\"]",jsonString);
}





- (void)test2growingHelper_base64String {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"imagetobase64:failed"];
    
    NSDate* tmpStartData = [NSDate date] ;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *bookmarkImage = [UIImage imageNamed:@"cycle_01.jpg"];
        NSData *data = UIImageJPEGRepresentation(bookmarkImage, 0.5);
        NSString *imgBase64Str = [data growingHelper_base64String];
        NSLog(@"%@",imgBase64Str);
        XCTAssertNotNil(imgBase64Str);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            double failedTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
            NSLog(@"－－－－－－cost time = %f ms(毫秒)", failedTime*1000);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    double successTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@"－－－－－－cost time = %f ms(毫秒)", successTime*1000);
}

- (void)test3growingHelper_utf8String {
    NSString *string = @"hello world";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *utf8Str = [data growingHelper_utf8String];
    NSLog(@"utf8:%@",utf8Str);
    XCTAssertEqualObjects(@"hello world",utf8Str);;
}

/*
- (void)test4growingHelper_LZ4String {
    NSString *string = @"hello world";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData * lz4data= [data growingHelper_LZ4String];
    NSString *utf8Str = [lz4data growingHelper_utf8String];
    NSLog(@"utf8:%@",utf8Str);
    //XCTAssertEqualObjects(@"hello world",utf8Str);;
}
*/


- (void)test5growingHelper_dictionaryObject {
    NSDictionary *dict = @{@"id":@1,@"name":@"ming",@"sex":@"man",@"toys":@[@"toy1",@"toy2",@"toy3"]};
    
    NSData *data = [dict growingHelper_jsonData];
    NSDictionary* dictdata= [data growingHelper_dictionaryObject];
    XCTAssertNotNil(dictdata);
}

 


- (void)test6growingHelper_md5String {
    NSString *string = @"hello world";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString* dictdata= [data growingHelper_md5String];
    NSLog(@"md5String:%@",dictdata);
    XCTAssertNotNil(dictdata);
    XCTAssertEqualObjects(@"5EB63BBBE01EEED093CB22BB8F5ACDC3",dictdata);
}

- (void)test7growingHelper_EncryptWithHint {
    NSString *string = @"hello world";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData * dictdata= [data growingHelper_xorEncryptWithHint:1];
    NSLog(@"EncryptWithHint:%@",[dictdata growingHelper_utf8String]);
    XCTAssertNotNil(dictdata);
}

- (void)test8imageBase64JPEG {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"imagetobase64:failed"];
    
    NSDate* tmpStartData = [NSDate date] ;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *bookmarkImage = [UIImage imageNamed:@"cycle_01.jpg"];
        NSString *imgBase64Str = [bookmarkImage growingHelper_Base64JPEG:0.5];
        NSLog(@"%@",imgBase64Str);
        XCTAssertNotNil(imgBase64Str);
        UIImage * image = [bookmarkImage growingHelper_getSubImage:CGRectMake(0, 0, 40, 40)];
        NSString *imageStr = [image growingHelper_Base64JPEG:0.5];
        NSLog(@"%@",imageStr);
        XCTAssertNotNil(imageStr);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            double failedTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
            NSLog(@"－－－－－－cost time = %f ms(毫秒)", failedTime*1000);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    double successTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@"－－－－－－cost time = %f ms(毫秒)", successTime*1000);
}

- (void)test9imagehelper  {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"imagetobase64:failed"];
    
    NSDate* tmpStartData = [NSDate date] ;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *bookmarkImage = [UIImage imageNamed:@"cycle_01.jpg"];
        NSString *imgBase64Str = [bookmarkImage growingHelper_Base64JPEG:0.5];
        NSLog(@"%@",imgBase64Str);
        XCTAssertNotNil(imgBase64Str);
        UIImage * image = [bookmarkImage growingHelper_getSubImage:CGRectMake(0, 0, 40, 40)];
        NSString *imageStr = [image growingHelper_Base64JPEG:0.5];
        NSLog(@"%@",imageStr);
        XCTAssertNotNil(imageStr);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            double failedTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
            NSLog(@"－－－－－－cost time = %f ms(毫秒)", failedTime*1000);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    double successTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@"－－－－－－cost time = %f ms(毫秒)", successTime*1000);
}

- (void)test10windowshelper {
    UIWindow *vc = [[UIWindow alloc]init ];
    [vc growingHelper_screenshot:CGFLOAT_MAX];
}




- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
