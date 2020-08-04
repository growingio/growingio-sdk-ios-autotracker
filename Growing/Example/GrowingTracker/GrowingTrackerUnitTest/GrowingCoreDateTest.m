//
//  GrowingCoreDateTest.m
//  GrowingTrackerUnitTest
//
//  Created by GrowingIO on 2020/1/11.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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
#import <KIF/KIF.h>
#import <OCMock/OCMock.h>
#import "GrowingFileStore.h"

@interface GrowingCoreDateTest : KIFTestCase

@end

@implementation GrowingCoreDateTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)test1DateTest {

    id mock = [OCMockObject mockForClass:[NSDate class]];
    
    NSString *testDate = @"2019-12-31";
    [[[mock stub] andReturn:[self dateFromString:testDate]] date];
    NSString *dateString = [GrowingFileStore performSelector:@selector(getTodayKey)];
    XCTAssertEqualObjects(testDate, dateString);
    
    mock = [OCMockObject mockForClass:[NSDate class]];
    testDate = @"2020-01-01";
    [[[mock stub] andReturn:[self dateFromString:testDate]] date];
    dateString = [GrowingFileStore performSelector:@selector(getTodayKey)];
    XCTAssertEqualObjects(testDate, dateString);
    
    mock = [OCMockObject mockForClass:[NSDate class]];
    testDate = @"2019-06-13";
    [[[mock stub] andReturn:[self dateFromString:testDate]] date];
    dateString = [GrowingFileStore performSelector:@selector(getTodayKey)];
    XCTAssertEqualObjects(testDate, dateString);

    mock = [OCMockObject mockForClass:[NSDate class]];
    testDate = @"2020-11-02";
    [[[mock stub] andReturn:[self dateFromString:testDate]] date];
    dateString = [GrowingFileStore performSelector:@selector(getTodayKey)];
    XCTAssertEqualObjects(testDate, dateString);
    
    [mock stopMocking];
    
}

- (void)test2CellularNetworkUploadEventSizeTest {

    id mock = [OCMockObject mockForClass:[NSDate class]];
    NSString *distanceDate = @"2019-12-31";
    unsigned long long mockDistanceSize = arc4random();
    [[[mock stub] andReturn:[self dateFromString:distanceDate]] date];
    [GrowingFileStore cellularNetworkStorgeEventSize:mockDistanceSize];
    unsigned long long distanceStorgeSize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(mockDistanceSize, distanceStorgeSize);
    [mock stopMocking];
    
    unsigned long long toadaySize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(0, toadaySize);
    unsigned long long mockToadaySize = arc4random();
    [GrowingFileStore cellularNetworkStorgeEventSize:mockToadaySize];
    unsigned long long toadyStorgeSize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(mockToadaySize, toadyStorgeSize);
    
    mock = [OCMockObject mockForClass:[NSDate class]];
    [[[mock stub] andReturn:[self dateFromString:distanceDate]] date];
    distanceStorgeSize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(0, distanceStorgeSize);
    [mock stopMocking];

    mock = [OCMockObject mockForClass:[NSDate class]];
    NSString *futureDate = @"2030-12-31";
    unsigned long long mockFutureSize = arc4random();
    [[[mock stub] andReturn:[self dateFromString:futureDate]] date];
    [GrowingFileStore cellularNetworkStorgeEventSize:mockFutureSize];
    unsigned long long futureStorgeSize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(mockFutureSize, futureStorgeSize);
    [mock stopMocking];
    
    toadaySize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(0, toadaySize);
    mockToadaySize = arc4random();
    [GrowingFileStore cellularNetworkStorgeEventSize:mockToadaySize];
    toadyStorgeSize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(mockToadaySize, toadyStorgeSize);
    
    mock = [OCMockObject mockForClass:[NSDate class]];
    [[[mock stub] andReturn:[self dateFromString:futureDate]] date];
    futureStorgeSize = [GrowingFileStore cellularNetworkUploadEventSize];
    XCTAssertEqual(0, futureStorgeSize);
    [mock stopMocking];

}



#pragma clang diagnostic pop

- (NSDate *)dateFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *currentDate = [dateFormatter dateFromString:dateString];
    return currentDate;
}


@end
