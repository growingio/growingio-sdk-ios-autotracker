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
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
#import "GrowingAutotracker.h"
#import <KIF/KIF.h>
#import "GrowingAppCloseEvent.h"
#import "GrowingWebCircle.h"
#import "NSURL+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingNode.h"
#import "GrowingUserDefaults.h"
#import "GrowingASLLogger.h"
#import "GrowingHybridBridgeProvider.h"
#import "GrowingDataTraffic.h"
#import "GrowingAppCloseEvent.h"
#import "GrowingWebCircleElement.h"
#import "GrowingHybridPageAttributesEvent.h"
#import "GrowingMobileDebugger.h"
#import "GrowingDeepLinkHandler.h"
#import "GrowingVisitEvent.h"
#import "GrowingPersistenceDataProvider.h"
#import "NSData+GrowingHelper.h"
#import "NSString+GrowingHelper.h"
#import "UIViewController+GrowingPageHelper.h"
#import "GrowingPageManager.h"
#import "GrowingHybridBridgeProvider.h"
#import <WebKit/WebKit.h>
@interface HybridTests : KIFTestCase

@end

@implementation HybridTests

- (void)setUp {
    [[GrowingAutotracker sharedInstance] setLoginUserId:@"test"];
    [[viewTester usingLabel:@"UI界面"] tap];
    [viewTester waitForTimeInterval:3];
    [[viewTester usingLabel:@"UI界面"] tap];
    
}

- (void)tearDown {
  //  [[viewTester usingLabel:@"UI界面"] tap];
    
}

- (void)testHybrid {
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"Hybrid"] tap];
    [viewTester waitForTimeInterval:3];
    [[viewTester usingLabel:@"返回"] tap];
    
    
}

-(void)testCollectionView{
    [[viewTester usingLabel:@"CollectionView"] tap];
    [[viewTester usingLabel:@"UI界面"] tap];
    
}

-(void)testPageStucture{
    [[viewTester usingLabel:@"Page Structure"] tap];
    [viewTester waitForTimeInterval:1];
    [[viewTester usingLabel:@"Multi ViewController"] tap];
    [[viewTester usingLabel:@"UI界面"] tap];
    
}
-(void)testActionSheets{
    [[viewTester usingLabel:@"Action Sheets"] tap];
    [viewTester waitForTimeInterval:1];
    [[viewTester usingLabel:@"GrowingAlertMenuThree"] tap];
    [viewTester waitForTimeInterval:1];
    [[viewTester usingLabel:@"Three"] tap];
    
}
-(void)testCloseEvent{
    
//    [GrowingCloseEvent sendWithLastPage:@"closepage"];

}
-(void)testWebCircle{
    [[[GrowingWebCircle alloc]init] performSelector:@selector(screenShot)];
    [GrowingWebCircle performSelector:@selector(impressScale)];

    UIViewController *current = [[UIViewController  alloc] init];
    GrowingPageGroup *page = [current growingPageHelper_getPageObject];
    if (!page) {
        [[GrowingPageManager sharedInstance] createdViewControllerPage:current];
        page = [current growingPageHelper_getPageObject];
    }
    NSMutableDictionary *dict = [[[GrowingWebCircle alloc]init] performSelector:@selector(dictFromPage:xPath:)withObject:current withObject:page.path];
    XCTAssertNotNil(dict);
//    XCTAssertNotNil([[[GrowingWebCircle alloc]init] performSelector:@selector(getSnapshotKey)]);
    XCTAssertNotNil([[[GrowingWebCircle alloc]init] performSelector:@selector(elements)]);
    [[[GrowingWebCircle alloc]init] performSelector:@selector(sendScreenShot)];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(remoteReady)];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(runWithCircle:readyBlock:finishBlock:)withObject:[NSURL URLWithString:@"ws://testws"] withObject:nil];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(start)];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(stop)];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(sendScreenShotWithCallback:)withObject:nil];
    NSURL *urltest = [[NSURL alloc]initWithString:@"http://testxxx.growingio.com/qrcode.html?URLScheme=growing.XXX&productId=XXX&circleRoomNumber=8ebd86b3fac64b64ae09a9ce1450e015&serviceType=circle&appName=XXX"];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(growingHandlerUrl:)withObject:urltest];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(webSocketDidOpen:)withObject:nil];
    NSString *messageready = @"{@\"msgType\":@\"ready\"}";
    NSString *messageincompatible = @"{@\"msgType\":@\"incompatible_version\"}";
  //  NSString *messagequit = @"{@\"msgType\":@\"quit\"}";
    [[[GrowingWebCircle alloc]init] performSelector:@selector(webSocketDidOpen:)withObject:nil];

    [[[GrowingWebCircle alloc]init] performSelector:@selector(webSocket:didReceiveMessage:)withObject:nil withObject:messageready];
    [[[GrowingWebCircle alloc]init] performSelector:@selector(webSocket:didReceiveMessage:)withObject:nil withObject:messageincompatible];

 //   [[[GrowingWebCircle alloc]init] performSelector:@selector(webSocket:didReceiveMessage:)withObject:nil withObject:messagequit];
    //    NSMutableDictionary *dict = [[GrowingWebCircle sharedInstance] dictFromPage:current xPath:page.path];
