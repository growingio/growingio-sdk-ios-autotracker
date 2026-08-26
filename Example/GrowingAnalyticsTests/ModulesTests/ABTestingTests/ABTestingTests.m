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
#import "Modules/ABTesting/Request/GrowingABTRequest.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingULTimeUtil.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingEncryptionService.h"
#import "GrowingServiceManager.h"
#import "MockEventQueue.h"

@interface GrowingABTRequest (XCTest)

+ (NSString *)identityWithDeviceId:(NSString *_Nullable)deviceId
                            userId:(NSString *_Nullable)userId
                           userKey:(NSString *_Nullable)userKey;

@end

@interface GrowingABTesting (XCTest)

+ (BOOL)isToday:(double)timestamp;

@end

@interface GrowingABTExperimentStorage (XCTest)

- (nullable GrowingABTExperiment *)findExperiment:(NSString *)layerId identity:(NSString *)identity;
- (void)addExperiment:(GrowingABTExperiment *)experiment;
- (void)removeExperiment:(GrowingABTExperiment *)experiment;

@end

@interface GrowingServiceManager (XCTest)

@property (nonatomic, strong) NSMutableDictionary *allServiceDict;
@property (nonatomic, strong) NSMutableDictionary *allServiceInstanceDict;

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
    configuration.abTestingRequestInterval = 5.0f;
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
    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
    GrowingConfigurationManager.sharedInstance.trackConfiguration.idMappingEnabled = NO;
}

