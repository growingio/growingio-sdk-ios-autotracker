//
//  GrowingAnalyticsStartTests2.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/20.
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

#import "GrowingAutotrackConfiguration.h"
#import "GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingTracker.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

// 对老版本API configurationWithProjectId的测试
@interface GrowingAnalyticsStartTests2 : XCTestCase

@end

@implementation GrowingAnalyticsStartTests2

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDefaultConfiguration_Autotracker {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    [GrowingRealAutotracker trackerWithConfiguration:config launchOptions:nil];

    GrowingAutotrackConfiguration *configuration =
        (GrowingAutotrackConfiguration *)GrowingConfigurationManager.sharedInstance.trackConfiguration;
    XCTAssertEqual(configuration.debugEnabled, NO);
    XCTAssertEqual(configuration.cellularDataLimit, 10);
    XCTAssertEqual(configuration.dataUploadInterval, 15);
    XCTAssertEqual(configuration.sessionInterval, 30);
    XCTAssertEqual(configuration.dataCollectionEnabled, YES);
    XCTAssertEqual(configuration.uploadExceptionEnable, YES);
    XCTAssertEqualObjects(configuration.dataCollectionServerHost, @"https://napi.growingio.com");
    XCTAssertEqual(configuration.excludeEvent, 0);
    XCTAssertEqual(configuration.ignoreField, 0);
    XCTAssertEqual(configuration.idMappingEnabled, NO);
    XCTAssertEqualObjects(configuration.urlScheme, nil);
    XCTAssertEqual(configuration.encryptEnabled, NO);
    XCTAssertEqual(configuration.compressEnabled, YES);
    XCTAssertEqual(configuration.impressionScale, 0);
    XCTAssertEqualObjects(configuration.dataSourceId, nil);
}

- (void)testSetConfiguration_Autotracker {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    config.debugEnabled = YES;
    config.cellularDataLimit = 5;
    config.dataUploadInterval = 10;
    config.sessionInterval = 10;
    config.dataCollectionEnabled = NO;
    config.uploadExceptionEnable = NO;
    config.dataCollectionServerHost = @"https://autotracker.growingio.com";
    config.excludeEvent = 1;
    config.ignoreField = 1;
    config.idMappingEnabled = YES;
    config.urlScheme = @"growing.autotracker";
    config.encryptEnabled = YES;
    config.compressEnabled = NO;
    config.impressionScale = 0.5;
    config.dataSourceId = @"12345";
    [GrowingRealAutotracker trackerWithConfiguration:config launchOptions:nil];

    GrowingAutotrackConfiguration *configuration =
        (GrowingAutotrackConfiguration *)GrowingConfigurationManager.sharedInstance.trackConfiguration;
    XCTAssertEqual(configuration.debugEnabled, YES);
    XCTAssertEqual(configuration.cellularDataLimit, 5);
    XCTAssertEqual(configuration.dataUploadInterval, 10);
    XCTAssertEqual(configuration.sessionInterval, 10);
    XCTAssertEqual(configuration.dataCollectionEnabled, NO);
    XCTAssertEqual(configuration.uploadExceptionEnable, NO);
    XCTAssertEqualObjects(configuration.dataCollectionServerHost, @"https://autotracker.growingio.com");
    XCTAssertEqual(configuration.excludeEvent, 1);
    XCTAssertEqual(configuration.ignoreField, 1);
    XCTAssertEqual(configuration.idMappingEnabled, YES);
    XCTAssertEqualObjects(configuration.urlScheme, @"growing.autotracker");
    XCTAssertEqual(configuration.encryptEnabled, YES);
    XCTAssertEqual(configuration.compressEnabled, NO);
    XCTAssertEqual(configuration.impressionScale, 0.5);
    XCTAssertEqualObjects(configuration.dataSourceId, @"12345");
}

- (void)testDefaultConfiguration_Tracker {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithProjectId:@"test"];
    [GrowingRealTracker trackerWithConfiguration:config launchOptions:nil];

    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    XCTAssertEqual(configuration.debugEnabled, NO);
    XCTAssertEqual(configuration.cellularDataLimit, 10);
    XCTAssertEqual(configuration.dataUploadInterval, 15);
    XCTAssertEqual(configuration.sessionInterval, 30);
    XCTAssertEqual(configuration.dataCollectionEnabled, YES);
    XCTAssertEqual(configuration.uploadExceptionEnable, YES);
    XCTAssertEqualObjects(configuration.dataCollectionServerHost, @"https://napi.growingio.com");
    XCTAssertEqual(configuration.excludeEvent, 0);
    XCTAssertEqual(configuration.ignoreField, 0);
    XCTAssertEqual(configuration.idMappingEnabled, NO);
    XCTAssertEqualObjects(configuration.urlScheme, nil);
    XCTAssertEqual(configuration.encryptEnabled, NO);
    XCTAssertEqual(configuration.compressEnabled, YES);
    XCTAssertEqualObjects(configuration.dataSourceId, nil);
}

- (void)testSetConfiguration_Tracker {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithProjectId:@"test"];
    config.debugEnabled = YES;
    config.cellularDataLimit = 5;
    config.dataUploadInterval = 10;
    config.sessionInterval = 10;
    config.dataCollectionEnabled = NO;
    config.uploadExceptionEnable = NO;
    config.dataCollectionServerHost = @"https://tracker.growingio.com";
    config.excludeEvent = 1;
    config.ignoreField = 1;
    config.idMappingEnabled = YES;
    config.urlScheme = @"growing.tracker";
    config.encryptEnabled = YES;
    config.compressEnabled = NO;
    config.dataSourceId = @"12345";
    [GrowingRealTracker trackerWithConfiguration:config launchOptions:nil];

    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    XCTAssertEqual(configuration.debugEnabled, YES);
    XCTAssertEqual(configuration.cellularDataLimit, 5);
    XCTAssertEqual(configuration.dataUploadInterval, 10);
    XCTAssertEqual(configuration.sessionInterval, 10);
    XCTAssertEqual(configuration.dataCollectionEnabled, NO);
    XCTAssertEqual(configuration.uploadExceptionEnable, NO);
    XCTAssertEqualObjects(configuration.dataCollectionServerHost, @"https://tracker.growingio.com");
    XCTAssertEqual(configuration.excludeEvent, 1);
    XCTAssertEqual(configuration.ignoreField, 1);
    XCTAssertEqual(configuration.idMappingEnabled, YES);
    XCTAssertEqualObjects(configuration.urlScheme, @"growing.tracker");
    XCTAssertEqual(configuration.encryptEnabled, YES);
    XCTAssertEqual(configuration.compressEnabled, NO);
    XCTAssertEqualObjects(configuration.dataSourceId, @"12345");
}

@end
