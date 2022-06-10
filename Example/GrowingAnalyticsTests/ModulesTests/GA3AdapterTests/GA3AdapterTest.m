//
//  GA3AdapterTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/6/7.
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
#import "Modules/GA3Adapter/Public/GrowingGA3Adapter.h"
#import "Modules/GA3Adapter/GrowingGA3TrackerInfo.h"
#import "Modules/GA3Adapter/GrowingGA3Event.h"
#import "GrowingAutotracker.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageAttributesEvent.h"
#import "MockEventQueue.h"
#import "GrowingTrackerCore/Swizzle/GrowingSwizzler.h"
@import GoogleAnalytics;

@implementation MockEventQueue (GA3EventHandler)

+ (void)load {
    // GA3Adapter通过writeToDatabaseWithEvent:直接入库，不会经过GrowingEventInterceptor，所以这里hook一下
    Class class = GrowingEventManager.class;
    SEL selector = NSSelectorFromString(@"writeToDatabaseWithEvent:");
    id block = ^(id sharedInstance,
                 SEL selector,
                 GrowingBaseEvent *event) {
        if (![event isKindOfClass:GrowingGA3Event.class]) {
            return;
        }
        [MockEventQueue.sharedQueue performSelector:@selector(growingEventManagerEventDidBuild:)
                                         withObject:event];
    };
        
    [GrowingSwizzler growing_swizzleSelector:selector
                                     onClass:class
                                   withBlock:block
                                       named:@"MockEventQueue_GA3EventHandler"];
}

@end

@interface GA3AdapterTest : XCTestCase

@end

@implementation GA3AdapterTest

