//
//  ProtobufRequestHeaderTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/7.
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
#import "GrowingEventRequestHeaderAdapter+Protobuf.h"
#import "GrowingConfigurationManager.h"

@interface ProtobufRequestHeaderTest : XCTestCase

@end

@implementation ProtobufRequestHeaderTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRequestHeader {
    GrowingEventRequestHeaderAdapter *eventHeaderAdapter = [[GrowingEventRequestHeaderAdapter alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.growingio.com"]];
    request = [eventHeaderAdapter adaptedRequest:request];
    NSDictionary<NSString *, NSString *> *allHTTPHeaderFields = request.allHTTPHeaderFields;
    for (NSString *key in allHTTPHeaderFields.allKeys) {
        if ([key isEqualToString:@"Content-Type"]) {
            NSString *value = allHTTPHeaderFields[key];
            XCTAssertEqualObjects(value, @"application/protobuf");
            break;
        }
    }
}

- (void)testRequestHeaderWithEncryptEnabled {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.encryptEnabled = YES;
    
    GrowingEventRequestHeaderAdapter *eventHeaderAdapter = [[GrowingEventRequestHeaderAdapter alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.growingio.com"]];
    request = [eventHeaderAdapter adaptedRequest:request];
    NSDictionary<NSString *, NSString *> *allHTTPHeaderFields = request.allHTTPHeaderFields;
    for (NSString *key in allHTTPHeaderFields.allKeys) {
        if ([key isEqualToString:@"X-Compress-Codec"]) {
            NSString *value = allHTTPHeaderFields[key];
            XCTAssertEqualObjects(value, @"3");
        }
        if ([key isEqualToString:@"X-Crypt-Codec"]) {
            NSString *value = allHTTPHeaderFields[key];
            XCTAssertEqualObjects(value, @"1");
        }
    }
}

@end
