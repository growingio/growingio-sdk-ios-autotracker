//
//  GrowingAnalyticsStartTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/13.
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

#import "GrowingAutotrackConfiguration.h"
#import "GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingTracker.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

@interface GrowingAnalyticsStartTests : XCTestCase

@end

@implementation GrowingAnalyticsStartTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

- (void)testGrowingTrackerStart {
    XCTAssertThrowsSpecificNamed(GrowingTracker.sharedInstance, NSException, @"GrowingTracker未初始化");

    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"xctest"];
    XCTAssertThrowsSpecificNamed([GrowingTracker startWithConfiguration:config launchOptions:nil],
                                 NSException,
                                 @"初始化异常");

    config.dataSourceId = @"xctest";
    [GrowingTracker startWithConfiguration:config launchOptions:nil];

    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            XCTAssertThrowsSpecificNamed([GrowingTracker startWithConfiguration:config launchOptions:nil],
                                         NSException,
                                         @"初始化异常");
        }
                  waitUntilDone:YES];

    GrowingTrackConfiguration *config2 = [GrowingTrackConfiguration configurationWithAccountId:@""];
    XCTAssertThrowsSpecificNamed([GrowingTracker startWithConfiguration:config2 launchOptions:nil],
                                 NSException,
                                 @"初始化异常");
    
    GrowingTrackConfiguration *config3 = [GrowingTrackConfiguration configurationWithAccountId:nil];
    XCTAssertThrowsSpecificNamed([GrowingTracker startWithConfiguration:config3 launchOptions:nil],
                                 NSException,
                                 @"初始化异常");
}

- (void)testGrowingAutotrackerStart {
    XCTAssertThrowsSpecificNamed(GrowingAutotracker.sharedInstance, NSException, @"GrowingAutotracker未初始化");

    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithAccountId:@"xctest"];
    XCTAssertThrowsSpecificNamed([GrowingAutotracker startWithConfiguration:config launchOptions:nil],
                                 NSException,
                                 @"初始化异常");

    config.dataSourceId = @"xctest";
    [GrowingAutotracker startWithConfiguration:config launchOptions:nil];

    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            XCTAssertThrowsSpecificNamed([GrowingAutotracker startWithConfiguration:config launchOptions:nil],
                                         NSException,
                                         @"初始化异常");
        }
                  waitUntilDone:YES];

    GrowingAutotrackConfiguration *config2 = [GrowingAutotrackConfiguration configurationWithAccountId:@""];
    XCTAssertThrowsSpecificNamed([GrowingAutotracker startWithConfiguration:config2 launchOptions:nil],
                                 NSException,
                                 @"初始化异常");
    
    GrowingAutotrackConfiguration *config3 = [GrowingAutotrackConfiguration configurationWithAccountId:nil];
    XCTAssertThrowsSpecificNamed([GrowingAutotracker startWithConfiguration:config3 launchOptions:nil],
                                 NSException,
                                 @"初始化异常");
}

#pragma clang diagnostic pop

- (void)testDefaultConfiguration_Autotracker {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
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
    XCTAssertEqual(configuration.compressEnabled, NO);
    XCTAssertEqual(configuration.impressionScale, 0);
    XCTAssertEqualObjects(configuration.dataSourceId, nil);
    XCTAssertEqualObjects(configuration.networkConfig, nil);
}

- (void)testSetConfiguration_Autotracker {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithAccountId:@"test"];
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
    config.compressEnabled = YES;
    config.impressionScale = 0.5;
    config.dataSourceId = @"12345";
    GrowingNetworkConfig *networkConfig = [GrowingNetworkConfig config];
    networkConfig.requestTimeout = 0.3f;
    config.networkConfig = networkConfig;
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
    XCTAssertEqual(configuration.compressEnabled, YES);
    XCTAssertEqual(configuration.impressionScale, 0.5);
    XCTAssertEqualObjects(configuration.dataSourceId, @"12345");
    XCTAssertNotNil(configuration.networkConfig);
    XCTAssertEqual(configuration.networkConfig.requestTimeout, 0.3f);
}

- (void)testDefaultConfiguration_Tracker {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"test"];
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
    XCTAssertEqual(configuration.compressEnabled, NO);
    XCTAssertEqualObjects(configuration.dataSourceId, nil);
    XCTAssertEqualObjects(configuration.networkConfig, nil);
}

- (void)testSetConfiguration_Tracker {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"test"];
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
    config.compressEnabled = YES;
    config.dataSourceId = @"12345";
    GrowingNetworkConfig *networkConfig = [GrowingNetworkConfig config];
    networkConfig.requestTimeout = 0.3f;
    config.networkConfig = networkConfig;
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
    XCTAssertEqual(configuration.compressEnabled, YES);
    XCTAssertEqualObjects(configuration.dataSourceId, @"12345");
    XCTAssertNotNil(configuration.networkConfig);
    XCTAssertEqual(configuration.networkConfig.requestTimeout, 0.3f);
}

- (void)testVersionNameAndVersionCode {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSString *versionName = [GrowingRealTracker performSelector:@selector(versionName)];
    NSString *versionCode = [GrowingRealTracker performSelector:@selector(versionCode)];
    XCTAssertNotNil(versionName);
    XCTAssertNotNil(versionCode);
#pragma clang diagnostic pop
}

@end