- (void)test00ExperimentStorage {
    NSString *layerId = @"123456";
    NSString *identity = [GrowingABTRequest currentIdentity];
    GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                    layerName:@"layer123456"
                                                                 experimentId:@"123"
                                                               experimentName:@"exp_123"
                                                                   strategyId:@"456"
                                                                 strategyName:@"strategy_456"
                                                                    variables:@{}
                                                                    fetchTime:GrowingULTimeUtil.currentTimeMillis];
    exp.identity = identity;
    
    {
        // 测试在初始化storage时，会从本地获取experiment缓存
        // 测试addExperiment/removeExperiment
        GrowingABTExperimentStorage *storage1 = [[GrowingABTExperimentStorage alloc] init];
        [storage1 addExperiment:exp];
        
        GrowingABTExperimentStorage *storage2 = [[GrowingABTExperimentStorage alloc] init];
        GrowingABTExperiment *exp2 = [storage2 findExperiment:layerId identity:identity];
        XCTAssertEqualObjects(exp, exp2);
        
        [storage2 removeExperiment:exp2];
        GrowingABTExperimentStorage *storage3 = [[GrowingABTExperimentStorage alloc] init];
        GrowingABTExperiment *exp3 = [storage3 findExperiment:layerId identity:identity];
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
                    GrowingABTExperiment *exp2 = [GrowingABTExperimentStorage findExperiment:layerId identity:identity];
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
        XCTAssertNil(exp.layerName);
        XCTAssertEqualObjects(exp.experimentId, @"123");
        XCTAssertNil(exp.experimentName);
        XCTAssertEqualObjects(exp.strategyId, @"456");
        XCTAssertNil(exp.strategyName);
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
        XCTAssertNil(event.attributes[@"$exp_layer_name"]);
        XCTAssertEqualObjects(event.attributes[@"$exp_id"], @"123");
        XCTAssertNil(event.attributes[@"$exp_name"]);
        XCTAssertEqualObjects(event.attributes[@"$exp_strategy_id"], @"456");
        XCTAssertNil(event.attributes[@"$exp_strategy_name"]);
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

- (void)test01FetchSuccess_v2 {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(0),
            @"layerName": @"layer_123456",
            @"experimentId": @(123),
            @"experimentName": @"exp_123",
            @"strategyId": @(456),
            @"strategyName": @"strategy_456",
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
        XCTAssertEqualObjects(exp.layerName, @"layer_123456");
        XCTAssertEqualObjects(exp.experimentId, @"123");
        XCTAssertEqualObjects(exp.experimentName, @"exp_123");
        XCTAssertEqualObjects(exp.strategyId, @"456");
        XCTAssertEqualObjects(exp.strategyName, @"strategy_456");
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
        XCTAssertEqualObjects(event.attributes[@"$exp_layer_name"], @"layer_123456");
        XCTAssertEqualObjects(event.attributes[@"$exp_id"], @"123");
        XCTAssertEqualObjects(event.attributes[@"$exp_name"], @"exp_123");
        XCTAssertEqualObjects(event.attributes[@"$exp_strategy_id"], @"456");
        XCTAssertEqualObjects(event.attributes[@"$exp_strategy_name"], @"strategy_456");

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
                                                                    layerName:@"layer123456"
                                                                 experimentId:@"123"
                                                               experimentName:@"exp_123"
                                                                   strategyId:@"456"
                                                                 strategyName:@"strategy_456"
                                                                    variables:@{}
                                                                    fetchTime:1602485628504];
    exp.identity = [GrowingABTRequest currentIdentity];
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
    
    // 非http请求失败不重试
    XCTestExpectation *expectation = [self expectationWithDescription:@"testFetchCodeFailure Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(requestCount, 1);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)test06ExperimentEqual {
    NSString *layerId = @"123456";
    NSString *layerName = @"layer_123456";
    NSString *experimentId = @"123";
    NSString *experimentName = @"exp_123";
    NSString *strategyId = @"456";
    NSString *strategyName = @"strategy_456";
    NSDictionary *variables = @{@"key": @"value"};
    {
        // 跟fetchTime没关系，只验证layerId/experimentId/strategyId/variables
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                        layerName:layerName.copy
                                                                     experimentId:experimentId.copy
                                                                   experimentName:experimentName.copy
                                                                       strategyId:strategyId.copy
                                                                     strategyName:strategyName.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        XCTAssertTrue([exp isEqual:exp2]);
    }
    {
        // layerId不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                        layerName:layerName.copy
                                                                     experimentId:experimentId.copy
                                                                   experimentName:experimentName.copy
                                                                       strategyId:strategyId.copy
                                                                     strategyName:strategyName.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:@"654321"
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        XCTAssertFalse([exp isEqual:exp2]); // 值不同
    }
    {
        // experimentId不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                        layerName:layerName.copy
                                                                     experimentId:experimentId.copy
                                                                   experimentName:experimentName.copy
                                                                       strategyId:strategyId.copy
                                                                     strategyName:strategyName.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:@"321"
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        
        GrowingABTExperiment *exp3 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:nil
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628506];
        
        GrowingABTExperiment *exp4 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:nil
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628507];
        XCTAssertFalse([exp isEqual:exp2]); // 值不同
        XCTAssertFalse([exp isEqual:exp3]); // 其中一个为nil
        XCTAssertTrue([exp3 isEqual:exp4]); // 都是nil
    }
    {
        // strategyId不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                        layerName:layerName.copy
                                                                     experimentId:experimentId.copy
                                                                   experimentName:experimentName.copy
                                                                       strategyId:strategyId.copy
                                                                     strategyName:strategyName.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:@"654"
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628505];
        
        GrowingABTExperiment *exp3 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:nil
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628506];
        
        GrowingABTExperiment *exp4 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:nil
                                                                      strategyName:strategyName.copy
                                                                         variables:variables.copy
                                                                         fetchTime:1602485628507];
        XCTAssertFalse([exp isEqual:exp2]); // 值不同
        XCTAssertFalse([exp isEqual:exp3]); // 其中一个为nil
        XCTAssertTrue([exp3 isEqual:exp4]); // 都是nil
    }
    {
        // variables不同
        GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                        layerName:layerName.copy
                                                                     experimentId:experimentId.copy
                                                                   experimentName:experimentName.copy
                                                                       strategyId:strategyId.copy
                                                                     strategyName:strategyName.copy
                                                                        variables:variables.copy
                                                                        fetchTime:1602485628504];
        
        GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
                                                                         variables:@{@"key": @"value2"}
                                                                         fetchTime:1602485628505];
        
        GrowingABTExperiment *exp3 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
                                                                         variables:nil
                                                                         fetchTime:1602485628506];
        
        GrowingABTExperiment *exp4 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                         layerName:layerName.copy
                                                                      experimentId:experimentId.copy
                                                                    experimentName:experimentName.copy
                                                                        strategyId:strategyId.copy
                                                                      strategyName:strategyName.copy
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
    NSString *layerName = @"layer_123456";
    NSString *experimentId = @"123";
    NSString *experimentName = @"exp_123";
    NSString *strategyId = @"456";
    NSString *strategyName = @"strategy_456";
    NSDictionary *variables = @{@"key": @"value"};
    GrowingABTExperiment *exp = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                    layerName:layerName.copy
                                                                 experimentId:experimentId.copy
                                                               experimentName:experimentName.copy
                                                                   strategyId:strategyId.copy
                                                                 strategyName:strategyName.copy
                                                                    variables:variables.copy
                                                                    fetchTime:1602485628504];
    
    GrowingABTExperiment *exp2 = [[GrowingABTExperiment alloc] initWithLayerId:layerId.copy
                                                                     layerName:layerName.copy
                                                                  experimentId:experimentId.copy
                                                                experimentName:experimentName.copy
                                                                    strategyId:strategyId.copy
                                                                  strategyName:strategyName.copy
                                                                     variables:variables.copy
                                                                     fetchTime:1602485628505];
    XCTAssertTrue([exp isEqual:exp2]);
    [set addObject:exp];
    [set addObject:exp2];
    XCTAssertEqual(set.count, 1); // 相同的experiment对象hash也相同，只会在Set/Dictionary中一次存储
}

