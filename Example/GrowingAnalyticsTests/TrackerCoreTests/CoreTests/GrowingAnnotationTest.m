//
//  GrowingAnnotationTest.m
//  GrowingAnalytics
//
//  Created by sheng on 2021/12/21.
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

#import "GrowingAnnotationCore.h"

GrowingMod(GrowingAnnotationTest)

GrowingService(GrowingAnnotationTestService, GrowingAnnotationTest)

@interface GrowingAnnotationTest : XCTestCase

@end

@implementation GrowingAnnotationTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAnnotationMethod {
    growing_section section = growingSectionDataModule();
    XCTAssertTrue(section.count != 0,"growing_section can`t be nil");
    BOOL isFindMod = NO;
    for (int i = 0; i < section.count; i++) {
        char *string = (char *)section.charAddress[i];
        NSString *str = [NSString stringWithUTF8String:string];
        if (!str) continue;
        if ([str isEqualToString:@"GrowingAnnotationTest"]) {
            isFindMod = YES;
            break;
        };
    }
    XCTAssertTrue(!isFindMod);
    growing_section service = growingSectionDataService();
    BOOL isFindService = NO;
    for (int i = 0; i < service.count; i++) {
        char *string = (char *)service.charAddress[i];
        NSString *map = [NSString stringWithUTF8String:string];
        NSData *jsonData = [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
                NSString *protocol = [json allKeys][0];
                NSString *clsName = [json allValues][0];
                if (protocol && clsName) {
                    if ([clsName isEqualToString:@"GrowingAnnotationTest"]) {
                        isFindService = YES;
                        break;
                    }
                }
            }
        }
    }
    XCTAssertTrue(!isFindService);
}

@end
