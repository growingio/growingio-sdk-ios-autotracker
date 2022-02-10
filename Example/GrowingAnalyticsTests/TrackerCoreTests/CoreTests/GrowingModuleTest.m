//
//  GrowingModuleTest.m
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

#import "GrowingModuleManager.h"
#import "GrowingModuleProtocol.h"

@interface GrowingModuleManager (Private)

@property(nonatomic, strong) NSMutableArray<NSDictionary *> *growingModuleInfos;

@end

@interface GrowingModuleTest : XCTestCase <GrowingModuleProtocol>

@end

@implementation GrowingModuleTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)growingModInit:(GrowingContext *)context {
    
}

- (void)testGrowingModuleManager {
    [[GrowingModuleManager sharedInstance] registerDynamicModule:[GrowingModuleTest class]];
    
    
    NSMutableArray *moduleInfos = GrowingModuleManager.sharedInstance.growingModuleInfos;
    BOOL isFind = NO;
    for (NSDictionary *dict in moduleInfos) {
        if ([dict[@"moduleClass"] isEqualToString:NSStringFromClass([GrowingModuleTest class])]) {
            isFind = YES;
            break;
        }
    }
    XCTAssertTrue(isFind);
    
    [[GrowingModuleManager sharedInstance] unRegisterDynamicModule:[GrowingModuleTest class]];
    
    BOOL isFind2 = NO;
    for (NSDictionary *dict in moduleInfos) {
        if ([dict[@"moduleClass"] isEqualToString:NSStringFromClass([GrowingModuleTest class])]) {
            isFind2 = YES;
            break;
        }
    }
    XCTAssertTrue(!isFind2);
}

@end