- (NSInteger)expHitCount {
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    NSInteger count = 0;
    for (GrowingBaseEvent *event in events) {
        if ([((GrowingCustomEvent *)event).eventName isEqualToString:@"$exp_hit"]) {
            count++;
        }
    }
    return count;
}

static NSDictionary<NSString *, NSString *> *GrowingABTBodyParameters(GrowingABTRequest *request) {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:request.absoluteURL];
    for (id<GrowingRequestAdapter> adapter in request.adapters) {
        urlRequest = [adapter adaptedURLRequest:urlRequest];
    }
    NSString *bodyString = [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *pair in [bodyString componentsSeparatedByString:@"&"]) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            parameters[kv[0]] = [kv[1] stringByRemovingPercentEncoding];
        }
    }
    return parameters;
}

static NSString *GrowingABTDecodeValue(NSString *value, unsigned long long stm) {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:0];
    NSMutableData *result = [NSMutableData dataWithData:data];
    unsigned char *bytes = result.mutableBytes;
    unsigned char factor = (unsigned char)(stm & 0xFF);
    for (NSUInteger i = 0; i < result.length; i++) {
        bytes[i] = bytes[i] ^ factor;
    }
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

- (void)test08RequestStmQuery {
    GrowingABTRequest *request = [[GrowingABTRequest alloc] init];
    request.layerId = @"123456";

    XCTAssertTrue(request.stm > 0);

    NSURLComponents *components = [NSURLComponents componentsWithURL:request.absoluteURL resolvingAgainstBaseURL:YES];
    XCTAssertEqualObjects(components.host, @"www.example.com");
    XCTAssertEqualObjects(components.path, @"/diversion/specified-layer-variables");

    NSMutableArray<NSURLQueryItem *> *stmItems = [NSMutableArray array];
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"stm"]) {
            [stmItems addObject:item];
        }
    }
    XCTAssertEqual(stmItems.count, 1);
    XCTAssertEqualObjects(stmItems.firstObject.value, ([NSString stringWithFormat:@"%llu", request.stm]));

    XCTAssertEqualObjects(request.absoluteURL.absoluteString, request.absoluteURL.absoluteString);
}

- (void)test08RequestWithoutLoginUser {
    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];

    GrowingABTRequest *request = [[GrowingABTRequest alloc] init];
    request.layerId = @"123456";
    NSDictionary *parameters = GrowingABTBodyParameters(request);

    XCTAssertNil(parameters[@"userId"]);
    XCTAssertNil(parameters[@"userKey"]);
    XCTAssertEqualObjects(parameters[@"accountId"], @"test");
    XCTAssertEqualObjects(parameters[@"datasourceId"], @"test");
    XCTAssertEqualObjects(parameters[@"layerId"], @"123456");
    XCTAssertNotNil(parameters[@"distinctId"]);
}

