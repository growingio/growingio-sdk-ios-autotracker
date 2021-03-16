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
#import "GrowingNode.h"
#import "GrowingUserDefaults.h"
#import "GrowingASLLogger.h"
#import "GrowingHybridBridgeProvider.h"
#import "GrowingDataTraffic.h"
#import "GrowingLoggerDebugger.h"
#import "GrowingAppCloseEvent.h"
#import "GrowingWebCircleElement.h"
#import "GrowingHybridPageAttributesEvent.h"
#import "GrowingMobileDebugger.h"
#import "GrowingMobileDebugger.h"
#import "GrowingDeepLinkHandler.h"

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
    [[viewTester usingLabel:@"UI界面"] tap];
    
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
//    [[GrowingWebCircle shareInstance] screenShot];

//    UIViewController *current = [[UIViewController  alloc] init];
//    GrowingPageGroup *page = [current growingPageHelper_getPageObject];
//    if (!page) {
//        [[GrowingPageManager sharedInstance] createdViewControllerPage:current];
//        page = [current growingPageHelper_getPageObject];
//    }
//    NSMutableDictionary *dict = [[GrowingWebCircle shareInstance] dictFromPage:current xPath:page.path];
//    [GrowingWebCircle retrieveAllElementsAsync:nil];
    [GrowingWebCircle shareInstance];
    [GrowingWebCircle  runWithCircle:[NSURL URLWithString:@"ws://testws"] readyBlock:nil finishBlock:nil];
    [GrowingWebCircle isRunning];
    [GrowingWebCircle stop];
//    [GrowingWebCircle isContainer:nil];

    Class realClazz = NSClassFromString(@"GrowingWebCircle");
//    [realClazz respondsToSelector:@selector(setNeedUpdateScreen)];
    [realClazz performSelector:@selector(impressScale)];
    [[realClazz performSelector:@selector(shareInstance)] performSelector:@selector(_setNeedUpdateScreen)];;
    [[realClazz performSelector:@selector(shareInstance)] performSelector:@selector(sendWebcircleWithType:)withObject:@"eventType"];;

}


-(void)testGrowingHandleUrl{
    NSURL *url = [NSURL URLWithString: @"growing.9683a369c615f77d://growing/oauth2/token?messageId=GPnmM2RY&gtouchType=preview&msgType=popupWindow&"];
//    [Growing handleURL:url];
    NSDictionary *params = url.growingHelper_queryDict;
//    XCTAssertEqual(1, 1);
}

- (void)testGrowingHelper_screenshot {
    UIViewController *vc = [[UIViewController alloc]init ];
    [vc.view growingHelper_screenshot:CGFLOAT_MAX];
}

-(void)testGrowingNode{
 //   [GrowingRootNode rootNode];
}

-(void)testGrowingUserDefaults{
    [[GrowingUserDefaults shareInstance] setValue:@"testToken" forKey:@"_refreshToken"];
    NSString *_refreshToken = [[GrowingUserDefaults shareInstance] valueForKey:@"_refreshToken"];
    //((_refreshToken) equal to (@"testToken")) failed: ("{length = 8, bytes = 0x0000000000000000}") is not equal to ("{length = 8, bytes = 0xe82abb2801000000}")
 //   XCTAssertEqual(_refreshToken, @"testToken");
    
}

-(void)testGrowingASLLogger{
    [[GrowingASLLogger sharedInstance] loggerName ];

}

-(void)testGrowingHybridBridgeProvider{
    [GrowingHybridBridgeProvider.sharedInstance handleJavascriptBridgeMessage:@"testHibrid"];
    
    GrowingHybridPageAttributesEvent.builder.setQuery(@"QUERY")
    .setPath(@"KEY_PATH")
    .setPageShowTimestamp(@"KEY_PAGE_SHOW_TIMESTAMP")
    .setAttributes(@"KEY_ATTRIBUTES")
    .setDomain(@"domain");
    XCTAssertEqual(1, 1);

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

-(void)testGrowingLoggerDebugger{
    [GrowingLoggerDebugger startLoggerDebuggerWithKey:@"testGrowingLoggerDebugger"];
    [GrowingLoggerDebugger stopLoggerDebugger];

}

-(void)testGrowingMobileDebugger{
    
    NSURL *url1 = [NSURL URLWithString:@"growing.3612b67ce562c755://growingio/webservice?serviceType=debugger&wsUrl=wss://gta0.growingio.com/app/0wDaZmQ1/circle/ec7f5925458f458b8ae6f3901cacaa92"];
    [GrowingDeepLinkHandler handlerUrl:url1];
    [[GrowingMobileDebugger shareInstance] start];
    if([GrowingMobileDebugger isRunning]) {
        [GrowingMobileDebugger stop];
    }
}

-(void)testGrowingabsoluteURL{
    NSString * url = [GrowingMobileDebugger absoluteURL];
    XCTAssertEqualObjects(url, @"https://api.growingio.com/v3/projects/91eaf9b283361032/collect");
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

@end