+ (void)setUp {
    // 初始化GrowingAnalytics
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    configuration.debugEnabled = YES;
    configuration.sessionInterval = 5.0f;
    configuration.urlScheme = @"growing.xctest";
    configuration.dataSourceIds = @{@"UA-XXXX-Y" : @"0000000000000000",
                                    @"UA-1111-Y" : @"1111111111111111",
                                    @"UA-2222-Y" : @"2222222222222222",
                                    @"UA-3333-Y" : @"3333333333333333",
                                    @"UA-4444-Y" : @"4444444444444444"
    };
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
    [GrowingAutotracker.sharedInstance setLoginUserId:@"userId" userKey:@"userKey"];
    
    // 初始化GoogleAnalytics
    GAI.sharedInstance.logger.logLevel = kGAILogLevelVerbose;
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - GoogleAnalytics API Test

- (void)test01EachTrackerAttributes {
    // 测试各个tracker分别设置不同的attributes
    GAI *gai = [GAI sharedInstance];
    id<GAITracker> tracker1 = [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    [tracker1 set:@"key" value:@"value"];

    id<GAITracker> tracker2 = [gai trackerWithName:@"GA3Tracker2" trackingId:@"UA-2222-Y"];
    [tracker2 set:@"key2" value:@"value2"];
    
    id<GAITracker> tracker3 = [gai trackerWithName:@"GA3Tracker3" trackingId:@"UA-3333-Y"];
    [tracker3 set:@"key3" value:@"value3"];
    
    id<GAITracker> tracker4 = [gai trackerWithName:@"GA3Tracker4" trackingId:@"UA-4444-Y"];
    [tracker4 set:@"key4" value:@"value4"];
    
    [tracker1 send:@{@"tracker" : @"1"}];
    [tracker2 send:@{@"tracker" : @"2"}];
    [tracker3 send:@{@"tracker" : @"3"}];
    [tracker4 send:@{@"tracker" : @"4"}];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    XCTAssertEqual(events.count, 4);

    for (GrowingCustomEvent *event in events) {
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventName"], @"GAEvent");
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqual(attr.allKeys.count, 2);
        
        if ([attr[@"tracker"] isEqual:@"1"]) {
            XCTAssertEqualObjects(attr[@"key"], @"value");
        } else if ([attr[@"tracker"] isEqual:@"2"]) {
            XCTAssertEqualObjects(attr[@"key2"], @"value2");
        } else if ([attr[@"tracker"] isEqual:@"3"]) {
            XCTAssertEqualObjects(attr[@"key3"], @"value3");
        } else if ([attr[@"tracker"] isEqual:@"4"]) {
            XCTAssertEqualObjects(attr[@"key4"], @"value4");
        }
    }
    
    [gai removeTrackerByName:@"GA3Tracker1"];
    [gai removeTrackerByName:@"GA3Tracker2"];
    [gai removeTrackerByName:@"GA3Tracker3"];
    [gai removeTrackerByName:@"GA3Tracker4"];
}

- (void)test02ResendLastVisit {
    GrowingBaseBuilder *builder = GrowingVisitEvent.builder;
    [GrowingEventManager.sharedInstance postEventBuidler:builder];

    GrowingVisitEvent *event = (GrowingVisitEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeVisit];
        
    // 新增一个Tracker将补发last VISIT，除了userKey/gioId/dataSourceId/sessionId等等字段，大部分字段值与原事件相同
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    
    GrowingVisitEvent *gaEvent = (GrowingVisitEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeVisit];
    NSDictionary *dic = event.toDictionary;
    NSDictionary *gaDic = gaEvent.toDictionary;

    XCTAssertNil(gaDic[@"userKey"]);
    XCTAssertNil(gaDic[@"gioId"]);
    XCTAssertEqualObjects(gaDic[@"dataSourceId"], @"1111111111111111");
    XCTAssertNotEqualObjects(gaDic[@"sessionId"], dic[@"sessionId"]);
    XCTAssertNotEqualObjects(gaDic[@"userId"], dic[@"userId"]);
    XCTAssertNotEqualObjects(gaDic[@"timestamp"], dic[@"timestamp"]);
    
    XCTAssertEqualObjects(gaDic[@"eventType"], dic[@"eventType"]);
    XCTAssertEqualObjects(gaDic[@"language"], dic[@"language"]);
    XCTAssertEqualObjects(gaDic[@"deviceBrand"], dic[@"deviceBrand"]);
    XCTAssertEqualObjects(gaDic[@"deviceId"], dic[@"deviceId"]);
    XCTAssertEqualObjects(gaDic[@"globalSequenceId"], dic[@"globalSequenceId"]);
    XCTAssertEqualObjects(gaDic[@"urlScheme"], dic[@"urlScheme"]);
    XCTAssertEqualObjects(gaDic[@"deviceType"], dic[@"deviceType"]);
    XCTAssertEqualObjects(gaDic[@"appVersion"], dic[@"appVersion"]);
    XCTAssertEqualObjects(gaDic[@"screenHeight"], dic[@"screenHeight"]);
    XCTAssertEqualObjects(gaDic[@"networkState"], dic[@"networkState"]);
    XCTAssertEqualObjects(gaDic[@"domain"], dic[@"domain"]);
    XCTAssertEqualObjects(gaDic[@"platform"], dic[@"platform"]);
    XCTAssertEqualObjects(gaDic[@"appName"], dic[@"appName"]);
    XCTAssertEqualObjects(gaDic[@"appState"], dic[@"appState"]);
    XCTAssertEqualObjects(gaDic[@"sdkVersion"], dic[@"sdkVersion"]);
    XCTAssertEqualObjects(gaDic[@"deviceModel"], dic[@"deviceModel"]);
    XCTAssertEqualObjects(gaDic[@"screenWidth"], dic[@"screenWidth"]);
    XCTAssertEqualObjects(gaDic[@"idfa"], dic[@"idfa"]);
    XCTAssertEqualObjects(gaDic[@"idfv"], dic[@"idfv"]);
    XCTAssertEqualObjects(gaDic[@"platformVersion"], dic[@"platformVersion"]);
    XCTAssertEqualObjects(gaDic[@"eventSequenceId"], dic[@"eventSequenceId"]);

    [gai removeTrackerByName:@"GA3Tracker1"];
}

- (void)test03ResendLastPage {
    GrowingBaseBuilder *builder = GrowingPageEvent.builder
        .setPath(@"path")
        .setTitle(@"title")
        .setReferralPage(@"referralPage");
    [GrowingEventManager.sharedInstance postEventBuidler:builder];

    // !!! 注意：这里有个隐藏的死锁问题 !!!
    // 首次发送 GrowingPageEvent 时，-[GrowingDeviceInfo deviceOrientation] 中，有个子线程同步等待主线程的操作
    // 如果此时主线程也在同步等待子线程，则会造成死锁，比如在主线程调用以下代码:
    // [GrowingDispatchManager dispatchInGrowingThread:^{} waitUntilDone:YES];
    // 因此，这里在子线程验证PageEvent
    XCTestExpectation *expectation = [self expectationWithDescription:@"testLastPage failed : timeout"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        GrowingPageEvent *event = (GrowingPageEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypePage];
        
        // 新增一个Tracker将补发last PAGE，除了userKey/gioId/dataSourceId/sessionId等等字段，大部分字段值与原事件相同
        GAI *gai = [GAI sharedInstance];
        [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
        
        GrowingPageEvent *gaEvent = (GrowingPageEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypePage];
        NSDictionary *dic = event.toDictionary;
        NSDictionary *gaDic = gaEvent.toDictionary;

        XCTAssertNil(gaDic[@"userKey"]);
        XCTAssertNil(gaDic[@"gioId"]);
        XCTAssertEqualObjects(gaDic[@"dataSourceId"], @"1111111111111111");
        XCTAssertNotEqualObjects(gaDic[@"sessionId"], dic[@"sessionId"]);
        XCTAssertNotEqualObjects(gaDic[@"userId"], dic[@"userId"]);
        XCTAssertNotEqualObjects(gaDic[@"timestamp"], dic[@"timestamp"]);
        
        XCTAssertEqualObjects(gaDic[@"eventType"], dic[@"eventType"]);
        XCTAssertEqualObjects(gaDic[@"language"], dic[@"language"]);
        XCTAssertEqualObjects(gaDic[@"deviceBrand"], dic[@"deviceBrand"]);
        XCTAssertEqualObjects(gaDic[@"deviceId"], dic[@"deviceId"]);
        XCTAssertEqualObjects(gaDic[@"globalSequenceId"], dic[@"globalSequenceId"]);
        XCTAssertEqualObjects(gaDic[@"title"], dic[@"title"]);
        XCTAssertEqualObjects(gaDic[@"urlScheme"], dic[@"urlScheme"]);
        XCTAssertEqualObjects(gaDic[@"deviceType"], dic[@"deviceType"]);
        XCTAssertEqualObjects(gaDic[@"appVersion"], dic[@"appVersion"]);
        XCTAssertEqualObjects(gaDic[@"screenHeight"], dic[@"screenHeight"]);
        XCTAssertEqualObjects(gaDic[@"path"], dic[@"path"]);
        XCTAssertEqualObjects(gaDic[@"networkState"], dic[@"networkState"]);
        XCTAssertEqualObjects(gaDic[@"domain"], dic[@"domain"]);
        XCTAssertEqualObjects(gaDic[@"referralPage"], dic[@"referralPage"]);
        XCTAssertEqualObjects(gaDic[@"platform"], dic[@"platform"]);
        XCTAssertEqualObjects(gaDic[@"appName"], dic[@"appName"]);
        XCTAssertEqualObjects(gaDic[@"appState"], dic[@"appState"]);
        XCTAssertEqualObjects(gaDic[@"sdkVersion"], dic[@"sdkVersion"]);
        XCTAssertEqualObjects(gaDic[@"deviceModel"], dic[@"deviceModel"]);
        XCTAssertEqualObjects(gaDic[@"screenWidth"], dic[@"screenWidth"]);
        XCTAssertEqualObjects(gaDic[@"platformVersion"], dic[@"platformVersion"]);
        XCTAssertEqualObjects(gaDic[@"eventSequenceId"], dic[@"eventSequenceId"]);

        [gai removeTrackerByName:@"GA3Tracker1"];
        
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)test04UploadClientId {
    // 新增一个Tracker将伴随着发送一个LOGIN_USER_ATTRIBUTES事件，上传clientId，用于关联历史数据
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    
    GrowingLoginUserAttributesEvent *gaEvent = (GrowingLoginUserAttributesEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeLoginUserAttributes];
    NSDictionary *gaDic = gaEvent.toDictionary;
    
    XCTAssertNil(gaDic[@"userKey"]);
    XCTAssertNil(gaDic[@"gioId"]);
    XCTAssertEqualObjects(gaDic[@"dataSourceId"], @"1111111111111111");
    XCTAssertNotNil(gaDic[@"sessionId"]);
    XCTAssertNil(gaDic[@"userId"]);
    XCTAssertNotNil(gaDic[@"timestamp"]);
    
    XCTAssertNotNil(gaDic[@"attributes"][@"&cid"]);

    [gai removeTrackerByName:@"GA3Tracker1"];
}

- (void)test05TrackerSetValue {
    GAI *gai = [GAI sharedInstance];
    id<GAITracker> tracker = [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    NSDictionary *params = @{@"tracker" : @"1"};
    
    {
        [tracker set:@"key" value:@"value"];
        [tracker send:params];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqualObjects(attr[@"key"], @"value");
        XCTAssertEqualObjects(attr[@"tracker"], @"1");
    }
    
    {
        // 新值覆盖旧值
        [tracker set:@"key" value:@"valueChange"];
        [tracker send:params];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqualObjects(attr[@"key"], @"valueChange");
        XCTAssertEqualObjects(attr[@"tracker"], @"1");
    }
    
    {
        // 新增属性
        [tracker set:kGAISampleRate value:@"50.0"];
        [tracker send:params];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqualObjects(attr[@"&sf"], @"50.0");
        XCTAssertEqualObjects(attr[@"tracker"], @"1");
    }
    
    {
        // 删除属性
        [tracker set:kGAISampleRate value:nil];
        [tracker send:params];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertNil(attr[@"&sf"]);
        XCTAssertEqualObjects(attr[@"tracker"], @"1");
    }
    
    [gai removeTrackerByName:@"GA3Tracker1"];
}

- (void)test06TrackerSend {
    GAI *gai = [GAI sharedInstance];
    id<GAITracker> tracker = [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    
    {
        // 调用send方法生成GrowingGA3Event，会自动补齐所有字段
        [tracker set:@"key" value:@"value"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"appview", kGAIHitType, @"Home Screen", kGAIScreenName, nil];
        [tracker send:params];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        XCTAssertEqualObjects(dic[@"eventName"], @"GAEvent");
        XCTAssertEqualObjects(dic[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(dic[@"dataSourceId"], @"1111111111111111");
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqual(attr.allKeys.count, 3);
        XCTAssertEqualObjects(attr[@"key"], @"value");
        XCTAssertEqualObjects(attr[@"&cd"], @"Home Screen");
        XCTAssertEqualObjects(attr[@"&t"], @"appview");
        
        XCTAssertNotNil(dic[@"appName"]);
        XCTAssertNotNil(dic[@"appState"]);
        XCTAssertNotNil(dic[@"appVersion"]);
        XCTAssertNotNil(dic[@"deviceBrand"]);
        XCTAssertNotNil(dic[@"deviceId"]);
        XCTAssertNotNil(dic[@"deviceModel"]);
        XCTAssertNotNil(dic[@"deviceType"]);
        XCTAssertNotNil(dic[@"domain"]);
        XCTAssertNotNil(dic[@"eventSequenceId"]);
        XCTAssertNotNil(dic[@"globalSequenceId"]);
        XCTAssertNotNil(dic[@"language"]);
        XCTAssertNotNil(dic[@"networkState"]);
        XCTAssertNotNil(dic[@"platform"]);
        XCTAssertNotNil(dic[@"platformVersion"]);
        XCTAssertNotNil(dic[@"screenHeight"]);
        XCTAssertNotNil(dic[@"screenWidth"]);
        XCTAssertNotNil(dic[@"sdkVersion"]);
        XCTAssertNotNil(dic[@"sessionId"]);
        XCTAssertNotNil(dic[@"timestamp"]);
        XCTAssertNotNil(dic[@"urlScheme"]);
    }
    
    {
        // GAIDictionaryBuilder的使用
        [tracker send:[[[GAIDictionaryBuilder createScreenView] set:@"Home Screen"
                                                             forKey:kGAIScreenName] build]];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        XCTAssertEqualObjects(dic[@"eventName"], @"GAEvent");
        XCTAssertEqualObjects(dic[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(dic[@"dataSourceId"], @"1111111111111111");
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqual(attr.allKeys.count, 3);
        XCTAssertEqualObjects(attr[@"key"], @"value");
        XCTAssertEqualObjects(attr[@"&cd"], @"Home Screen");
        XCTAssertEqualObjects(attr[@"&t"], @"screenview");
        
        XCTAssertNotNil(dic[@"appName"]);
        XCTAssertNotNil(dic[@"appState"]);
        XCTAssertNotNil(dic[@"appVersion"]);
        XCTAssertNotNil(dic[@"deviceBrand"]);
        XCTAssertNotNil(dic[@"deviceId"]);
        XCTAssertNotNil(dic[@"deviceModel"]);
        XCTAssertNotNil(dic[@"deviceType"]);
        XCTAssertNotNil(dic[@"domain"]);
        XCTAssertNotNil(dic[@"eventSequenceId"]);
        XCTAssertNotNil(dic[@"globalSequenceId"]);
        XCTAssertNotNil(dic[@"language"]);
        XCTAssertNotNil(dic[@"networkState"]);
        XCTAssertNotNil(dic[@"platform"]);
        XCTAssertNotNil(dic[@"platformVersion"]);
        XCTAssertNotNil(dic[@"screenHeight"]);
        XCTAssertNotNil(dic[@"screenWidth"]);
        XCTAssertNotNil(dic[@"sdkVersion"]);
        XCTAssertNotNil(dic[@"sessionId"]);
        XCTAssertNotNil(dic[@"timestamp"]);
        XCTAssertNotNil(dic[@"urlScheme"]);
    }
    
    {
        // GAIDictionaryBuilder的使用 - 复杂数据上报
        [tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:@"transactionid111"
                                                                    name:@"name111"
                                                                     sku:@"sku111"
                                                                category:@"category111"
                                                                   price:@50
                                                                quantity:@100
                                                            currencyCode:@"currencyCode111"] build]];
                
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        XCTAssertEqualObjects(dic[@"eventName"], @"GAEvent");
        XCTAssertEqualObjects(dic[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(dic[@"dataSourceId"], @"1111111111111111");
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqual(attr.allKeys.count, 9);
        XCTAssertEqualObjects(attr[@"key"], @"value");
        XCTAssertEqualObjects(attr[@"&cu"], @"currencyCode111");
        XCTAssertEqualObjects(attr[@"&ip"], @"50");
        XCTAssertEqualObjects(attr[@"&ic"], @"sku111");
        XCTAssertEqualObjects(attr[@"&iv"], @"category111");
        XCTAssertEqualObjects(attr[@"&ti"], @"transactionid111");
        XCTAssertEqualObjects(attr[@"&t"], @"item");
        XCTAssertEqualObjects(attr[@"&in"], @"name111");
        XCTAssertEqualObjects(attr[@"&iq"], @"100");
        
        XCTAssertNotNil(dic[@"appName"]);
        XCTAssertNotNil(dic[@"appState"]);
        XCTAssertNotNil(dic[@"appVersion"]);
        XCTAssertNotNil(dic[@"deviceBrand"]);
        XCTAssertNotNil(dic[@"deviceId"]);
        XCTAssertNotNil(dic[@"deviceModel"]);
        XCTAssertNotNil(dic[@"deviceType"]);
        XCTAssertNotNil(dic[@"domain"]);
        XCTAssertNotNil(dic[@"eventSequenceId"]);
        XCTAssertNotNil(dic[@"globalSequenceId"]);
        XCTAssertNotNil(dic[@"language"]);
        XCTAssertNotNil(dic[@"networkState"]);
        XCTAssertNotNil(dic[@"platform"]);
        XCTAssertNotNil(dic[@"platformVersion"]);
        XCTAssertNotNil(dic[@"screenHeight"]);
        XCTAssertNotNil(dic[@"screenWidth"]);
        XCTAssertNotNil(dic[@"sdkVersion"]);
        XCTAssertNotNil(dic[@"sessionId"]);
        XCTAssertNotNil(dic[@"timestamp"]);
        XCTAssertNotNil(dic[@"urlScheme"]);
    }
    
    {
        // 不上报任何属性
        [tracker send:nil];
                
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        XCTAssertEqualObjects(dic[@"eventName"], @"GAEvent");
        XCTAssertEqualObjects(dic[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(dic[@"dataSourceId"], @"1111111111111111");
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqual(attr.allKeys.count, 1);
        XCTAssertEqualObjects(attr[@"key"], @"value");
        
        XCTAssertNotNil(dic[@"appName"]);
        XCTAssertNotNil(dic[@"appState"]);
        XCTAssertNotNil(dic[@"appVersion"]);
        XCTAssertNotNil(dic[@"deviceBrand"]);
        XCTAssertNotNil(dic[@"deviceId"]);
        XCTAssertNotNil(dic[@"deviceModel"]);
        XCTAssertNotNil(dic[@"deviceType"]);
        XCTAssertNotNil(dic[@"domain"]);
        XCTAssertNotNil(dic[@"eventSequenceId"]);
        XCTAssertNotNil(dic[@"globalSequenceId"]);
        XCTAssertNotNil(dic[@"language"]);
        XCTAssertNotNil(dic[@"networkState"]);
        XCTAssertNotNil(dic[@"platform"]);
        XCTAssertNotNil(dic[@"platformVersion"]);
        XCTAssertNotNil(dic[@"screenHeight"]);
        XCTAssertNotNil(dic[@"screenWidth"]);
        XCTAssertNotNil(dic[@"sdkVersion"]);
        XCTAssertNotNil(dic[@"sessionId"]);
        XCTAssertNotNil(dic[@"timestamp"]);
        XCTAssertNotNil(dic[@"urlScheme"]);
    }
    
    [gai removeTrackerByName:@"GA3Tracker1"];
}

- (void)test07SetUserId {
    GAI *gai = [GAI sharedInstance];
    id<GAITracker> tracker = [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    NSString *kGA3UserIdKey = @"&uid";
    [MockEventQueue.sharedQueue cleanQueue];
    
    {
        /*
         A -> nil, A -> A不补发VISIT
         nil -> A, A -> B补发VISIT
         另外：
         SDK 2.0 (A -> nil) -> A 补发，而 SDK 3.0 (A -> nil) -> A 不补发，这里按照 3.0 的逻辑
         */
        
        // nil -> A 发
        [tracker set:kGA3UserIdKey value:@"userIdInGA"];
        XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 1);
        [MockEventQueue.sharedQueue cleanQueue];
        
        // A -> nil 不发
        [tracker set:kGA3UserIdKey value:nil];
        XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 0);
        
        // (A -> nil) -> A 不发
        [tracker set:kGA3UserIdKey value:@"userIdInGA"];
        XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 0);
        
        // A -> A 不发
        [tracker set:kGA3UserIdKey value:@"userIdInGA"];
        XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 0);
        
        // A -> B 发
        [tracker set:kGA3UserIdKey value:@"userIdInGA2"];
        XCTAssertEqual([MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit].count, 1);
    }
    
    NSDictionary *params = @{@"tracker" : @"1"};
    {
        // 设置userId
        [tracker set:kGA3UserIdKey value:@"userIdInGA"];
        [tracker send:params];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        XCTAssertEqualObjects(dic[@"eventName"], @"GAEvent");
        XCTAssertEqualObjects(dic[@"userId"], @"userIdInGA");
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqual(attr.allKeys.count, 1);
        XCTAssertEqualObjects(attr[@"tracker"], @"1");
    }
    
    {
        // 清除userId
        [tracker set:kGA3UserIdKey value:nil];
        [tracker send:params];
        
        GrowingCustomEvent *gaEvent = (GrowingCustomEvent *)[MockEventQueue.sharedQueue lastEventFor:GrowingEventTypeCustom];
        NSDictionary *dic = gaEvent.toDictionary;
        
        XCTAssertEqualObjects(dic[@"eventName"], @"GAEvent");
        XCTAssertNil(dic[@"userId"]);
        NSDictionary *attr = dic[@"attributes"];
        XCTAssertEqual(attr.allKeys.count, 1);
        XCTAssertEqualObjects(attr[@"tracker"], @"1");
    }

    [gai removeTrackerByName:@"GA3Tracker1"];
}

- (void)test08ForwardAutotrackEvent {
    // 转发无埋点事件
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    [MockEventQueue.sharedQueue cleanQueue];
    
    GrowingBaseBuilder *builder = GrowingPageAttributesEvent.builder
        .setPath(@"path")
        .setPageShowTimestamp(1638857558209)
        .setAttributes(@{@"key" : @"value"});
    [GrowingEventManager.sharedInstance postEventBuidler:builder];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePageAttributes];
    XCTAssertEqual(events.count, 2);
    
    GrowingPageAttributesEvent *originEvent;
    GrowingPageAttributesEvent *gaEvent;
    for (int i = 0; i < events.count; i++) {
        GrowingPageAttributesEvent *event = (GrowingPageAttributesEvent *)(events[i]);
        if ([event.toDictionary[@"dataSourceId"] isEqualToString:@"1111111111111111"]) {
            gaEvent = event;
            originEvent = (GrowingPageAttributesEvent *)(events[1 - i]);
            break;
        }
    }
    NSDictionary *dic = originEvent.toDictionary;
    NSDictionary *gaDic = gaEvent.toDictionary;
    
    XCTAssertNil(gaDic[@"userKey"]);
    XCTAssertNil(gaDic[@"gioId"]);
    XCTAssertEqualObjects(gaDic[@"dataSourceId"], @"1111111111111111");
    XCTAssertNotEqualObjects(gaDic[@"sessionId"], dic[@"sessionId"]);
    XCTAssertNotEqualObjects(gaDic[@"userId"], dic[@"userId"]);
    XCTAssertEqualObjects(gaDic[@"timestamp"], dic[@"timestamp"]); // 转发无埋点事件，timestamp相同
    
    XCTAssertEqualObjects(gaDic[@"eventType"], dic[@"eventType"]);
    XCTAssertEqualObjects(gaDic[@"language"], dic[@"language"]);
    XCTAssertEqualObjects(gaDic[@"deviceBrand"], dic[@"deviceBrand"]);
    XCTAssertEqualObjects(gaDic[@"deviceId"], dic[@"deviceId"]);
    XCTAssertEqualObjects(gaDic[@"globalSequenceId"], dic[@"globalSequenceId"]);
    XCTAssertEqualObjects(gaDic[@"urlScheme"], dic[@"urlScheme"]);
    XCTAssertEqualObjects(gaDic[@"deviceType"], dic[@"deviceType"]);
    XCTAssertEqualObjects(gaDic[@"appVersion"], dic[@"appVersion"]);
    XCTAssertEqualObjects(gaDic[@"screenHeight"], dic[@"screenHeight"]);
    XCTAssertEqualObjects(gaDic[@"path"], dic[@"path"]);
    XCTAssertEqualObjects(gaDic[@"pageShowTimestamp"], dic[@"pageShowTimestamp"]);
    XCTAssertEqualObjects(gaDic[@"networkState"], dic[@"networkState"]);
    XCTAssertEqualObjects(gaDic[@"domain"], dic[@"domain"]);
    XCTAssertEqualObjects(gaDic[@"platform"], dic[@"platform"]);
    XCTAssertEqualObjects(gaDic[@"appName"], dic[@"appName"]);
    XCTAssertEqualObjects(gaDic[@"appState"], dic[@"appState"]);
    XCTAssertEqualObjects(gaDic[@"sdkVersion"], dic[@"sdkVersion"]);
    XCTAssertEqualObjects(gaDic[@"deviceModel"], dic[@"deviceModel"]);
    XCTAssertEqualObjects(gaDic[@"screenWidth"], dic[@"screenWidth"]);
    XCTAssertEqualObjects(gaDic[@"platformVersion"], dic[@"platformVersion"]);
    XCTAssertEqualObjects(gaDic[@"eventSequenceId"], dic[@"eventSequenceId"]);
    XCTAssertEqualObjects(gaDic[@"attributes"][@"key"], dic[@"attributes"][@"key"]);

    [gai removeTrackerByName:@"GA3Tracker1"];
}

- (void)test09ApplicationLifeCycle {
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithName:@"GA3Tracker1" trackingId:@"UA-1111-Y"];
    [MockEventQueue.sharedQueue cleanQueue];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    id sharedInstance = [GrowingGA3Adapter performSelector:@selector(sharedInstance)];
    
    NSString *(^getCurrentSessionId)(void) = ^{
        NSDictionary *trackerInfos = [sharedInstance performSelector:@selector(trackerInfos)];
        GrowingGA3TrackerInfo *info = (GrowingGA3TrackerInfo *)(trackerInfos[@"GA3Tracker1"]);
        return info.sessionId;
    };
    
    {
        // 从前台到前台，sessionId不变
        __block NSString *oldSessionId;
        [GrowingDispatchManager dispatchInGrowingThread:^{
            // 保证获取到的是实际值
            oldSessionId = getCurrentSessionId();
        } waitUntilDone:YES];
        
        [sharedInstance performSelector:@selector(applicationDidBecomeActive)];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            // 保证获取到的是实际值
            XCTAssertEqualObjects(oldSessionId, getCurrentSessionId());
        } waitUntilDone:YES];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
        XCTAssertEqual(events.count, 0);
    }
    
    {
        // 从前台到后台
        [sharedInstance performSelector:@selector(applicationDidEnterBackground)];
    }
    
    {
        // 从后台到前台，且超过设置的sessionInterval，sessionId改变，重发VISIT事件
        [sharedInstance performSelector:@selector(applicationWillResignActive)];
        GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        NSTimeInterval sessionInterval = trackConfiguration.sessionInterval;
        sleep((int)(sessionInterval) + 1);
        
        __block NSString *oldSessionId;
        [GrowingDispatchManager dispatchInGrowingThread:^{
            // 保证获取到的是实际值
            oldSessionId = getCurrentSessionId();
        } waitUntilDone:YES];
        
        [sharedInstance performSelector:@selector(applicationDidBecomeActive)];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            // 保证获取到的是实际值
            XCTAssertNotEqualObjects(oldSessionId, getCurrentSessionId());
        } waitUntilDone:YES];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
        XCTAssertEqual(events.count, 1);
        XCTAssertEqualObjects(events[0].toDictionary[@"dataSourceId"], @"1111111111111111");
    }
#pragma clang diagnostic pop
    
    [gai removeTrackerByName:@"GA3Tracker1"];
}

@end