- (void)test08RequestWithLoginUserId {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.idMappingEnabled = NO;
    NSString *loginUserId = @"user+id/测试=001";
    [[GrowingSession currentSession] setLoginUserId:loginUserId userKey:@"userKeyShouldBeIgnored"];

    GrowingABTRequest *request = [[GrowingABTRequest alloc] init];
    request.layerId = @"123456";
    NSDictionary *parameters = GrowingABTBodyParameters(request);

    XCTAssertNotNil(parameters[@"userId"]);
    XCTAssertNotEqualObjects(parameters[@"userId"], loginUserId);
    XCTAssertEqualObjects(GrowingABTDecodeValue(parameters[@"userId"], request.stm), loginUserId);
    XCTAssertNil(parameters[@"userKey"]);

    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
}

- (void)test08RequestWithLoginUserIdAndKey {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.idMappingEnabled = YES;
    NSString *loginUserId = @"user+id/测试=001";
    NSString *loginUserKey = @"phone+number/测试=002";
    [[GrowingSession currentSession] setLoginUserId:loginUserId userKey:loginUserKey];

    GrowingABTRequest *request = [[GrowingABTRequest alloc] init];
    request.layerId = @"123456";

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:request.absoluteURL];
    for (id<GrowingRequestAdapter> adapter in request.adapters) {
        urlRequest = [adapter adaptedURLRequest:urlRequest];
    }
    NSString *bodyString = [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding];
    XCTAssertFalse([bodyString containsString:@"+"]);
    XCTAssertFalse([bodyString containsString:@"/"]);

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *pair in [bodyString componentsSeparatedByString:@"&"]) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            parameters[kv[0]] = [kv[1] stringByRemovingPercentEncoding];
        }
    }

    XCTAssertEqualObjects(GrowingABTDecodeValue(parameters[@"userId"], request.stm), loginUserId);
    XCTAssertEqualObjects(GrowingABTDecodeValue(parameters[@"userKey"], request.stm), loginUserKey);

    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
    GrowingABTRequest *request2 = [[GrowingABTRequest alloc] init];
    request2.layerId = @"123456";
    NSDictionary *parameters2 = GrowingABTBodyParameters(request2);
    XCTAssertNil(parameters2[@"userId"]);
    XCTAssertNil(parameters2[@"userKey"]);

    GrowingConfigurationManager.sharedInstance.trackConfiguration.idMappingEnabled = NO;
}

- (void)test09IdentityFingerprint {
    GrowingConfigurationManager.sharedInstance.trackConfiguration.idMappingEnabled = YES;

    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
    NSString *anonymous = [GrowingABTRequest currentIdentity];
    XCTAssertTrue(anonymous.length > 0);

    [[GrowingSession currentSession] setLoginUserId:@"u1" userKey:@"k1"];
    NSString *identity1 = [GrowingABTRequest currentIdentity];
    XCTAssertNotEqualObjects(identity1, anonymous);

    [[GrowingSession currentSession] setLoginUserId:@"u1" userKey:@"k2"];
    NSString *identity2 = [GrowingABTRequest currentIdentity];
    XCTAssertNotEqualObjects(identity2, identity1);

    [[GrowingSession currentSession] setLoginUserId:@"ab" userKey:@"c"];
    NSString *identity3 = [GrowingABTRequest currentIdentity];
    [[GrowingSession currentSession] setLoginUserId:@"a" userKey:@"bc"];
    NSString *identity4 = [GrowingABTRequest currentIdentity];
    XCTAssertNotEqualObjects(identity3, identity4);

    [[GrowingSession currentSession] setLoginUserId:@"a\nb" userKey:@"c"];
    NSString *identity5 = [GrowingABTRequest currentIdentity];
    [[GrowingSession currentSession] setLoginUserId:@"a" userKey:@"b\nc"];
    NSString *identity6 = [GrowingABTRequest currentIdentity];
    XCTAssertNotEqualObjects(identity5, identity6);

    NSString *deviceId = [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
    XCTAssertEqualObjects([GrowingABTRequest identityWithDeviceId:deviceId userId:@"a" userKey:@"b\nc"], identity6);
    XCTAssertNotEqualObjects([GrowingABTRequest identityWithDeviceId:@"another-device"
                                                             userId:@"a"
                                                            userKey:@"b\nc"],
                             identity6);

    GrowingABTRequest *request = [[GrowingABTRequest alloc] init];
    XCTAssertEqualObjects(request.userIdentity, identity6);
    [[GrowingSession currentSession] setLoginUserId:@"another" userKey:nil];
    XCTAssertEqualObjects(request.userIdentity, identity6);
    XCTAssertNotEqualObjects(request.userIdentity, [GrowingABTRequest currentIdentity]);

    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
    GrowingConfigurationManager.sharedInstance.trackConfiguration.idMappingEnabled = NO;
}

- (void)test09CacheInvalidatedOnUserSwitch {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(0),
            @"experimentId": @(123),
            @"strategyId": @(456),
            @"variables": @{@"key": @"value"}
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];

    NSString *layerId = [NSUUID UUID].UUIDString; // 避免缓存影响
    [[GrowingSession currentSession] setLoginUserId:@"userA"];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"test09CacheInvalidatedOnUserSwitch Test failed : timeout"];
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertEqualObjects(exp.experimentId, @"123");
        XCTAssertEqual(requestCount, 1);

        [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp2) {
            XCTAssertEqual(requestCount, 1);

            [[GrowingSession currentSession] setLoginUserId:@"userB"];
            [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp3) {
                XCTAssertEqual(requestCount, 2);

                [[GrowingSession currentSession] setLoginUserId:nil];
                [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp4) {
                    XCTAssertEqual(requestCount, 3);

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                        NSArray<GrowingBaseEvent *> *events =
                            [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
                        NSInteger hitCount = 0;
                        for (GrowingBaseEvent *event in events) {
                            if ([((GrowingCustomEvent *)event).eventName isEqualToString:@"$exp_hit"]) {
                                hitCount++;
                            }
                        }
                        XCTAssertEqual(hitCount, 3);
                        [expectation fulfill];
                    });
                }];
            }];
        }];
    }];
    [self waitForExpectationsWithTimeout:15.0f handler:nil];
}

