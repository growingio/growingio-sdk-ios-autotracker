//
// HybirdTests.m
// ExampleTests
//
//  Created by GrowingIO on 9/11/20.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import <WebKit/WebKit.h>
#import "GrowingEventDatabaseService.h"
#import "GrowingServiceManager.h"
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "Modules/Hybrid/Events/GrowingHybridPageEvent.h"
#import "Modules/Hybrid/GrowingHybridBridgeProvider.h"
#import "Services/Protobuf/GrowingEventProtobufDatabase.h"

@interface GrowingHybridBridgeProvider (XCTest)

- (void)dispatchWebViewDomChanged;

- (GrowingBaseBuilder *)transformViewElementBuilder:(NSDictionary *)dict;

- (void)parseEventJsonString:(NSString *)jsonString;

@end

/// 拦截 evaluateJavaScript，取到原生实际下发给页面的回调代码
@interface GrowingHybridMockWebView : WKWebView

@property (nonatomic, copy) NSString *lastJavaScript;
@property (nonatomic, assign) NSUInteger evaluateCount;

@end

@implementation GrowingHybridMockWebView

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    self.lastJavaScript = javaScriptString;
    self.evaluateCount++;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString
                   inFrame:(WKFrameInfo *)frame
            inContentWorld:(WKContentWorld *)contentWorld
         completionHandler:(void (^)(id, NSError *))completionHandler API_AVAILABLE(ios(14.0)) {
    self.lastJavaScript = javaScriptString;
    self.evaluateCount++;
}

@end

@interface HybridTest : XCTestCase

@property (nonatomic, strong) GrowingHybridBridgeProvider *provider;

@end

@implementation HybridTest

- (void)setUp {
    self.provider = GrowingHybridBridgeProvider.sharedInstance;

    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingPBEventDatabaseService)
                                                implClass:GrowingEventProtobufDatabase.class];
    [GrowingSession startSession];
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"test"];
    config.idMappingEnabled = YES;
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
}

- (void)testGrowingHybridBridgeProvider {
    [self.provider handleJavascriptBridgeMessage:@"testHibrid"];

    GrowingBaseBuilder *builder = GrowingHybridPageEvent.builder.setQuery(@"QUERY")
                                      .setPath(@"KEY_PATH")
                                      .setAttributes(@{@"test": @"value"})
                                      .setDomain(@"domain")
                                      .setUserId(@"testUserId")
                                      .setPlatform(@"testPlatform")
                                      .setDeviceId(@"testDeviceId")
                                      .setUrlScheme(@"testUrlScheme")
                                      .setAppState(0)
                                      .setExtraParams(@{})
                                      .setSessionId(@"testSessionId")
                                      .setEventSequenceId(0)
                                      .setPlatformVersion(@"testPlatformVersion");
    XCTAssertNotNil(builder);
    [self.provider handleJavascriptBridgeMessage:@"{@'messageType':@'messagedata'}"];
    [self.provider dispatchWebViewDomChanged];
    WKWebView *_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.provider getDomTreeForWebView:_webView
                      completionHandler:^(NSDictionary *_Nullable dom, NSError *_Nullable error) {
                          NSLog(@"test");
                      }];
    NSString *jsonString =
        @"{\"messageType\":\"dispatchEvent\",\"data\":\"{\"eventType\":\"PAGE\",\"protocolType\":\"http\",\"deviceId\":"
        @"\"4a6e5b29-3a32-42f6-abc0-5bf81beecff9\",\"sessionId\":\"485de03a-7188-49a3-bae2-d915bf17847d\","
        @"\"dataSourceId\":\"955a56011f29a378\",\"timestamp\":1628650812710,\"domain\":\"release-messages.growingio."
        @"cn\",\"path\":\"/push/cdp/"
        @"uat.html\",\"platform\":\"web\",\"screenHeight\":844,\"screenWidth\":390,\"sdkVersion\":\"3.3.0\","
        @"\"language\":\"en-us\",\"title\":\"SDKAutoCheck\",\"globalSequenceId\":2,\"eventSequenceId\":1}\"}";
    [self.provider parseEventJsonString:jsonString];

    NSDictionary *dict = (NSDictionary *)[jsonString growingHelper_jsonObject];
    builder = [self.provider transformViewElementBuilder:dict];
    XCTAssertNotNil(builder);
}

- (void)testSetNativeUserIdAndUserKey {
    NSString *dict =
        @"{\"messageType\":\"setNativeUserIdAndUserKey\",\"data\":\"{\\\"userId\\\":\\\"zhangsan2\\\",\\\"userKey\\\":"
        @"\\\"邮箱\\\"}\"}";
    [self.provider handleJavascriptBridgeMessage:dict];

    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"zhangsan2");
            XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey], @"邮箱");
        }
                  waitUntilDone:YES];
}

- (void)testClearNativeUserIdAndUserKey {
    NSDictionary *dict = @{@"messageType": @"clearNativeUserIdAndUserKey", @"data": @""};
    [self.provider handleJavascriptBridgeMessage:[dict growingHelper_jsonString]];

    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"");
            XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey], @"");
        }
                  waitUntilDone:YES];
}

#pragma mark - getNativeIdentity

