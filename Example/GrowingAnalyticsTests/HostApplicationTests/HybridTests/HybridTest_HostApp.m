//
//  HybridTest_HostApp.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/2/8.
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


#import <KIF/KIF.h>

#import <WebKit/WebKit.h>
#import "GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "GrowingTrackEventType.h"
#import "GrowingLoginUserAttributesEvent.h"
#import "GrowingConversionVariableEvent.h"
#import "GrowingHybridEventType.h"
#import "GrowingHybridViewElementEvent.h"
#import "GrowingHybridPageEvent.h"
#import "GrowingHybridCustomEvent.h"
#import "GrowingHybridPageAttributesEvent.h"
#import "ManualTrackHelper.h"
#import "GrowingDispatchManager.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingHybridBridgeProvider.h"
#import "GrowingWebViewDomChangedDelegate.h"

@interface HybridTest_HostApp : KIFTestCase <GrowingWebViewDomChangedDelegate>

@end

@implementation HybridTest_HostApp

- (void)beforeAll {
    // userId userKey
    [GrowingAutotracker.sharedInstance setLoginUserId:@"xctest_userId" userKey:@"xctest_userKey"];
    // latitude longitude
    [GrowingAutotracker.sharedInstance setLocation:30.12345 longitude:31.123456];
    
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"Hybrid"] tap];
    [viewTester waitForTimeInterval:10];
}

- (void)afterAll {
    [[viewTester usingLabel:@"UI界面"] tap];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test01SendMockVisitEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockVisitEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeVisit];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeVisit);
    XCTAssertTrue([ManualTrackHelper visitEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
}

- (void)test02SendMockCustomEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockCustomEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeCustom);
    XCTAssertTrue([ManualTrackHelper customEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
    XCTAssertEqualObjects(dic[@"eventName"], @"test_name");
}

- (void)test03SendMockCustomEventWithAttributes {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockCustomEventWithAttributes()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeCustom];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeCustom);
    XCTAssertTrue([ManualTrackHelper customEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
    XCTAssertEqualObjects(dic[@"eventName"], @"test_name");
}

- (void)test04SendMockLoginUserAttributesEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockLoginUserAttributesEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    XCTAssertEqual(events.count, 1);
    
    GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeLoginUserAttributes);
    XCTAssertTrue([ManualTrackHelper loginUserAttributesEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"attributes"][@"key1"], @"value1");
    XCTAssertEqualObjects(dic[@"attributes"][@"key2"], @"value2");
}

- (void)test05SendMockConversionVariablesEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockConversionVariablesEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeConversionVariables];
    XCTAssertEqual(events.count, 1);
    
    GrowingConversionVariableEvent *event = (GrowingConversionVariableEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeConversionVariables);
    XCTAssertTrue([ManualTrackHelper conversionVariablesEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertNotNil(dic[@"attributes"]);
}

- (void)test06SendMockPageEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockPageEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
    XCTAssertTrue([ManualTrackHelper pageEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"title"], @"Hybrid测试页面");
}

- (void)test07SendMockPageEventWithQuery {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockPageEventWithQuery()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePage];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePage);
    XCTAssertTrue([ManualTrackHelper pageEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"title"], @"Hybrid测试页面");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
}

- (void)test08SendMockPageAttributesEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockPageAttributesEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePageAttributes];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridPageAttributesEvent *event = (GrowingHybridPageAttributesEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypePageAttributes);
    XCTAssertTrue([ManualTrackHelper pageAttributesEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
}

- (void)test09SendMockViewClickEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockViewClickEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
    XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
    XCTAssertEqualObjects(dic[@"textValue"], @"登录");
}

- (void)test10SendMockViewChangeEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockViewChangeEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewChange);
    XCTAssertTrue([ManualTrackHelper viewChangeEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
    XCTAssertEqualObjects(dic[@"textValue"], @"输入内容");
}

- (void)test11SendMockFormSubmitEvent {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"sendMockFormSubmitEvent()"];
    [viewTester waitForTimeInterval:1];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeFormSubmit];
    XCTAssertEqual(events.count, 1);
    
    GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeFormSubmit);
    XCTAssertTrue([ManualTrackHelper hybridFormSubmitEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"domain"], @"test-browser.growingio.com");
    XCTAssertEqualObjects(dic[@"path"], @"/push/web.html");
    XCTAssertEqualObjects(dic[@"query"], @"a=1&b=2");
}

- (void)test12MockSetUserId {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"mockSetUserId('xctest_userId_hybrid')"];
    [viewTester waitForTimeInterval:1];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"xctest_userId_hybrid");
    } waitUntilDone:YES];
}

- (void)test13MockClearUserId {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"mockClearUserId()"];
    [viewTester waitForTimeInterval:1];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"");
    } waitUntilDone:YES];
}

- (void)test14MockSetUserIdAndUserKey {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"mockSetUserIdAndUserKey('xctest_userId_hybrid2', 'xctest_userKey_hybrid2')"];
    [viewTester waitForTimeInterval:1];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"xctest_userId_hybrid2");
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey], @"xctest_userKey_hybrid2");
    } waitUntilDone:YES];
}

- (void)test15MockClearUserIdAndUserKey {
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"mockClearUserIdAndUserKey()"];
    [viewTester waitForTimeInterval:1];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"");
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey], @"");
    } waitUntilDone:YES];
}

static int XCTest_didDomChanged = 0;
- (void)test16MockDomChanged {
    [GrowingHybridBridgeProvider sharedInstance].domChangedDelegate = self;
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"HybridWebView"];
    [self webView:actor.view evaluateJavaScript:@"mockDomChanged()"];
    [viewTester waitForTimeInterval:1];
    XCTAssertEqual(XCTest_didDomChanged, 1);
}

#pragma mark - GrowingWebViewDomChangedDelegate

- (void)webViewDomDidChanged {
    XCTest_didDomChanged = 1;
}

#pragma mark - Private Methods

- (void)webView:(UIView *)view evaluateJavaScript:(NSString *)js {
    if (!view || ![view isKindOfClass:WKWebView.class]) {
        return;
    }
    WKWebView *webView = (WKWebView *)view;
    [webView evaluateJavaScript:js completionHandler:nil];
}

@end
