//
//  EventTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/31.
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

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingServiceManager.h"
#import "GrowingEventDatabaseService.h"
#import "Services/Database/GrowingEventFMDatabase.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "MockEventQueue.h"
#import "ManualTrackHelper.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingAppCloseEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitorAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingConversionVariableEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"

@interface EventTest : XCTestCase

@end

@implementation EventTest

+ (void)setUp {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithProjectId:@"test"];
    config.dataSourceId = @"test";
    
    // 避免不执行readPropertyInTrackThread
    config.dataCollectionEnabled = YES;
    // 开启idMapping
    config.idMappingEnabled = YES;
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
    
    // 避免insertEventToDatabase异常
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventDatabaseService)
                                                implClass:GrowingEventFMDatabase.class];
    // 初始化sessionId
    [GrowingSession startSession];
    // userId userKey
    [GrowingSession.currentSession setLoginUserId:@"xctest_userId" userKey:@"xctest_userKey"];
    // latitude longitude
    [GrowingSession.currentSession setLocation:30.123456 longitude:31.123456];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingVisitEvent {
    GrowingVisitEvent.builder.setIdfa(@"testIdfa")
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
        .setDeviceId(@"testdeviceID");
    
    GrowingBaseBuilder *builder = GrowingVisitEvent.builder;
    [GrowingEventManager.sharedInstance postEventBuilder:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 1);
    
    GrowingVisitEvent *event = (GrowingVisitEvent *)events.firstObject;
    XCTAssertEqualObjects(event.eventType, GrowingEventTypeVisit);
    
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeVisit);
    XCTAssertTrue([ManualTrackHelper visitEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
}

- (void)testGrowingCustomEvent {
    GrowingBaseBuilder *builder = GrowingCustomEvent.builder.setEventName(@"custom").setAttributes(@{@"key" : @"value"});
    [GrowingEventManager.sharedInstance postEventBuilder:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    XCTAssertEqual(events.count, 1);
    
    GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
    XCTAssertEqualObjects(event.eventType, GrowingEventTypeCustom);
    XCTAssertEqualObjects(event.eventName, @"custom");
    XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeCustom);
    XCTAssertEqualObjects(dic[@"eventName"], @"custom");
    XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    XCTAssertTrue([ManualTrackHelper customEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
}

- (void)testGrowingLoginUserAttributesEvent {
    GrowingBaseBuilder *builder = GrowingLoginUserAttributesEvent.builder.setAttributes(@{@"key" : @"value"});
    [GrowingEventManager.sharedInstance postEventBuilder:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    XCTAssertEqual(events.count, 1);
    
    GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)events.firstObject;
    XCTAssertEqualObjects(event.eventType, GrowingEventTypeLoginUserAttributes);
    XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeLoginUserAttributes);
    XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    XCTAssertTrue([ManualTrackHelper loginUserAttributesEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
}

- (void)testGrowingConversionVariableEvent {
    GrowingBaseBuilder *builder = GrowingConversionVariableEvent.builder.setAttributes(@{@"key" : @"value"});
    [GrowingEventManager.sharedInstance postEventBuilder:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeConversionVariables];
    XCTAssertEqual(events.count, 1);
    
    GrowingConversionVariableEvent *event = (GrowingConversionVariableEvent *)events.firstObject;
    XCTAssertEqualObjects(event.eventType, GrowingEventTypeConversionVariables);
    XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeConversionVariables);
    XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    XCTAssertTrue([ManualTrackHelper conversionVariablesEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
}

- (void)testGrowingVisitorAttributesEvent {
    GrowingBaseBuilder *builder = GrowingVisitorAttributesEvent.builder.setAttributes(@{@"key" : @"value"});
    [GrowingEventManager.sharedInstance postEventBuilder:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisitorAttributes];
    XCTAssertEqual(events.count, 1);
    
    GrowingVisitorAttributesEvent *event = (GrowingVisitorAttributesEvent *)events.firstObject;
    XCTAssertEqualObjects(event.eventType, GrowingEventTypeVisitorAttributes);
    XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeVisitorAttributes);
    XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    XCTAssertTrue([ManualTrackHelper visitorAttributesEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
}

- (void)testGrowingAppCloseEvent {
    GrowingBaseBuilder *builder = GrowingAppCloseEvent.builder;
    [GrowingEventManager.sharedInstance postEventBuilder:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeAppClosed];
    XCTAssertEqual(events.count, 1);
    
    GrowingAppCloseEvent *event = (GrowingAppCloseEvent *)events.firstObject;
    XCTAssertEqualObjects(event.eventType, GrowingEventTypeAppClosed);
    
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeAppClosed);
    XCTAssertTrue([ManualTrackHelper appCloseEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
}

- (void)testGrowingPageEvent {
    NSString *orientation = self.deviceOrientation;
    GrowingBaseBuilder *builder = GrowingPageEvent.builder
        .setPath(@"path")
        .setOrientation(orientation)
        .setTitle(@"title")
        .setReferralPage(@"referralPage")
        .setAttributes(@{@"key" : @"value"});
    [GrowingEventManager.sharedInstance postEventBuilder:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    
    GrowingPageEvent *event = (GrowingPageEvent *)events.firstObject;
    XCTAssertEqualObjects(event.eventType, GrowingEventTypePage);
    XCTAssertEqualObjects(event.pageName, @"path");
    XCTAssertEqualObjects(event.orientation, orientation);
    XCTAssertEqualObjects(event.title, @"title");
    XCTAssertEqualObjects(event.referralPage, @"referralPage");
    XCTAssertEqualObjects(event.attributes[@"key"], @"value");
    
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
    XCTAssertEqualObjects(dic[@"path"], @"path");
    XCTAssertEqualObjects(dic[@"orientation"], orientation);
    XCTAssertEqualObjects(dic[@"title"], @"title");
    XCTAssertEqualObjects(dic[@"referralPage"], @"referralPage");
    XCTAssertEqualObjects(dic[@"attributes"][@"key"], @"value");
    XCTAssertTrue([ManualTrackHelper pageEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
}

#pragma mark - Private Methods

- (NSString *)deviceOrientation {
    // SDK配置pageEvent.orientation的逻辑
    __block NSString *deviceOrientation = @"PORTRAIT";
    dispatch_block_t block = ^{
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation != UIInterfaceOrientationUnknown) {
            deviceOrientation = UIInterfaceOrientationIsPortrait(orientation) ? @"PORTRAIT" : @"LANDSCAPE";
        }
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
    return deviceOrientation;
}

@end
