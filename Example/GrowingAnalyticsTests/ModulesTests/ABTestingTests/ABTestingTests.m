//
//  ABTestingTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/16.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingABTesting.h"
#import "GrowingAutotracker.h"
#import "HTTPStubs.h"
#import "HTTPStubsResponse+JSON.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "Modules/ABTesting/GrowingABTExperiment+Private.h"
#import "Modules/ABTesting/GrowingABTExperimentStorage.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "MockEventQueue.h"

@interface GrowingABTesting (XCTest)

+ (BOOL)isToday:(double)timestamp;

@end

@interface GrowingABTExperimentStorage (XCTest)

- (nullable GrowingABTExperiment *)findExperiment:(NSString *)layerId;
- (void)addExperiment:(GrowingABTExperiment *)experiment;
- (void)removeExperiment:(GrowingABTExperiment *)experiment;

@end

@interface ABTestingTests : XCTestCase

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wcompound-token-split-by-macro"

@implementation ABTestingTests

+ (void)setUp {
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
    configuration.dataSourceId = @"test";
    configuration.urlScheme = @"growing.530c8231345c492d";
    configuration.abTestingServerHost = @"https://www.example.com";
    configuration.experimentTTL = 5.0f;
    GrowingNetworkConfig *networkConfig = [GrowingNetworkConfig config];
    networkConfig.abTestingRequestTimeout = 3.0f;
    configuration.networkConfig = networkConfig;
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
    [HTTPStubs removeAllStubs];
}

- (void)tearDown {
    
}

- (void)test00ExperimentStorage {
    NSString *layerId = @"123456";
    GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                 experimentId:@"123"
                                                                   strategyId:@"456"
                                                                    variables:@{}
                                                                    fetchTime:1602485628504];
    
    {
        // 测试在初始化storage时，会从本地获取experiment缓存
        // 测试addExperiment/removeExperiment
        GrowingABTExperimentStorage *storage1 = [[GrowingABTExperimentStorage alloc] init];
        [storage1 addExperiment:exp];
        
        GrowingABTExperimentStorage *storage2 = [[GrowingABTExperimentStorage alloc] init];
        GrowingABTExperiment *exp2 = [storage2 findExperiment:layerId];
        XCTAssertEqualObjects(exp, exp2);
        
        [storage2 removeExperiment:exp2];
        GrowingABTExperimentStorage *storage3 = [[GrowingABTExperimentStorage alloc] init];
        GrowingABTExperiment *exp3 = [storage3 findExperiment:layerId];
        XCTAssertNil(exp3);
    }
    
    {
        // 多线程场景下不崩溃
        XCTAssertNoThrow({
            XCTestExpectation *expectation = [self expectationWithDescription:@"test00ExperimentStorage Test failed : timeout"];
            for (int i = 0; i < 1000; i++) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [GrowingABTExperimentStorage removeExperiment:exp];
                    [GrowingABTExperimentStorage addExperiment:exp];
                    GrowingABTExperiment *exp2 = [GrowingABTExperimentStorage findExperiment:layerId];
                    if (exp2) {
                        // 读异步写同步，因此需要判断非nil情况
                        XCTAssertEqualObjects(exp, exp2);
                    }
                });
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [expectation fulfill];
            });
            [self waitForExpectationsWithTimeout:5.0f handler:nil];
        });
    }
}

- (void)test01FetchSuccess {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(0),
            @"experimentId": @(123),
            @"strategyId": @(456),
            @"variables": @{
                @"key": @"value"
            }
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];
    
    NSString *layerId = [NSUUID UUID].UUIDString; //避免缓存影响
    __block GrowingABTExperiment *lastExp = nil;
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertEqualObjects(exp.layerId, layerId);
        XCTAssertEqualObjects(exp.experimentId, @"123");
        XCTAssertEqualObjects(exp.strategyId, @"456");
        XCTAssertEqualObjects(exp.variables[@"key"], @"value");
        lastExp = exp;
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testFetchSuccess Test failed : timeout"];
    expectation.expectedFulfillmentCount = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(requestCount, 1);
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
        XCTAssertEqual(events.count, 1);
        
        GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
        XCTAssertEqualObjects(event.eventType, GrowingEventTypeCustom);
        XCTAssertEqualObjects(event.eventName, @"$exp_hit");
        XCTAssertEqualObjects(event.attributes[@"$exp_layer_id"], layerId);
        XCTAssertEqualObjects(event.attributes[@"$exp_id"], @"123");
        XCTAssertEqualObjects(event.attributes[@"$exp_strategy_id"], @"456");

        [expectation fulfill];
        
        // 多次调用，由于在TTL内，所以不会再请求
        [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
            // 2次获取的实验对象相同
            XCTAssert([lastExp isEqual:exp]);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssertEqual(requestCount, 1);
            [expectation fulfill];
        });
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test02FetchWrongLayerId {
    XCTAssertNoThrow([GrowingABTesting fetchExperiment:@"" completedBlock:nil]);
    XCTAssertNoThrow([GrowingABTesting fetchExperiment:@(0) completedBlock:nil]);
    XCTAssertNoThrow([GrowingABTesting fetchExperiment:nil completedBlock:nil]);
}

