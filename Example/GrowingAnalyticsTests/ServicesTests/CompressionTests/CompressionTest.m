//
//  CompressionTest.m
//  GrowingAnalytics
//
//  Created by sheng on 2021/12/16.
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

#import "GrowingDataCompression.h"
#import "GrowingVisitEvent.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"

@interface CompressionTest : XCTestCase

@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation CompressionTest

- (void)setUp {
    self.dict = GrowingVisitEvent.builder.setIdfa(@"testIdfa")
                    .setIdfv(@"testIdfv")
                    .setExtraSdk(@{@"testkey" : @"value"})
                    .setNetworkState(@"testNetworkState")
                    .setScreenHeight(1920)
                    .setScreenWidth(1280)
                    .setDeviceBrand(@"testDeviceBrand")
                    .setDeviceModel(@"testDeviceModel")
                    .setDeviceType(@"testDeviceType")
                    .setAppName(@"testAppName")
                    .setAppVersion(@"testAppVersion")
                    .setLanguage(@"testLanguage")
                    .setSdkVersion(@"testSdkVersion")
                    .setDomain(@"testdomain")
                    .setLanguage(@"testlanguage")
                    .setLatitude(10)
                    .setLongitude(11)
                    .setPlatform(@"iOS")
                    .setTimestamp(12345678)
                    .setUserId(@"zhangsan")
                    .setUserKey(@"phone")
                    .setDeviceId(@"testdeviceID")
                    .build.toDictionary;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCompressionSize {
    NSData *origin = self.dict.growingHelper_jsonData;
    GrowingDataCompression *compression = [GrowingDataCompression new];
    NSData *result = [compression compressedEventData:origin];
    NSLog(@"origin %lu, result %lu", (unsigned long)origin.length, result.length);
    XCTAssertTrue((result.length < origin.length));
}

- (void)testCompressionNullData {
    NSData *origin = [NSData data];
    GrowingDataCompression *compression = [GrowingDataCompression new];
    XCTAssertNoThrow([compression compressedEventData:origin]);
}

@end
