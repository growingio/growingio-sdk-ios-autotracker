//
//  GAAdapterTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/24.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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
#import "Modules/GAAdapter/GrowingGAAdapter.h"
#import "GrowingAutotracker.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "MockEventQueue.h"
@import FirebaseCore;
@import FirebaseAnalytics;

@interface GrowingGAAdapter (Private)

@property (nonatomic, assign, getter=isAnalyticsCollectionEnabled) BOOL analyticsCollectionEnabled;
@property (nonatomic, strong) NSMutableDictionary *defaultParameters;

+ (instancetype)sharedInstance;

@end

@interface GAAdapterTest : XCTestCase

@end

@implementation GAAdapterTest

+ (void)setUp {
    // 初始化GrowingAnalytics
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    configuration.sessionInterval = 10.0f;
    configuration.urlScheme = @"growing.xctest";
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
    
    // 初始化FirebaseAnalytics
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:@"1:813277617756:ios:850ccf2e8d5183c5571099"
                                                      GCMSenderID:@"813277617756"];
    options.APIKey = @"AIzaSy1111BC35k111111eyj7KHVw1111OR1111";
    options.projectID = @"ga-adapter";
    [FIRApp configureWithOptions:options];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - FirebaseAnalytics API Test

- (void)test01SetAnalyticsCollectionEnabled {
    {
        int(^getAnalyticsEnabledState)(void) = ^{
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSString *kFIRAPersistedConfigMeasurementEnabledStateKey = @"/google/measurement/measurement_enabled_state";
            return ((NSNumber *)[u objectForKey:kFIRAPersistedConfigMeasurementEnabledStateKey]).intValue;
        };
        
        // 判断是否在Adapter初始化时获取到正确的MeasurementEnabledState
        [GrowingDispatchManager dispatchInGrowingThread:^{
            BOOL enabled = GrowingGAAdapter.sharedInstance.isAnalyticsCollectionEnabled;
            XCTAssertEqual(getAnalyticsEnabledState() != 2/* kFIRAnalyticsEnabledStateSetNo */, enabled);
        } waitUntilDone:YES];
        
        [FIRAnalytics setAnalyticsCollectionEnabled:YES];
        // 判断Adapter.analyticsCollectionEnabled是否设置成功
        [GrowingDispatchManager dispatchInGrowingThread:^{
            BOOL enabled = GrowingGAAdapter.sharedInstance.isAnalyticsCollectionEnabled;
            XCTAssertEqual(YES, enabled);
        } waitUntilDone:YES];
        
        // 因-[FIRAnalytics setAnalyticsCollectionEnabled:]在GA内部线程完成userDefaults字段值更改，
        // 这里通过延时获取来确认MeasurementEnabledState是否已存储在本地
        XCTestExpectation *e = [self expectationWithDescription:@"testSetAnalyticsCollectionEnabled failed : timeout"];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            // 每0.5秒检测一次，直到存储成功或超时
            for (int i = 0; i < 20; i++) {
                int analyticsEnabledState = getAnalyticsEnabledState();
                if (analyticsEnabledState == 1/* kFIRAnalyticsEnabledStateSetYes */) {
                    [e fulfill];
                    break;
                }
                usleep(500 * 1000);
            }
        }];
        [self waitForExpectationsWithTimeout:11.0f handler:nil];
    }
    
    {
        [MockEventQueue.sharedQueue cleanQueue];
        BOOL enabled = NO;
        NSString *eventName = @"name";
        // 当isAnalyticsCollectionEnabled为NO，logEvent调用无效
        [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
        [FIRAnalytics logEventWithName:eventName parameters:nil];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
            XCTAssertEqual(enabled, trackConfiguration.dataCollectionEnabled);
            
            NSArray *events = MockEventQueue.sharedQueue.allEvent;
            XCTAssertEqual(events.count, 0);
        } waitUntilDone:YES];
        
        enabled = YES;
        // 当isAnalyticsCollectionEnabled从NO到YES，将按照GrowingAnalytics的逻辑补发VISIT
        [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
            XCTAssertEqual(enabled, trackConfiguration.dataCollectionEnabled);
            
            NSArray *events = MockEventQueue.sharedQueue.allEvent;
            XCTAssertEqual(events.count, 1); // VISIT
            
            GrowingBaseEvent *event = [MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeVisit];
            XCTAssertTrue([event isKindOfClass:[GrowingVisitEvent class]]);
        } waitUntilDone:YES];
        
        // 当isAnalyticsCollectionEnabled为YES，logEvent调用正常
        [FIRAnalytics logEventWithName:eventName parameters:nil];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSArray *events = MockEventQueue.sharedQueue.allEvent;
            XCTAssertEqual(events.count, 2); // VISIT + CUSTOM
            
            GrowingBaseEvent *event = [MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
            XCTAssertTrue([event isKindOfClass:[GrowingCustomEvent class]]);
            GrowingCustomEvent *customEvent = (GrowingCustomEvent *)event;
            XCTAssertEqualObjects(customEvent.eventName, eventName);
        } waitUntilDone:YES];
    }
}