- (void)test09LegacyCacheWithoutIdentity {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(0),
            @"experimentId": @(123),
            @"strategyId": @(456),
            @"variables": @{@"key": @"value"}
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];

    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];

    NSString *layerId = [NSUUID UUID].UUIDString;
    long long now = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    GrowingABTExperiment *legacy = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                      layerName:nil
                                                                   experimentId:@"999"
                                                                 experimentName:nil
                                                                     strategyId:@"888"
                                                                   strategyName:nil
                                                                      variables:@{@"legacy": @"yes"}
                                                                      fetchTime:now];
    XCTAssertNil(legacy.identity);
    [legacy saveToDisk];

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"test09LegacyCacheWithoutIdentity Test failed : timeout"];
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertEqual(requestCount, 1);
        XCTAssertEqualObjects(exp.experimentId, @"123");
        XCTAssertNotEqualObjects(exp.experimentId, @"999");
        XCTAssertEqualObjects(exp.identity, [GrowingABTRequest currentIdentity]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test09ExpHitReportedAcrossNaturalDay {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(0),
            @"experimentId": @(123),
            @"strategyId": @(456),
            @"variables": @{@"key": @"value"}
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];

    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];

    NSString *layerId = [NSUUID UUID].UUIDString;
    GrowingABTExperiment *cached = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                      layerName:nil
                                                                   experimentId:@"123"
                                                                 experimentName:nil
                                                                     strategyId:@"456"
                                                                   strategyName:nil
                                                                      variables:@{@"key": @"value"}
                                                                      fetchTime:1602485628504];
    cached.identity = [GrowingABTRequest currentIdentity];
    [cached saveToDisk];
    XCTAssertFalse([GrowingABTesting isToday:cached.fetchTime]);

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"test09ExpHitReportedAcrossNaturalDay Test failed : timeout"];
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertEqual(requestCount, 1);
        XCTAssertTrue([exp isEqual:cached]);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            NSInteger hitCount = 0;
            for (GrowingBaseEvent *event in events) {
                if ([((GrowingCustomEvent *)event).eventName isEqualToString:@"$exp_hit"]) {
                    hitCount++;
                }
            }
            XCTAssertEqual(hitCount, 1);
            [expectation fulfill];
        });
    }];
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test09ResultOwnershipWhenIdentityChangedDuringRequest {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        [[GrowingSession currentSession] setLoginUserId:@"user_B"];
        NSDictionary *obj = @{
            @"code": @(0),
            @"experimentId": @(123),
            @"strategyId": @(456),
            @"variables": @{@"key": @"value"}
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];

    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
    NSString *anonymousIdentity = [GrowingABTRequest currentIdentity];
    NSString *layerId = [NSUUID UUID].UUIDString;

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"test09ResultOwnershipWhenIdentityChangedDuringRequest failed : timeout"];
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable exp) {
        XCTAssertEqual(requestCount, 1);
        XCTAssertEqualObjects(exp.experimentId, @"123");

        XCTAssertEqualObjects(exp.identity, anonymousIdentity);
        XCTAssertNotEqualObjects(exp.identity, [GrowingABTRequest currentIdentity]);

        XCTAssertNotNil([GrowingABTExperiment findExperiment:layerId identity:anonymousIdentity]);
        XCTAssertNil([GrowingABTExperiment findExperiment:layerId
                                                 identity:[GrowingABTRequest currentIdentity]]);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            XCTAssertEqual([self expHitCount], 1);
            [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
            [expectation fulfill];
        });
    }];
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test10SwitchBackHitsOwnCache {
    __block NSInteger requestCount = 0;
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"www.example.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        requestCount++;
        NSDictionary *obj = @{
            @"code": @(0),
            @"experimentId": @(123),
            @"strategyId": @(456),
            @"variables": @{@"key": @"value"}
        };
        return [HTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];

    NSString *layerId = [NSUUID UUID].UUIDString;
    XCTestExpectation *expectation =
        [self expectationWithDescription:@"test10SwitchBackHitsOwnCache failed : timeout"];

    [[GrowingSession currentSession] setLoginUserId:@"user_A"];
    [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable expA) {
        XCTAssertEqual(requestCount, 1);

        [[GrowingSession currentSession] setLoginUserId:@"user_B"];
        [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable expB) {
            XCTAssertEqual(requestCount, 2);

            [[GrowingSession currentSession] setLoginUserId:@"user_A"];
            [GrowingABTesting fetchExperiment:layerId completedBlock:^(GrowingABTExperiment * _Nullable expA2) {
                XCTAssertEqual(requestCount, 2);
                XCTAssertEqualObjects(expA2.identity, [GrowingABTRequest currentIdentity]);

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    XCTAssertEqual([self expHitCount], 2);
                    [[GrowingSession currentSession] setLoginUserId:nil userKey:nil];
                    [expectation fulfill];
                });
            }];
        }];
    }];
    [self waitForExpectationsWithTimeout:15.0f handler:nil];
}

