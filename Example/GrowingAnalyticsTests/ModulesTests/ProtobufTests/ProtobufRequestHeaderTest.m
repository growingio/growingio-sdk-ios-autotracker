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
#import "GrowingAutotrackConfiguration.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "Modules/DefaultServices/GrowingEventRequestJSONAdapter.h"
#import "Modules/DefaultServices/GrowingEventRequestProtobufAdapter.h"

@interface ProtobufRequestHeaderTest : XCTestCase

@end

@implementation ProtobufRequestHeaderTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test01RequestHeaderProtobufFirst {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
    config.useProtobuf = YES;
    [GrowingRealAutotracker trackerWithConfiguration:config launchOptions:nil];

    GrowingEventRequestProtobufAdapter *adapter = [GrowingEventRequestProtobufAdapter adapterWithRequest:nil];
    GrowingEventRequestJSONAdapter *adapter2 = [GrowingEventRequestJSONAdapter adapterWithRequest:nil];
    XCTAssertLessThan(adapter2.priority, adapter.priority);

    NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.growingio.com"]];
    request = [adapter2 adaptedURLRequest:request];
    request = [adapter adaptedURLRequest:request];

    NSDictionary<NSString *, NSString *> *allHTTPHeaderFields = request.allHTTPHeaderFields;
    for (NSString *key in allHTTPHeaderFields.allKeys) {
        if ([key isEqualToString:@"Content-Type"]) {
            NSString *value = allHTTPHeaderFields[key];
            XCTAssertEqualObjects(value, @"application/protobuf");
            break;
        }
    }
}

- (void)test02RequestHeaderJSONFirst {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
    config.useProtobuf = NO;
    [GrowingRealAutotracker trackerWithConfiguration:config launchOptions:nil];

    GrowingEventRequestProtobufAdapter *adapter = [GrowingEventRequestProtobufAdapter adapterWithRequest:nil];
    GrowingEventRequestJSONAdapter *adapter2 = [GrowingEventRequestJSONAdapter adapterWithRequest:nil];
    XCTAssertLessThan(adapter.priority, adapter2.priority);

    NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.growingio.com"]];
    request = [adapter adaptedURLRequest:request];
    request = [adapter2 adaptedURLRequest:request];

    NSDictionary<NSString *, NSString *> *allHTTPHeaderFields = request.allHTTPHeaderFields;
    for (NSString *key in allHTTPHeaderFields.allKeys) {
        if ([key isEqualToString:@"Content-Type"]) {
            NSString *value = allHTTPHeaderFields[key];
            XCTAssertEqualObjects(value, @"application/json");
            break;
        }
    }
}

@end