- (void)test02SetDefaultEventParameters {
    {
        NSDictionary *(^getAnalyticsDefaultEventParameters)(void) = ^{
            NSString *kFIRAPersistedConfigPlistName = @"com.google.gmp.measurement";
            NSUserDefaults *u = [[NSUserDefaults alloc] initWithSuiteName:kFIRAPersistedConfigPlistName];
            NSString *kFIRAPersistedConfigDefaultEventParametersKey = @"/google/measurement/default_event_parameters";
            return ((NSDictionary *)[u objectForKey:kFIRAPersistedConfigDefaultEventParametersKey]);
        };
        
        // 判断是否在Adapter初始化时获取到正确的DefaultParameters
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSDictionary *defaultParameters = GrowingGAAdapter.sharedInstance.defaultParameters;
            NSDictionary *localDefaultParameters = getAnalyticsDefaultEventParameters();
            
            for (NSString *key in localDefaultParameters.allKeys) {
                id value = localDefaultParameters[key];
                id value2 = defaultParameters[key];
                if ([value isKindOfClass:NSString.class]) {
                    if (((NSString *)value).length == 0) {
                        // localDefaultParameters会存储空字符串，但在上报事件时不会附带此字段
                        // 因此Adapter.defaultParameters不存储此字段
                        continue;
                    }
                    XCTAssertEqualObjects(value2, value);
                } else if ([value isKindOfClass:NSNumber.class]) {
                    XCTAssertEqualWithAccuracy(((NSNumber *)value2).doubleValue,
                                               ((NSNumber *)value).doubleValue,
                                               1.0 / pow(10, 15));
                }
            }
        } waitUntilDone:YES];
        
        [FIRAnalytics setDefaultEventParameters:@{@"key" : @"value", @"key2" : @(1.123456789)}];
        // 判断Adapter.defaultParameters是否设置成功
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSDictionary *defaultParameters = GrowingGAAdapter.sharedInstance.defaultParameters;
            XCTAssertEqualObjects(defaultParameters[@"key"], @"value");
            XCTAssertEqualObjects(defaultParameters[@"key2"], @(1.123456789));
        } waitUntilDone:YES];
        