- (void)test10CleanupOnStorageInit {
    NSString *staleLayerId = [NSUUID UUID].UUIDString;
    NSString *legacyLayerId = [NSUUID UUID].UUIDString;
    NSString *freshLayerId = [NSUUID UUID].UUIDString;
    NSString *identity = [GrowingABTRequest currentIdentity];

    GrowingABTExperiment *(^makeExp)(NSString *, long long) = ^(NSString *layerId, long long fetchTime) {
        return [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                   layerName:nil
                                                experimentId:@"123"
                                              experimentName:nil
                                                  strategyId:@"456"
                                                strategyName:nil
                                                   variables:@{@"key": @"value"}
                                                   fetchTime:fetchTime];
    };

    GrowingABTExperiment *stale = makeExp(staleLayerId, 1602485628504);
    stale.identity = identity;
    [stale saveToDisk];

    GrowingABTExperiment *legacy = makeExp(legacyLayerId, GrowingULTimeUtil.currentTimeMillis);
    XCTAssertNil(legacy.identity);
    [legacy saveToDisk];

    GrowingABTExperiment *fresh = makeExp(freshLayerId, GrowingULTimeUtil.currentTimeMillis);
    fresh.identity = identity;
    [fresh saveToDisk];

    GrowingABTExperimentStorage *reloaded = [[GrowingABTExperimentStorage alloc] init];
    XCTAssertNil([reloaded findExperiment:staleLayerId identity:identity]);
    XCTAssertNil([reloaded findExperiment:legacyLayerId identity:identity]);
    XCTAssertNotNil([reloaded findExperiment:freshLayerId identity:identity]);

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"test10CleanupOnStorageInit failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GrowingABTExperimentStorage *reloadedAgain = [[GrowingABTExperimentStorage alloc] init];
        XCTAssertNil([reloadedAgain findExperiment:staleLayerId identity:identity]);
        XCTAssertNil([reloadedAgain findExperiment:legacyLayerId identity:identity]);
        XCTAssertNotNil([reloadedAgain findExperiment:freshLayerId identity:identity]);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)test11RemoveDoesNotAffectOtherIdentity {
    NSString *layerId = [NSUUID UUID].UUIDString;
    GrowingABTExperiment *(^make)(NSString *) = ^(NSString *identity) {
        GrowingABTExperiment *e = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                      layerName:nil
                                                                   experimentId:nil
                                                                 experimentName:nil
                                                                     strategyId:nil
                                                                   strategyName:nil
                                                                      variables:@{}
                                                                      fetchTime:GrowingULTimeUtil.currentTimeMillis];
        e.identity = identity;
        return e;
    };

    GrowingABTExperiment *expA = make(@"identity_A");
    GrowingABTExperiment *expB = make(@"identity_B");
    XCTAssertTrue([expA isEqual:expB]);

    [expA saveToDisk];
    [expB saveToDisk];
    XCTAssertNotNil([GrowingABTExperimentStorage findExperiment:layerId identity:@"identity_A"]);
    XCTAssertNotNil([GrowingABTExperimentStorage findExperiment:layerId identity:@"identity_B"]);

    [expA removeFromDisk];
    XCTAssertNil([GrowingABTExperimentStorage findExperiment:layerId identity:@"identity_A"]);
    XCTAssertNotNil([GrowingABTExperimentStorage findExperiment:layerId identity:@"identity_B"]);
}

