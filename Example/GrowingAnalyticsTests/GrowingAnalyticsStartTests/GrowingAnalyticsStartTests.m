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

#import "GrowingRealAutotracker.h"
#import "GrowingRealTracker.h"
#import "GrowingAutotrackConfiguration.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingConfigurationManager.h"
#import "GrowingTracker.h"
#import "GrowingAutotracker.h"
#import "GrowingDispatchManager.h"

@interface GrowingAnalyticsStartTests : XCTestCase

@end

@implementation GrowingAnalyticsStartTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingTrackerStart {
    XCTAssertThrowsSpecificNamed(GrowingTracker.sharedInstance,
                                 NSException,
                                 @"GrowingTracker未初始化");
    
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithProjectId:@"xctest"];
    [GrowingTracker startWithConfiguration:config launchOptions:nil];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertThrowsSpecificNamed([GrowingTracker startWithConfiguration:config launchOptions:nil],
                                     NSException,
                                     @"初始化异常");
    } waitUntilDone:YES];
    
    GrowingTrackConfiguration *config2 = [GrowingTrackConfiguration configurationWithProjectId:@""];
    XCTAssertThrowsSpecificNamed([GrowingTracker startWithConfiguration:config2 launchOptions:nil],
                                 NSException,
                                 @"初始化异常");
}

- (void)testGrowingAutotrackerStart {
    XCTAssertThrowsSpecificNamed(GrowingAutotracker.sharedInstance,
                                 NSException,
                                 @"GrowingAutotracker未初始化");
    
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithProjectId:@"xctest"];
    [GrowingAutotracker startWithConfiguration:config launchOptions:nil];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertThrowsSpecificNamed([GrowingAutotracker startWithConfiguration:config launchOptions:nil],
                                     NSException,
                                     @"初始化异常");
    } waitUntilDone:YES];
    
    GrowingAutotrackConfiguration *config2 = [GrowingAutotrackConfiguration configurationWithProjectId:@""];
    XCTAssertThrowsSpecificNamed([GrowingAutotracker startWithConfiguration:config2 launchOptions:nil],
                                 NSException,
                                 @"初始化异常");
}

- (void)testDefaultConfiguration_Autotracker {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    [GrowingRealAutotracker trackerWithConfiguration:config launchOptions:nil];
    
    GrowingAutotrackConfiguration *configuration = (GrowingAutotrackConfiguration *)GrowingConfigurationManager.sharedInstance.trackConfiguration;
    XCTAssertEqual(configuration.debugEnabled, NO);
    XCTAssertEqual(configuration.cellularDataLimit, 10);
    XCTAssertEqual(configuration.dataUploadInterval, 15);
    XCTAssertEqual(configuration.sessionInterval, 30);
    XCTAssertEqual(configuration.dataCollectionEnabled, YES);
    XCTAssertEqual(configuration.uploadExceptionEnable, YES);
    XCTAssertEqualObjects(configuration.dataCollectionServerHost, @"https://api.growingio.com");
    XCTAssertEqual(configuration.excludeEvent, 0);
    XCTAssertEqual(configuration.ignoreField, 0);
    XCTAssertEqual(configuration.idMappingEnabled, NO);
    XCTAssertEqualObjects(configuration.urlScheme, nil);
    XCTAssertEqual(configuration.encryptEnabled, NO);
    XCTAssertEqual(configuration.impressionScale, 0);
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
    config.impressionScale = 0.5;
    [GrowingRealAutotracker trackerWithConfiguration:config launchOptions:nil];

    GrowingAutotrackConfiguration *configuration = (GrowingAutotrackConfiguration *)GrowingConfigurationManager.sharedInstance.trackConfiguration;
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
    XCTAssertEqual(configuration.impressionScale, 0.5);
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
    XCTAssertEqualObjects(configuration.dataCollectionServerHost, @"https://api.growingio.com");
    XCTAssertEqual(configuration.excludeEvent, 0);
    XCTAssertEqual(configuration.ignoreField, 0);
    XCTAssertEqual(configuration.idMappingEnabled, NO);
    XCTAssertEqualObjects(configuration.urlScheme, nil);
    XCTAssertEqual(configuration.encryptEnabled, NO);
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