#warning GitHub Action中此步骤会偶现超时，在Xcode模拟器上未复现，可能是环境问题，暂时不执行这个步骤
        /*
        // 因-[FIRAnalytics setDefaultEventParameters:]在GA内部线程完成userDefaults字段值更改，
        // 这里通过延时获取来确认DefaultParameters是否已存储在本地
        XCTestExpectation *e = [self expectationWithDescription:@"testSetDefaultEventParameters failed : timeout"];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            // 每0.5秒检测一次，直到存储成功或超时
            for (int i = 0; i < 20; i++) {
                NSDictionary *localDefaultParameters = getAnalyticsDefaultEventParameters();
                if ([localDefaultParameters[@"key"] isEqual:@"value"]
                    && [localDefaultParameters[@"key2"] isEqual:@(1.123456789)]) {
                    [e fulfill];
                    break;
                }
                usleep(500 * 1000);
            }
        }];
        [self waitForExpectationsWithTimeout:11.0f handler:nil];
         */
    }

    {
        [FIRAnalytics setDefaultEventParameters:nil];
        NSString *key1 = @"key1";
        id value1 = @"value1";
        NSString *key2 = @"key2";
        id value2 = @(123456789);
        NSString *key3 = @"key3";
        id value3 = @(1.123456789);
        NSString *key4 = @"key4";
        id value4 = @(1.12345678901234567890);
        [FIRAnalytics setDefaultEventParameters:@{key1 : value1,
                                                  key2 : value2,
                                                  key3 : value3,
                                                  key4 : value4}];
        // 是否同步到Adapter.defaultParameters
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSDictionary *defaultParameters = GrowingGAAdapter.sharedInstance.defaultParameters;
            XCTAssertEqualObjects(defaultParameters[key1], @"value1");
            XCTAssertEqualObjects(defaultParameters[key2], @(123456789));
            XCTAssertEqualObjects(defaultParameters[key3], @(1.123456789));
            XCTAssertEqualObjects(defaultParameters[key4], @(1.123456789012346));
        } waitUntilDone:YES];
        
        // 新值覆盖旧值
        [FIRAnalytics setDefaultEventParameters:@{key1 : @"valueChange"}];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSDictionary *defaultParameters = GrowingGAAdapter.sharedInstance.defaultParameters;
            XCTAssertEqualObjects(defaultParameters[key1], @"valueChange");
        } waitUntilDone:YES];

        // 非法参数判断
        [FIRAnalytics setDefaultEventParameters:@{key1 : value1}];
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"key_1#" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"1_key" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"_1key" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"ga_1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"firebase_1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"google_1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{@"1234567890"
                                                                   @"1234567890"
                                                                   @"1234567890"
                                                                   @"1234567890"
                                                                   @"1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{key1 : @""}]);
        XCTAssertNoThrow([FIRAnalytics setDefaultEventParameters:@{key1 : @"12345678901234567890123456789012345678901234567890"
                                                                          @"12345678901234567890123456789012345678901234567890"
                                                                          @"1"}]);
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSDictionary *defaultParameters = GrowingGAAdapter.sharedInstance.defaultParameters;
            XCTAssertEqualObjects(defaultParameters[key1], @"value1");
            XCTAssertEqual(defaultParameters.allKeys.count, 4);
        } waitUntilDone:YES];
        
        // key's value设为NSNull则删除此字段
        [FIRAnalytics setDefaultEventParameters:@{key1 : NSNull.null}];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSDictionary *defaultParameters = GrowingGAAdapter.sharedInstance.defaultParameters;
            XCTAssertEqualObjects(defaultParameters[key1], nil);
        } waitUntilDone:YES];
        
        // parameters设为nil则删除所有字段
        [FIRAnalytics setDefaultEventParameters:nil];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSDictionary *defaultParameters = GrowingGAAdapter.sharedInstance.defaultParameters;
            XCTAssertEqual(defaultParameters.allKeys.count, 0);
        } waitUntilDone:YES];
    }
    
    {
        NSString *eventName = @"eventName";
        [FIRAnalytics setDefaultEventParameters:nil];
        NSString *key1 = @"key1";
        id value1 = @"value1";
        NSString *key2 = @"key2";
        id value2 = @(123456789);
        NSString *key3 = @"key3";
        id value3 = @(1.123456789);
        NSString *key4 = @"key4";
        id value4 = @(1.12345678901234567890);
        [FIRAnalytics setDefaultEventParameters:@{key1 : value1,
                                                  key2 : value2,
                                                  key3 : value3,
                                                  key4 : value4}];
        {
            // defaultParameters将在logEvent中附带
            [FIRAnalytics logEventWithName:eventName parameters:nil];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
            XCTAssertEqualObjects(event.eventName, eventName);
            XCTAssertEqual(event.attributes.allKeys.count, 4);
            XCTAssertEqualObjects(event.attributes[key1], @"value1");
            XCTAssertEqualObjects(event.attributes[key2], @"123456789");
            XCTAssertEqualObjects(event.attributes[key3], @"1.123456789");
            XCTAssertEqualObjects(event.attributes[key4], @"1.123456789012346");
        }

        {
            // eventParameters优先级高于defaultEventParameters
            [MockEventQueue.sharedQueue cleanQueue];
            NSString *valueChange = @"valueChange";
            [FIRAnalytics logEventWithName:eventName parameters:@{key1 : valueChange}];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
            XCTAssertEqualObjects(event.eventName, eventName);
            XCTAssertEqual(event.attributes.allKeys.count, 4);
            XCTAssertEqualObjects(event.attributes[key1], valueChange);
            XCTAssertEqualObjects(event.attributes[key2], @"123456789");
            XCTAssertEqualObjects(event.attributes[key3], @"1.123456789");
            XCTAssertEqualObjects(event.attributes[key4], @"1.123456789012346");
        }

        {
            // eventParameters优先级高于defaultEventParameters，无论参数是否合规
            [MockEventQueue.sharedQueue cleanQueue];
            NSNull *valueNull = NSNull.null;
            [FIRAnalytics logEventWithName:eventName parameters:@{key1 : valueNull}];
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);

            GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
            XCTAssertEqualObjects(event.eventName, eventName);
            XCTAssertEqual(event.attributes.allKeys.count, 3);
            XCTAssertEqualObjects(event.attributes[key1], nil);
            XCTAssertEqualObjects(event.attributes[key2], @"123456789");
            XCTAssertEqualObjects(event.attributes[key3], @"1.123456789");
            XCTAssertEqualObjects(event.attributes[key4], @"1.123456789012346");
        }
    }
}