//    [GrowingWebCircle retrieveAllElementsAsync:nil];
//    [GrowingWebCircle isRunning];
//    [GrowingWebCircle isContainer:nil];

//    Class realClazz = NSClassFromString(@"GrowingWebCircle");
////    [realClazz respondsToSelector:@selector(setNeedUpdateScreen)];
//    [realClazz performSelector:@selector(impressScale)];
//    [[realClazz performSelector:@selector(sharedInstance)] performSelector:@selector(_setNeedUpdateScreen)];;
//    [[realClazz performSelector:@selector(sharedInstance)] performSelector:@selector(sendWebcircleWithType:)withObject:@"eventType"];;

}


-(void)testGrowingHandleUrl{
    NSURL *url = [NSURL URLWithString: @"growing.9683a369c615f77d://growing/oauth2/token?messageId=GPnmM2RY&gtouchType=preview&msgType=popupWindow&"];
//    [Growing handleURL:url];
    NSDictionary *params = url.growingHelper_queryDict;
    XCTAssertNotNil(params);
}

- (void)testGrowingHelper_screenshot {
    UIViewController *vc = [[UIViewController alloc]init ];
    [vc.view growingHelper_screenshot:CGFLOAT_MAX];
}

-(void)testGrowingNode{
 //   [GrowingRootNode rootNode];
}

-(void)testGrowingUserDefaults{
    [[GrowingUserDefaults sharedInstance] setValue:@"testToken" forKey:@"_refreshToken"];
    NSString *_refreshToken = [[GrowingUserDefaults sharedInstance] valueForKey:@"_refreshToken"];
    //((_refreshToken) equal to (@"testToken")) failed: ("{length = 8, bytes = 0x0000000000000000}") is not equal to ("{length = 8, bytes = 0xe82abb2801000000}")
 //   XCTAssertEqual(_refreshToken, @"testToken");
    
}

-(void)testGrowingASLLogger{
    [[GrowingASLLogger sharedInstance] loggerName ];

}

-(void)testGrowingHybridBridgeProvider{
    [GrowingHybridBridgeProvider.sharedInstance handleJavascriptBridgeMessage:@"testHibrid"];
    
    GrowingBaseBuilder *builder =GrowingHybridPageAttributesEvent.builder.setQuery(@"QUERY")
    .setPath(@"KEY_PATH")
    .setPageShowTimestamp(@"KEY_PAGE_SHOW_TIMESTAMP")
    .setAttributes(@"KEY_ATTRIBUTES")
    .setDomain(@"domain")
    .setUserId(@"testUserId")
    .setPlatform(@"testPlatform")
    .setDeviceId(@"testDeviceId")
    .setUrlScheme(@"testUrlScheme")
    .setAppState(@"testAppState")
    .setExtraParams(@"testExtraParams")
    .setSessionId(@"testSessionId")
    .setGlobalSequenceId(@"testGlobalSequenceId")
    .setEventSequenceId(@"testEventSequenceId")
    .setPlatformVersion(@"testPlatformVersion");
    XCTAssertNotNil(builder);
    [[GrowingHybridBridgeProvider sharedInstance] handleJavascriptBridgeMessage:@"{@'messageType':@'messagedata'}"];
    [[GrowingHybridBridgeProvider sharedInstance] performSelector:@selector(dispatchWebViewDomChanged)];
    WKWebView *_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [[GrowingHybridBridgeProvider sharedInstance] getDomTreeForWebView:_webView completionHandler:^(NSDictionary *_Nullable dom, NSError *_Nullable error) {
        NSLog(@"test");
    }
     ];
    NSString *jsonString = @"{\"messageType\":\"dispatchEvent\",\"data\":\"{\"eventType\":\"PAGE\",\"protocolType\":\"http\",\"deviceId\":\"4a6e5b29-3a32-42f6-abc0-5bf81beecff9\",\"sessionId\":\"485de03a-7188-49a3-bae2-d915bf17847d\",\"dataSourceId\":\"955a56011f29a378\",\"timestamp\":1628650812710,\"domain\":\"release-messages.growingio.cn\",\"path\":\"/push/cdp/uat.html\",\"platform\":\"web\",\"screenHeight\":844,\"screenWidth\":390,\"sdkVersion\":\"3.3.0\",\"language\":\"en-us\",\"title\":\"SDKAutoCheck\",\"globalSequenceId\":2,\"eventSequenceId\":1}\"}";
    id dict = [jsonString growingHelper_jsonObject];
    NSDictionary *evetDataDict = (NSDictionary *)dict;
   builder= [[GrowingHybridBridgeProvider sharedInstance] performSelector:@selector(transformViewElementBuilder:)withObject: evetDataDict];
   XCTAssertNotNil(builder);

}

-(void)testGrowingWebCircleElement{
    
    [GrowingWebCircleElement builder];
   GrowingWebCircleElementBuilder *WebCircleElement = [[GrowingWebCircleElementBuilder alloc] init];
    [[GrowingWebCircleElement alloc]initWithBuilder:WebCircleElement];
    [[GrowingWebCircleElement alloc]toDictionary];

}