- (void)test03ExperimentOutDated {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(0),
            @"experimentId": @(123),
            @"strategyId": @(456),
            @"variables": @{
                @"key": @"value"
            }
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];
    
    // 向本地存入一个超出自然日的实验
    NSString *layerId = @"outDated";
    GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                 experimentId:@"123"
                                                                   strategyId:@"456"
                                                                    variables:@{}
                                                                    fetchTime:1602485628504];
    [exp saveToDisk];
    
    // 重新获取的实验，其fetchTime应该是今天
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertTrue([GrowingABTesting isToday:exp.fetchTime]);
    }];
    
    // 超出自然日，会清除本地缓存，再次请求
    XCTestExpectation *expectation = [self expectationWithDescription:@"testExperimentOutDated Test failed : timeout"];
    expectation.expectedFulfillmentCount = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(requestCount, 1);
        [expectation fulfill];
        
        // 再次获取，由于还在自然日内，则不会再请求
        [GrowingABTesting fetchExperiment:layerId completedBlock:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssertEqual(requestCount, 1);
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)test04FetchHttpFailure {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{};
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:500 headers:nil];
    }];
    
    NSString *layerId = @"httpFailure";
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertNil(exp);
    }];
    
    // 目前会重试1次
    XCTestExpectation *expectation = [self expectationWithDescription:@"testFetchHttpFailure Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(requestCount, 2);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)test05FetchCodeFailure {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(-1),
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];
    
    NSString *layerId = @"codeFailure";
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertNil(exp);
    }];
    
    // 目前会重试1次
    XCTestExpectation *expectation = [self expectationWithDescription:@"testFetchCodeFailure Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(requestCount, 2);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)test06ExperimentEqual {
    NSString *layerId = @"123456";
    NSString *experimentId = @"123";
    NSString *strategyId = @"456";
    NSDictionary *variables = @{@"key": @"value"};
    {
        // 跟fetchTime没关系，只验证layerId/experimentId/strategyId/variables
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                     experimentId:experimentId.copy
                                                                       strategyId:strategyId.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:experimentId.copy
                                                                        strategyId:strategyId.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        XCTAssertTrue([exp isEqual:exp2]);
    }
    {
        // layerId不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                     experimentId:experimentId.copy
                                                                       strategyId:strategyId.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:@"654321"
                                                                      experimentId:experimentId.copy
                                                                        strategyId:strategyId.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        XCTAssertFalse([exp isEqual:exp2]); // 值不同
    }
    {
        // experimentId不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                     experimentId:experimentId.copy
                                                                       strategyId:strategyId.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:@"321"
                                                                        strategyId:strategyId.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        
        GrowingABTExperiment *exp3 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:nil
                                                                        strategyId:strategyId.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628506];
        
        GrowingABTExperiment *exp4 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:nil
                                                                        strategyId:strategyId.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628507];
        XCTAssertFalse([exp isEqual:exp2]); // 值不同
        XCTAssertFalse([exp isEqual:exp3]); // 其中一个为nil
        XCTAssertTrue([exp3 isEqual:exp4]); // 都是nil
    }
    {
        // strategyId不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                     experimentId:experimentId.copy
                                                                       strategyId:strategyId.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:experimentId.copy
                                                                        strategyId:@"654"
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        
        GrowingABTExperiment *exp3 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:experimentId.copy
                                                                        strategyId:nil
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628506];
        
        GrowingABTExperiment *exp4 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:experimentId.copy
                                                                        strategyId:nil
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628507];
        XCTAssertFalse([exp isEqual:exp2]); // 值不同
        XCTAssertFalse([exp isEqual:exp3]); // 其中一个为nil
        XCTAssertTrue([exp3 isEqual:exp4]); // 都是nil
    }
    {
        // variables不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                     experimentId:experimentId.copy
                                                                       strategyId:strategyId.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:experimentId.copy
                                                                        strategyId:strategyId.copy
                                                                         variables:@{@"key": @"value2"}
                                                                         fetchTime:1602485628505];
        
        GrowingABTExperiment *exp3 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:experimentId.copy
                                                                        strategyId:strategyId.copy
                                                                         variables:nil
                                                                         fetchTime:1602485628506];
        
        GrowingABTExperiment *exp4 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                      experimentId:experimentId.copy
                                                                        strategyId:strategyId.copy
                                                                         variables:nil
                                                                         fetchTime:1602485628507];
        XCTAssertFalse([exp isEqual:exp2]); // 值不同
        XCTAssertFalse([exp isEqual:exp3]); // 其中一个为nil
        XCTAssertTrue([exp3 isEqual:exp4]); // 都是nil
    }
}

- (void)test07ExperimentHash {
    NSMutableSet *set = [NSMutableSet set];
    NSString *layerId = @"123456";
    NSString *experimentId = @"123";
    NSString *strategyId = @"456";
    NSDictionary *variables = @{@"key": @"value"};
    GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                 experimentId:experimentId.copy
                                                                   strategyId:strategyId.copy
                                                                    variables:variables.copy
                                                                    fetchTime:1602485628504];
    
    GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                  experimentId:experimentId.copy
                                                                    strategyId:strategyId.copy
                                                                     variables:variables.copy
                                                                     fetchTime:1602485628505];
    XCTAssertTrue([exp isEqual:exp2]);
    [set addObject:exp];
    [set addObject:exp2];
    XCTAssertEqual(set.count, 1); // 相同的experiment对象hash也相同，只会在Set/Dictionary中一次存储
}

@end

#pragma clang diagnostic pop
