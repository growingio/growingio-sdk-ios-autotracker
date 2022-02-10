//
//  DynamicProxyTest.m
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

#import "GrowingDynamicProxy.h"

@interface GrowingDynamicObject_XCTest : GrowingDynamicProxy

@property (nonatomic, copy) NSString *string;

- (BOOL)instanceMethod;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingDynamicObject_XCTest

@end
#pragma clang diagnostic pop

@interface GrowingRealObject_XCTest : NSObject <NSCopying>

@property (nonatomic, copy) NSString *string;

- (BOOL)instanceMethod;

@end

@implementation GrowingRealObject_XCTest

- (id)copyWithZone:(nullable NSZone *)zone {
    GrowingRealObject_XCTest *object = [[[self class] allocWithZone:zone] init];
    object->_string = _string;
    return object;
}

- (NSString *)string {
    if (!_string) {
        _string = @"hello world";
    }
    return _string;
}

- (BOOL)instanceMethod {
    return YES;
}

- (NSString *)description {
    return self.string;
}

- (NSString *)debugDescription {
    return self.string;
}

@end

@interface DynamicProxyTest : XCTestCase

@end

@implementation DynamicProxyTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingDynamicProxy {
    {
        GrowingRealObject_XCTest *realObject = [[GrowingRealObject_XCTest alloc] init];
        GrowingDynamicObject_XCTest *dynamicObject = [GrowingDynamicObject_XCTest proxyWithTarget:realObject];
        XCTAssertNotNil(dynamicObject);
        XCTAssertTrue([dynamicObject respondsToSelector:@selector(instanceMethod)]);
        XCTAssertTrue([dynamicObject instanceMethod]);
        XCTAssertEqualObjects(dynamicObject.string, realObject.string);
        

        
        XCTAssertTrue([dynamicObject isEqual:realObject]);
        XCTAssertEqual(dynamicObject.hash, realObject.hash);
        XCTAssertEqualObjects(dynamicObject.superclass, realObject.superclass);
        XCTAssertEqualObjects(dynamicObject.class, realObject.class);
        XCTAssertTrue([dynamicObject isKindOfClass:GrowingRealObject_XCTest.class]);
        XCTAssertTrue([dynamicObject isMemberOfClass:GrowingRealObject_XCTest.class]);
        XCTAssertTrue([dynamicObject conformsToProtocol:@protocol(NSCopying)]);
        XCTAssertTrue([dynamicObject isProxy]);
        XCTAssertEqualObjects([dynamicObject description], [realObject description]);
        XCTAssertEqualObjects([dynamicObject debugDescription], [realObject description]);
    }
    
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        GrowingDynamicObject_XCTest *dynamicObject = [GrowingDynamicObject_XCTest proxyWithTarget:nil];
#pragma clang diagnostic pop
        XCTAssertNotNil(dynamicObject);
        XCTAssertNoThrow([dynamicObject instanceMethod]);
    }
}

@end