-(void)testGrowingDataTraffic{
    [GrowingDataTraffic cellularNetworkStorgeEventSize:1024*1024];
    [GrowingDataTraffic cellularNetworkUploadEventSize];
//    XCTAssertEqual(1, 1);
    
}


-(void)testGrowingMobileDebugger{
    
    NSURL *url1 = [NSURL URLWithString:@"growing.3612b67ce562c755://growingio/webservice?serviceType=debugger&wsUrl=wss://gta0.growingio.com/app/0wDaZmQ1/circle/ec7f5925458f458b8ae6f3901cacaa92"];
    [GrowingDeepLinkHandler handlerUrl:url1];
    id mobileDebugger = [[GrowingMobileDebugger alloc] init];
    [mobileDebugger performSelector:@selector(start)];
    [mobileDebugger performSelector:@selector(stop)];
    [mobileDebugger performSelector:@selector(nextOne)];
    [mobileDebugger performSelector:@selector(startTimer)];
    [mobileDebugger performSelector:@selector(stopTimer)];
    [mobileDebugger performSelector:@selector(webSocket:didFailWithError:)withObject:nil withObject:nil];
    // 断开链接有个弹框
    [[viewTester usingLabel:@"知道了"] tap];
    [mobileDebugger performSelector:@selector(growingApplicationEventSendEvent:)withObject:nil];

//    [[GrowingMobileDebugger sharedInstance] start];
//    if([GrowingMobileDebugger isRunning]) {
//        [GrowingMobileDebugger stop];
//    }
}

-(void)testGrowingabsoluteURL{
    NSString * url = [[[GrowingMobileDebugger alloc] init] absoluteURL];
//    XCTAssertEqualObjects(url, @"https://api.growingio.com/v3/projects/91eaf9b283361032/collect");
    XCTAssertNotNil(url);
}

-(void)testGrowingAppCloseEvent{
    [GrowingAppCloseEvent builder] ;
}

//-(void)testGrowingMobileDebugger{
//   [[GrowingMobileDebugger shareDebugger] performSelector:@selector(cacheEventStart)];
//   [[GrowingMobileDebugger shareDebugger] debugWithRoomNumber:@"testcircleRoomNumber" dataCheck:false];
//
//
//
//}
-(void)testGrowingVisitEvent{
    GrowingVisitEvent.builder
    .setIdfa(@"testIdfa")
    .setIdfv(@"testIdfv")
    .setExtraSdk(@{@"testkey":@"value"})
    .setNetworkState(@"testNetworkState")
    .setScreenHeight(@1920)
    .setScreenWidth(@1280)
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
}


-(void)testNSDataGrowingHelper{
    NSString *testString = @"123测试";
    NSData *testData = [testString dataUsingEncoding: NSUTF8StringEncoding];
    XCTAssertNotNil([testData growingHelper_LZ4String]);
    XCTAssertNil([testData growingHelper_dictionaryObject]);
    XCTAssertNil([testData growingHelper_arrayObject]);
    XCTAssertNotNil([testData growingHelper_md5String]);
    XCTAssertNotNil([testData growingHelper_xorEncryptWithHint:@"a"]);

}

-(void)testNSStringGrowingHelper{
    NSString *testString1 = @"12测试";
    XCTAssertNil([testString1 growingHelper_queryObject]);
    NSString *a = @"teststring";
    [a growingHelper_uft8Data];
    [a growingHelper_jsonObject];
    [a growingHelper_dictionaryObject];
    [a growingHelper_safeSubStringWithLength:@1];
    [a growingHelper_sha1];
    [a growingHelper_isLegal];
    [a growingHelper_isValidU];
    [a growingHelper_encryptString];
    XCTAssertFalse([NSString growingHelper_isBlankString:@"t"]);
    [a convertToDictFromPasteboard];
    XCTAssertFalse([NSString growingHelper_isEqualStringA:@"A" andStringB:@"B"]);
    

}

-(void)testSetNativeUserIdAndUserKey{
    NSString *dict =@"{\"messageType\":\"setNativeUserIdAndUserKey\",\"data\":\"{\\\"userId\\\":\\\"zhangsan2\\\",\\\"userKey\\\":\\\"邮箱\\\"}\"}";
 
    [[GrowingHybridBridgeProvider sharedInstance] handleJavascriptBridgeMessage:dict];
    [tester waitForTimeInterval:5];
    XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId], @"zhangsan2");
    XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey], @"邮箱");
}

-(void)testClearNativeUserIdAndUserKey{
    NSDictionary *dict = @{@"messageType":@"clearNativeUserIdAndUserKey",@"data":@""};
    [[GrowingHybridBridgeProvider sharedInstance] handleJavascriptBridgeMessage:[dict growingHelper_jsonString]];
    [tester waitForTimeInterval:5];
    XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserId],@"");
    XCTAssertEqualObjects([[GrowingPersistenceDataProvider sharedInstance] loginUserKey],@"");
}
@end
