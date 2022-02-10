//
//  GrowingServiceTest.m
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

#import "GrowingServiceManager.h"

@protocol GrowingServiceTestProtocol <NSObject>

- (void)unitTest;

@end

@interface GrowingServiceTest : XCTestCase <GrowingServiceTestProtocol>

@end

@implementation GrowingServiceTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)unitTest {
    
}

- (void)testGrowingServiceManager {
    [[GrowingServiceManager sharedInstance] registerService:@protocol(GrowingServiceTestProtocol)
                                                  implClass:[GrowingServiceTest class]];
    Class impclass = [[GrowingServiceManager sharedInstance] serviceImplClass:@protocol(GrowingServiceTestProtocol)];
    XCTAssertTrue(impclass == [GrowingServiceTest class]);
    
    GrowingServiceTest *obj = [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingServiceTestProtocol)];
    [obj unitTest];
    XCTAssertTrue([obj isKindOfClass:[GrowingServiceTest class]]);
    
    //单例对象 应该是不存在的 GrowingServiceTest 不是单例对象
    GrowingServiceTest *obj2 = [[GrowingServiceManager sharedInstance] getServiceInstanceForServiceName:@"GrowingServiceTestProtocol"];
    XCTAssertTrue(![obj2 isKindOfClass:[GrowingServiceTest class]]);
}

@end