- (void)test03SetUserId {
    NSString *userId = @"123456789";
    {
        [FIRAnalytics setUserID:nil];
        [FIRAnalytics setUserID:userId];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, userId);
        } waitUntilDone:YES];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
        XCTAssertEqual(events.count, 1);
    }
    
    {
        // 长度为0，不作处理
        [FIRAnalytics setUserID:@""];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, userId);
        } waitUntilDone:YES];
    }
    
    {
        // 长度大于256，不作处理
        [FIRAnalytics setUserID:@"12345678901234567890123456789012345678901234567890"
                                @"12345678901234567890123456789012345678901234567890"
                                @"12345678901234567890123456789012345678901234567890"
                                @"12345678901234567890123456789012345678901234567890"
                                @"12345678901234567890123456789012345678901234567890"
                                @"1234567"];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            XCTAssertEqualObjects([GrowingSession currentSession].loginUserId, userId);
        } waitUntilDone:YES];
    }
}

- (void)test04SetUserIdNil {
    [FIRAnalytics setUserID:nil];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertNil([GrowingSession currentSession].loginUserId);
    } waitUntilDone:YES];
}

- (void)test05SetUserPropertyString {
    {
        NSString *value = @"property";
        NSString *key = @"name_1";
        [FIRAnalytics setUserPropertyString:value forName:key];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
        XCTAssertEqual(events.count, 1);
        
        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)events.firstObject;
        XCTAssertEqualObjects(event.attributes[key], value);
    }
    
    {
        // propertyString传nil则清除name对应的用户属性
        [MockEventQueue.sharedQueue cleanQueue];
        NSString *key = @"name_1";
        [FIRAnalytics setUserPropertyString:nil forName:key];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
        XCTAssertEqual(events.count, 1);
        
        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)events.firstObject;
        XCTAssertEqualObjects(event.attributes[key], @"");
    }
        
    {
        // 非法参数判断
        [MockEventQueue.sharedQueue cleanQueue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@"name_1#"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@"1_name"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@"_1name"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@"ga_1"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@"firebase_1"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@"google_1"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@""]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:@"1234567890"
                                                                                 @"1234567890"
                                                                                 @"12345"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"property" forName:nil]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"1234567890"
                                                             @"1234567890"
                                                             @"1234567890"
                                                             @"1234567" forName:@"name_1"]);
        XCTAssertNoThrow([FIRAnalytics setUserPropertyString:@"" forName:@"name_1"]);
#pragma clang diagnostic pop
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
        XCTAssertEqual(events.count, 0);
    }
}

