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
#import "GrowingDispatchManager.h"
#import "GrowingHybridBridgeProvider.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingHybridPageAttributesEvent.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSString+GrowingHelper.h"
#import "GrowingSession.h"
#import "GrowingConfigurationManager.h"
#import "GrowingEventGenerator.h"
#import "GrowingServiceManager.h"
#import "GrowingEventDatabaseService.h"
#import "GrowingEventFMDatabase.h"

@interface GrowingHybridBridgeProvider (XCTest)

- (void)dispatchWebViewDomChanged;

- (GrowingBaseBuilder *)transformViewElementBuilder:(NSDictionary *)dict;

- (void)parseEventJsonString:(NSString *)jsonString;

@end

@interface HybridTest : XCTestCase

@property (nonatomic, strong) GrowingHybridBridgeProvider *provider;

@end

@implementation HybridTest

- (void)setUp {
    self.provider = GrowingHybridBridgeProvider.sharedInstance;
    
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventDatabaseService)
                                                implClass:GrowingEventFMDatabase.class];
    [GrowingSession startSession];
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithProjectId:@"test"];
    config.idMappingEnabled = YES;
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
}

- (void)testGrowingHybridBridgeProvider {
    [self.provider handleJavascriptBridgeMessage:@"testHibrid"];

    GrowingBaseBuilder *builder = GrowingHybridPageAttributesEvent.builder.setQuery(@"QUERY")
                                      .setPath(@"KEY_PATH")
                                      .setPageShowTimestamp(123456)
                                      .setAttributes(@{@"test" : @"value"})
                                      .setDomain(@"domain")
                                      .setUserId(@"testUserId")
                                      .setPlatform(@"testPlatform")
                                      .setDeviceId(@"testDeviceId")
                                      .setUrlScheme(@"testUrlScheme")
                                      .setAppState(0)
                                      .setExtraParams(@{})
                                      .setSessionId(@"testSessionId")
                                      .setGlobalSequenceId(0)
                                      .setEventSequenceId(0)
                                      .setPlatformVersion(@"testPlatformVersion");
    XCTAssertNotNil(builder);
    [self.provider handleJavascriptBridgeMessage:@"{@'messageType':@'messagedata'}"];
    [self.provider dispatchWebViewDomChanged];
    WKWebView *_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.provider getDomTreeForWebView:_webView completionHandler:^(NSDictionary *_Nullable dom, NSError *_Nullable error) {
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
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"zhangsan2");
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey], @"邮箱");
    } waitUntilDone:YES];
}

- (void)testClearNativeUserIdAndUserKey {
    NSDictionary *dict = @{@"messageType" : @"clearNativeUserIdAndUserKey", @"data" : @""};
    [self.provider handleJavascriptBridgeMessage:[dict growingHelper_jsonString]];
    
    [GrowingDispatchManager dispatchInGrowingThread:^{
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"");
        XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey], @"");
    } waitUntilDone:YES];
}

@end