- (void)test11AddDoesNotAffectOtherIdentity {
    NSString *layerId = [NSUUID UUID].UUIDString;
    GrowingABTExperiment *(^make)(NSString *) = ^(NSString *identity) {
        GrowingABTExperiment *e = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                      layerName:nil
                                                                   experimentId:nil
                                                                 experimentName:nil
                                                                     strategyId:nil
                                                                   strategyName:nil
                                                                      variables:@{}
                                                                      fetchTime:GrowingULTimeUtil.currentTimeMillis];
        e.identity = identity;
        return e;
    };

    [make(@"identity_A") saveToDisk];
    [make(@"identity_B") saveToDisk];

    [make(@"identity_A") saveToDisk];
    XCTAssertNotNil([GrowingABTExperimentStorage findExperiment:layerId identity:@"identity_A"]);
    XCTAssertNotNil([GrowingABTExperimentStorage findExperiment:layerId identity:@"identity_B"]);
}

- (void)test12EncryptServiceMissingThrowsException {
    GrowingServiceManager *manager = GrowingServiceManager.sharedInstance;
    NSString *serviceKey = NSStringFromProtocol(@protocol(GrowingEncryptionService));
    NSString *implClassName = manager.allServiceDict[serviceKey];
    id cachedInstance = manager.allServiceInstanceDict[serviceKey];
    XCTAssertNotNil(implClassName, @"正规集成下加密服务应已注册，前置条件不成立则本用例无意义");

    @try {
        [manager.allServiceDict removeObjectForKey:serviceKey];
        [manager.allServiceInstanceDict removeObjectForKey:serviceKey];
        XCTAssertNil([manager createService:@protocol(GrowingEncryptionService)]);

        XCTAssertThrowsSpecificNamed([[GrowingABTesting sharedInstance] growingModInit:nil], NSException, @"初始化异常",
                                     @"加密服务缺失时应抛出初始化异常，否则 userId 会以明文上报并导致随机分流");
    } @finally {
        manager.allServiceDict[serviceKey] = implClassName;
        if (cachedInstance) {
            manager.allServiceInstanceDict[serviceKey] = cachedInstance;
        }
    }

    XCTAssertNotNil([manager createService:@protocol(GrowingEncryptionService)]);
    XCTAssertNoThrow([[GrowingABTesting sharedInstance] growingModInit:nil]);
}

@end

#pragma clang diagnostic pop
