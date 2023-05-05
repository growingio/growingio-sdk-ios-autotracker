//
//  GrowingFoundationHelpersTest.m
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

@interface GrowingFoundationHelpersTest : XCTestCase

@end

@implementation GrowingFoundationHelpersTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNSArrayGrowingHelper {
    NSArray *array = @[@"1", @"2", @"3", @"4"];
    XCTAssertNotNil([array growingHelper_jsonData]);
    XCTAssertNotNil([array growingHelper_jsonDataWithOptions:NSJSONWritingPrettyPrinted]);
    NSString *jsonString = [array growingHelper_jsonString];
    XCTAssertEqualObjects(@"[\"1\",\"2\",\"3\",\"4\"]", jsonString);
}

- (void)testNSDataGrowingHelper {
    NSString *testString = @"123测试";
    NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil([testData growingHelper_base64String]);
    XCTAssertNotNil([testData growingHelper_utf8String]);
    NSString *md5 = [[@"hello world" dataUsingEncoding:NSUTF8StringEncoding] growingHelper_md5String];
    XCTAssertEqualObjects(md5, @"5EB63BBBE01EEED093CB22BB8F5ACDC3");
    XCTAssertNotNil([testData growingHelper_LZ4String]);
    XCTAssertNil([testData growingHelper_jsonObject]);
    XCTAssertNil([testData growingHelper_arrayObject]);
    XCTAssertNil([testData growingHelper_dictionaryObject]);
    XCTAssertNotNil([testData growingHelper_xorEncryptWithHint:0x1F]);
}

- (void)testNSDictionaryGrowingHelper {
    NSDictionary *dict = @{@"id": @12324, @"name": @"ming", @"sex": @"man", @"toys": @[@"toy1", @"toy2", @"toy3"]};
    NSData *data = [dict growingHelper_jsonData];
    data = [dict growingHelper_jsonDataWithOptions:NSJSONWritingPrettyPrinted];
    [dict growingHelper_beautifulJsonString];
    [dict growingHelper_jsonString];
    [dict growingHelper_queryString];
    NSDictionary *dictdata = [data growingHelper_dictionaryObject];
    XCTAssertNotNil(dictdata);
    XCTAssertEqual([dict growingHelper_intForKey:@"id" fallback:1], 12324);
    XCTAssertEqual([dict growingHelper_longlongForKey:@"id" fallback:1], 12324);
    XCTAssertEqual([dict growingHelper_intForKey:@"id2" fallback:1], 1);
    XCTAssertEqual([dict growingHelper_longlongForKey:@"id2" fallback:1], 1);
}

- (void)testNSObjectGrowingHelper {
    NSArray *array = nil;
    if ([UISegmentedControl.new growingHelper_getIvar:"_segments" outObj:&array]) {
        XCTAssertNotNil(array);
    }
}

- (void)testNSStringGrowingHelper {
    NSString *a = @"12测试";
    XCTAssertNil([a growingHelper_queryObject]);
    [a growingHelper_uft8Data];
    [a growingHelper_jsonObject];
    [a growingHelper_dictionaryObject];
    [a growingHelper_queryObject];
    [a growingHelper_safeSubStringWithLength:1];
    [a growingHelper_sha1];
    [a growingHelper_isLegal];
    [a growingHelper_isValidU];
    [a growingHelper_encryptString];
    XCTAssertNotNil([[NSString alloc] initWithJsonObject_growingHelper:@{@"key" : @"value"}]);
    XCTAssertFalse([NSString growingHelper_isBlankString:@"t"]);
    a = [@"https://www.baidu.com" growingHelper_absoluteURLStringWithPath:@"path" andQuery:@{@"key" : @"value"}];
    XCTAssertEqualObjects(a, @"https://www.baidu.com/path?key=value");
    XCTAssertFalse([NSString growingHelper_isEqualStringA:@"A" andStringB:@"B"]);
}

- (void)testNSURLHelper {
    NSURL *url = [NSURL URLWithString:
                             @"growing.3612b67ce562c755://growingio/webservice?serviceType=debugger&wsUrl=wss://"
                             @"gta0.growingio.com/app/0wDaZmQ1/circle/ec7f5925458f458b8ae6f3901cacaa92"];
    XCTAssertNotNil(url.growingHelper_queryDict);
}

@end
