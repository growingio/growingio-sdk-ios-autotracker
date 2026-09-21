//
//  ViewImpressionConfigTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "Modules/ViewImpression/Public/GrowingViewImpression.h"
#import "Modules/ViewImpression/Public/GrowingViewImpressionConfig.h"

@interface ViewImpressionConfigTests : XCTestCase

@end

@implementation ViewImpressionConfigTests

- (void)testDefaults {
    GrowingViewImpressionConfig *config = [[GrowingViewImpressionConfig alloc] init];

    XCTAssertEqual(config.viewImpressionScale, 0.0f);
    XCTAssertEqual(config.stayDuration, 0.0);
    XCTAssertTrue(config.isRepeatable);
}

- (void)testFactoryMethod {
    GrowingViewImpressionConfig *config = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                        stayDuration:1.5
                                                                                          repeatable:NO];

    XCTAssertEqual(config.viewImpressionScale, 0.5f);
    XCTAssertEqual(config.stayDuration, 1.5);
    XCTAssertFalse(config.isRepeatable);
}

- (void)testScaleIsClampedToValidRange {
    GrowingViewImpressionConfig *config = [[GrowingViewImpressionConfig alloc] init];

    config.viewImpressionScale = -1.0f;
    XCTAssertEqual(config.viewImpressionScale, 0.0f);

    config.viewImpressionScale = 2.0f;
    XCTAssertEqual(config.viewImpressionScale, 1.0f);

    config.viewImpressionScale = 0.75f;
    XCTAssertEqual(config.viewImpressionScale, 0.75f);
}

- (void)testNegativeStayDurationIsClampedToZero {
    GrowingViewImpressionConfig *config = [[GrowingViewImpressionConfig alloc] init];

    config.stayDuration = -3.0;
    XCTAssertEqual(config.stayDuration, 0.0);

    config.stayDuration = 2.0;
    XCTAssertEqual(config.stayDuration, 2.0);
}

- (void)testCopyIsEqualAndIndependent {
    GrowingViewImpressionConfig *config = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                        stayDuration:1.0
                                                                                          repeatable:NO];
    GrowingViewImpressionConfig *copy = [config copy];

    XCTAssertNotIdentical(copy, config);
    XCTAssertEqualObjects(copy, config);
    XCTAssertEqual(copy.hash, config.hash);

    copy.viewImpressionScale = 0.2f;
    XCTAssertEqual(config.viewImpressionScale, 0.5f);
    XCTAssertNotEqualObjects(copy, config);
}

- (void)testEqualityComparesEveryField {
    GrowingViewImpressionConfig *base = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                      stayDuration:1.0
                                                                                        repeatable:YES];

    XCTAssertEqualObjects(base,
                          [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                        stayDuration:1.0
                                                                          repeatable:YES]);
    XCTAssertNotEqualObjects(base,
                             [GrowingViewImpressionConfig configWithViewImpressionScale:0.6f
                                                                           stayDuration:1.0
                                                                             repeatable:YES]);
    XCTAssertNotEqualObjects(base,
                             [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                           stayDuration:2.0
                                                                             repeatable:YES]);
    XCTAssertNotEqualObjects(base,
                             [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                           stayDuration:1.0
                                                                             repeatable:NO]);
    XCTAssertNotEqualObjects(base, @"not a config");
    XCTAssertEqualObjects(base, base);
}

- (void)testTrackConfigurationDefaults {
    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithAccountId:@"test"];

    XCTAssertTrue(configuration.viewImpressionEnabled);
    XCTAssertEqual(configuration.viewImpressionCheckInterval, 0.1);
    XCTAssertNil(configuration.viewImpressionConfig);
}

- (void)testTrackConfigurationRejectsNegativeCheckInterval {
    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithAccountId:@"test"];

    configuration.viewImpressionCheckInterval = -1.0;
    XCTAssertEqual(configuration.viewImpressionCheckInterval, 0.1);

    configuration.viewImpressionCheckInterval = 0.0;
    XCTAssertEqual(configuration.viewImpressionCheckInterval, 0.0);
}

- (void)testTrackConfigurationCopyCarriesViewImpressionFields {
    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithAccountId:@"test"];
    configuration.viewImpressionEnabled = NO;
    configuration.viewImpressionCheckInterval = 0.5;
    configuration.viewImpressionConfig = [GrowingViewImpressionConfig configWithViewImpressionScale:0.5f
                                                                                       stayDuration:1.0
                                                                                         repeatable:NO];

    GrowingTrackConfiguration *copy = [configuration copy];

    XCTAssertFalse(copy.viewImpressionEnabled);
    XCTAssertEqual(copy.viewImpressionCheckInterval, 0.5);
    XCTAssertEqualObjects(copy.viewImpressionConfig, configuration.viewImpressionConfig);
}

@end
