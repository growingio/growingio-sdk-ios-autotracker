//
//  HybridEventTest.m
//  GrowingAnalytics
//
//  Created by sheng on 2021/12/17.
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

#import "GrowingHybridCustomEvent.h"
#import "GrowingHybridPageAttributesEvent.h"
#import "GrowingHybridPageEvent.h"
#import "GrowingHybridViewElementEvent.h"

@interface HybridEventTest : XCTestCase

@end

@implementation HybridEventTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingHybridCustomEvent {
    GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)GrowingHybridCustomEvent.builder.setPath(@"/hybrid/test")
    .setQuery(@"testquery")
    .setEventName(@"testEventName")
    .setPageShowTimestamp(123456677)
    .setAttributes(@{@"test":@"value"}).build;
    
    XCTAssertEqual(event.path, @"/hybrid/test");
    XCTAssertEqual(event.query, @"testquery");
    XCTAssertEqual(event.eventName, @"testEventName");
    XCTAssertTrue(event.pageShowTimestamp == 123456677);
    NSString *value = (NSString *)event.attributes[@"test"];
    XCTAssertTrue([value isEqualToString:@"value"]);
}

- (void)testGrowingHybridPageAttributesEvent {
    GrowingHybridPageAttributesEvent *event = (GrowingHybridPageAttributesEvent *)GrowingHybridPageAttributesEvent.builder.setPath(@"/hybrid/test")
    .setQuery(@"testquery")
    .setPageShowTimestamp(123456677)
    .setAttributes(@{@"test":@"value"}).build;
    
    XCTAssertEqual(event.path, @"/hybrid/test");
    XCTAssertEqual(event.query, @"testquery");
    NSString *value = (NSString *)event.attributes[@"test"];
    XCTAssertTrue([value isEqualToString:@"value"]);
}

- (void)testGrowingHybridPageEvent {
    GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)GrowingHybridPageEvent.builder
    .setQuery(@"testquery")
    .setProtocolType(@"testProtocol").build;
    
    XCTAssertEqual(event.query, @"testquery");
    XCTAssertEqual(event.protocolType, @"testProtocol");
}

- (void)testGrowingPageCustomEvent {
    GrowingPageCustomEvent *event = (GrowingPageCustomEvent *)GrowingPageCustomEvent.builder
    .setPath(@"path")
    .setEventName(@"testEventName")
    .setAttributes(@{@"test":@"value"})
    .setPageShowTimestamp(123456677).build;
    
    XCTAssertEqualObjects(event.path, @"path");
    XCTAssertEqualObjects(event.eventName, @"testEventName");
    NSString *value = (NSString *)event.attributes[@"test"];
    XCTAssertTrue([value isEqualToString:@"value"]);
    XCTAssertTrue(event.pageShowTimestamp == 123456677);
}

- (void)testGrowingHybridViewElementEvent {
    GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)GrowingHybridViewElementEvent.builder
    .setHyperlink(@"testHyperlink")
    .setQuery(@"testquery").build;
    
    XCTAssertEqual(event.query, @"testquery");
    XCTAssertEqual(event.hyperlink, @"testHyperlink");
}

@end