- (void)test06LogEvent {
    NSString *eventName = @"eventName";
    NSString *key1 = @"key1";
    id value1 = @"value1";
    NSString *key2 = @"key2";
    id value2 = @(123456789);
    NSString *key3 = @"key3";
    id value3 = @(1.123456789);
    NSString *key4 = @"key4";
    id value4 = @(1.12345678901234567890);
    {
        [FIRAnalytics logEventWithName:eventName parameters:@{key1 : value1,
                                                              key2 : value2,
                                                              key3 : value3,
                                                              key4 : value4}];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);
            
            GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
            XCTAssertEqualObjects(event.attributes[key1], @"value1");
            XCTAssertEqualObjects(event.attributes[key2], @"123456789");
            XCTAssertEqualObjects(event.attributes[key3], @"1.123456789");
            XCTAssertEqualObjects(event.attributes[key4], @"1.123456789012346");
        } waitUntilDone:YES];
    }
    
    {
        // 非法参数判断，eventName非法则不发送事件
        [MockEventQueue.sharedQueue cleanQueue];
        
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"eventName_1#" parameters:nil]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"1_eventName" parameters:nil]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"_1eventName" parameters:nil]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"ga_1" parameters:nil]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"firebase_1" parameters:nil]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"google_1" parameters:nil]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"" parameters:nil]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:@"1234567890"
                                                        @"1234567890"
                                                        @"1234567890"
                                                        @"1234567890"
                                                        @"1" parameters:nil]);
        
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 0);
        } waitUntilDone:YES];

        // 非法参数判断，parameters非法则不包含parameters
        [FIRAnalytics setDefaultEventParameters:nil];
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"key_1#" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"1_key" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"_1key" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"ga_1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"firebase_1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"google_1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{@"1234567890"
                                                                               @"1234567890"
                                                                               @"1234567890"
                                                                               @"1234567890"
                                                                               @"1" : value1}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{key1 : @""}]);
        XCTAssertNoThrow([FIRAnalytics logEventWithName:eventName parameters:@{key1 : @"123456789012345678901234567890"
                                                                                      @"123456789012345678901234567890"
                                                                                      @"123456789012345678901234567890"
                                                                                      @"12345678901"}]);
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 10);
            
            for (GrowingCustomEvent *event in events) {
                XCTAssertEqual(event.attributes.allKeys.count, 0);
            }
        } waitUntilDone:YES];
    }

    {
        // parameters为nil则仅上报defaultEventParameters
        [MockEventQueue.sharedQueue cleanQueue];
        [FIRAnalytics setDefaultEventParameters:@{key1 : value1}];
        [FIRAnalytics logEventWithName:eventName parameters:nil];
        
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);
            
            GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
            XCTAssertEqualObjects(event.attributes[key1], @"value1");
        } waitUntilDone:YES];
    }
    
    {
        // 上报电子商务事件，含Array类型属性
        [MockEventQueue.sharedQueue cleanQueue];
        [FIRAnalytics logEventWithName:kFIREventBeginCheckout parameters:@{kFIRParameterItems : @[
            @{kFIRParameterItemName : @"item1", kFIRParameterItemCategory : @"category1"},
            @{kFIRParameterItemName : @"item2", kFIRParameterItemCategory : @"category2"},
            @{kFIRParameterItemName : @"item3", kFIRParameterItemCategory : @"category3"}
        ]}];
        
        [GrowingDispatchManager dispatchInGrowingThread:^{
            NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
            XCTAssertEqual(events.count, 1);
            
            GrowingCustomEvent *event = (GrowingCustomEvent *)events.firstObject;
            XCTAssertEqualObjects(event.attributes[@"items_0_item_name"], @"item1");
            XCTAssertEqualObjects(event.attributes[@"items_1_item_name"], @"item2");
            XCTAssertEqualObjects(event.attributes[@"items_2_item_name"], @"item3");
            XCTAssertEqualObjects(event.attributes[@"items_0_item_category"], @"category1");
            XCTAssertEqualObjects(event.attributes[@"items_1_item_category"], @"category2");
            XCTAssertEqualObjects(event.attributes[@"items_2_item_category"], @"category3");
        } waitUntilDone:YES];
    }
}

@end