- (void)testGetNativeIdentityWithoutLoginUser {
    [[GrowingSession currentSession] setLoginUserId:nil];
    GrowingHybridMockWebView *webView = [self mockWebView];

    [self sendGetNativeIdentityWithCallbackId:@"gio_1_1628650812710" webView:webView];

    XCTAssertEqual(webView.evaluateCount, 1);
    NSDictionary *identity = [self identityFromWebView:webView callbackId:@"gio_1_1628650812710"];
    XCTAssertEqualObjects(identity[@"deviceId"], [GrowingDeviceInfo currentDeviceInfo].deviceIDString);
    XCTAssertNil(identity[@"userId"]);
    XCTAssertNil(identity[@"userKey"]);
    // isNewDevice 恒返回，不因取值为 NO 而缺省
    XCTAssertTrue([identity[@"isNewDevice"] isKindOfClass:NSNumber.class]);
    XCTAssertEqualObjects(identity[@"isNewDevice"], @([GrowingDeviceInfo currentDeviceInfo].isNewDeviceInFirstSession));
}

- (void)testGetNativeIdentityWithLoginUser {
    [[GrowingSession currentSession] setLoginUserId:@"zhangsan" userKey:@"邮箱"];
    GrowingHybridMockWebView *webView = [self mockWebView];

    [self sendGetNativeIdentityWithCallbackId:@"gio_2_1628650812710" webView:webView];

    NSDictionary *identity = [self identityFromWebView:webView callbackId:@"gio_2_1628650812710"];
    XCTAssertEqualObjects(identity[@"userId"], @"zhangsan");
    XCTAssertEqualObjects(identity[@"userKey"], @"邮箱");
}

- (void)testGetNativeIdentityWithoutIdMapping {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"test"];
    config.idMappingEnabled = NO;
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
    [[GrowingSession currentSession] setLoginUserId:nil];
    [[GrowingSession currentSession] setLoginUserId:@"zhangsan" userKey:@"邮箱"];
    GrowingHybridMockWebView *webView = [self mockWebView];

    [self sendGetNativeIdentityWithCallbackId:@"gio_3_1628650812710" webView:webView];

    NSDictionary *identity = [self identityFromWebView:webView callbackId:@"gio_3_1628650812710"];
    XCTAssertEqualObjects(identity[@"userId"], @"zhangsan");
    XCTAssertNil(identity[@"userKey"]);
}

- (void)testGetNativeIdentityWithInvalidCallbackId {
    NSArray<NSString *> *invalidCallbackIds = @[
        @"a'); alert(1); ('",
        @"gio_1'",
        @"gio 1",
        @"",
        [@"" stringByPaddingToLength:65 withString:@"a" startingAtIndex:0]
    ];

    for (NSString *callbackId in invalidCallbackIds) {
        GrowingHybridMockWebView *webView = [self mockWebView];
        [self sendGetNativeIdentityWithCallbackId:callbackId webView:webView];
        XCTAssertEqual(webView.evaluateCount, 0, @"callbackId 应被拦截: %@", callbackId);
    }
}

- (void)testGetNativeIdentityWithMalformedMessage {
    GrowingHybridMockWebView *webView = [self mockWebView];
    NSString *message = [@{@"messageType": @"getNativeIdentity", @"data": @"not a json"} growingHelper_jsonString];
    [self.provider handleJavascriptBridgeMessage:message fromWebView:webView frameInfo:nil];
    XCTAssertEqual(webView.evaluateCount, 0);

    // 缺少 callbackId
    NSString *emptyData = [@{} growingHelper_jsonString];
    message = [@{@"messageType": @"getNativeIdentity", @"data": emptyData} growingHelper_jsonString];
    [self.provider handleJavascriptBridgeMessage:message fromWebView:webView frameInfo:nil];
    XCTAssertEqual(webView.evaluateCount, 0);
}

- (void)testGetNativeIdentityWithoutWebView {
    // WKScriptMessage.webView 为 weak，页面销毁后为 nil，不应崩溃
    NSString *data = [@{@"callbackId": @"gio_4_1628650812710"} growingHelper_jsonString];
    NSString *message = [@{@"messageType": @"getNativeIdentity", @"data": data} growingHelper_jsonString];
    XCTAssertNoThrow([self.provider handleJavascriptBridgeMessage:message]);
}

- (void)testIsNewDeviceInFirstSession {
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    BOOL expected = deviceInfo.isNewDevice && [GrowingSession currentSession].firstSession;
    XCTAssertEqual(deviceInfo.isNewDeviceInFirstSession, expected);
}

#pragma mark - Helper

- (GrowingHybridMockWebView *)mockWebView {
    return [[GrowingHybridMockWebView alloc] initWithFrame:CGRectZero];
}

- (void)sendGetNativeIdentityWithCallbackId:(NSString *)callbackId webView:(WKWebView *)webView {
    NSString *data = [@{@"callbackId": callbackId} growingHelper_jsonString];
    NSString *message = [@{@"messageType": @"getNativeIdentity", @"data": data} growingHelper_jsonString];
    [self.provider handleJavascriptBridgeMessage:message fromWebView:webView frameInfo:nil];
}

- (NSDictionary *)identityFromWebView:(GrowingHybridMockWebView *)webView callbackId:(NSString *)callbackId {
    NSString *javaScript = webView.lastJavaScript;
    NSString *prefix =
        [NSString stringWithFormat:@"window.GrowingWebViewJavascriptBridge._onNativeCallback('%@', ", callbackId];
    XCTAssertTrue([javaScript hasPrefix:prefix], @"实际下发: %@", javaScript);
    XCTAssertTrue([javaScript hasSuffix:@");"], @"实际下发: %@", javaScript);

    NSRange range = NSMakeRange(prefix.length, javaScript.length - prefix.length - 2);
    id identity = [[javaScript substringWithRange:range] growingHelper_jsonObject];
    XCTAssertTrue([identity isKindOfClass:NSDictionary.class]);
    return (NSDictionary *)identity;
}

@end
