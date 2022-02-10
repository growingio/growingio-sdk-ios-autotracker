//
//  WebCircleTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/30.
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

#import "GrowingAutotracker.h"
#import "GrowingAutotrackConfiguration.h"
#import "GrowingConfigurationManager.h"
#import "GrowingDeviceInfo.h"
#import "GrowingDeepLinkHandler.h"
#import "GrowingWebCircle.h"
#import "GrowingPageGroup.h"
#import "GrowingPageManager.h"
#import "UIViewController+GrowingPageHelper.h"
#import "GrowingWebCircleElement.h"

@interface GrowingWebCircle (XCTest)

- (UIImage *)screenShot;

+ (CGFloat)impressScale;

- (NSMutableDictionary *)dictFromPage:(id<GrowingNode>)aNode xPath:(NSString *)xPath;

- (unsigned long)getSnapshotKey;

- (void)resetSnapshotKey;

- (NSMutableArray *)elements;

- (void)sendScreenShot;

- (void)remoteReady;

- (void)runWithCircle:(NSURL *)url readyBlock:(void (^)(void))readyBlock finishBlock:(void (^)(void))finishBlock;

- (void)start;

- (void)stop;

- (void)sendScreenShotWithCallback:(void (^)(NSString *))callback;


#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url;

#pragma mark - Websocket Delegate

- (void)webSocketDidOpen:(id <GrowingWebSocketService>)webSocket;

- (void)webSocket:(id <GrowingWebSocketService>)webSocket didReceiveMessage:(id)message;

@end

@interface WebCircleTest : XCTestCase

@end

@implementation WebCircleTest

+ (void)setUp {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingDeepLinkHandler {
    NSURL *url1 = [NSURL URLWithString: @"http://test.growingio.com/oauth2/"
                   @"qrcode.html?URLScheme=growing.test&productId=test&circleRoomNumber=test0f4cfa51ff3f&serviceType="
                   @"circle&appName=GrowingIO&wsUrl=ws://cdp.growingio.com/app/test/circle/test0f4cfa51ff3f"];

    [GrowingDeepLinkHandler handlerUrl:url1];
}

- (void)testWebCircle {
    GrowingWebCircle *circle = [[GrowingWebCircle alloc] init];
    CGFloat impressScale = [GrowingWebCircle impressScale];
    XCTAssertGreaterThanOrEqual(impressScale, 0);
        
    XCTAssertGreaterThan([circle getSnapshotKey], 0);
    [circle resetSnapshotKey];
    XCTAssertEqual([circle getSnapshotKey], 1);

    UIViewController *current = [[UIViewController alloc] init];
    // 避免自动发 PAGE 报错
    current.growingPageIgnorePolicy = GrowingIgnoreSelf;
    GrowingPageGroup *page = [current growingPageHelper_getPageObject];
    if (!page) {
        [[GrowingPageManager sharedInstance] createdViewControllerPage:current];
        page = [current growingPageHelper_getPageObject];
    }
    XCTAssertNotNil([circle dictFromPage:(id<GrowingNode>)current xPath:page.path]);
    XCTAssertNotNil([circle elements]);
    
    [circle screenShot];
    [circle sendScreenShot];
    [circle remoteReady];
    [circle runWithCircle:[NSURL URLWithString:@"ws://testws"] readyBlock:nil finishBlock:nil];
    [circle start];
    [circle stop];
    [circle sendScreenShotWithCallback:nil];
    NSURL *urltest = [[NSURL alloc] initWithString:@"http://testxxx.growingio.com/"
                                                   @"qrcode.html?URLScheme=growing.XXX&productId=XXX&circleRoomNumber="
                                                   @"8ebd86b3fac64b64ae09a9ce1450e015&serviceType=circle&appName=XXX"];
    [circle growingHandlerUrl:urltest];
    [circle webSocketDidOpen:nil];
    [circle webSocket:nil didReceiveMessage:@"{@\"msgType\":@\"ready\"}"];
    [circle webSocket:nil didReceiveMessage:@"{@\"msgType\":@\"incompatible_version\"}"];
}

- (void)testWebCircleElement {
    GrowingWebCircleElementBuilder *builder = GrowingWebCircleElement.builder;
    GrowingWebCircleElement *element = builder.setRect(CGRectMake(0, 0, 100, 100))
                                              .setZLevel(10)
                                              .setContent(@"test")
                                              .setXpath(@"Xpath")
                                              .setNodeType(@"Button")
                                              .setParentXPath(@"parentXPath")
                                              .setIsContainer(YES)
                                              .setIndex(10)
                                              .setPage(@"page")
                                              .build;
    NSDictionary *dic = [element toDictionary];
    CGFloat scale = MIN([UIScreen mainScreen].scale, 2);
    XCTAssertNotNil(dic);
    XCTAssertEqualObjects(dic[@"left"], @0);
    XCTAssertEqualObjects(dic[@"top"], @0);
    XCTAssertEqualObjects(dic[@"width"], @(100 * scale));
    XCTAssertEqualObjects(dic[@"height"], @(100 * scale));
    XCTAssertEqualObjects(dic[@"zLevel"], @10);
    XCTAssertEqualObjects(dic[@"content"], @"test");
    XCTAssertEqualObjects(dic[@"xpath"], @"Xpath");
    XCTAssertEqualObjects(dic[@"nodeType"], @"Button");
    XCTAssertEqualObjects(dic[@"isContainer"], @1);
    XCTAssertEqualObjects(dic[@"index"], @10);
    XCTAssertEqualObjects(dic[@"parentXPath"], @"parentXPath");
    XCTAssertEqualObjects(dic[@"page"], @"page");
    XCTAssertEqualObjects(dic[@"domain"], [GrowingDeviceInfo currentDeviceInfo].bundleID);
}

@end
