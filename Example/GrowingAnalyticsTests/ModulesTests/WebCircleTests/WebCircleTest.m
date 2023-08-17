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

#import <KIF/KIF.h>

#import "GrowingModuleManager.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "Modules/WebCircle/GrowingWebCircle.h"
#import "Services/WebSocket/GrowingSRWebSocket.h"

@interface MockWebSocket : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *messages;

+ (instancetype)sharedInstance;

@end

@implementation MockWebSocket

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.messages = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)cleanMessages {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.messages removeAllObjects];
    }];
}

- (NSString *)lastMessage {
    __block NSString *message = nil;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            message = self.messages.lastObject.copy;
        }
                  waitUntilDone:YES];
    return message;
}

- (void)addMessage:(NSString *)message {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.messages addObject:message];
    }];
}

@end

@interface GrowingModuleManager (XCTest)

@property (nonatomic, strong) NSMutableArray *modules;

@end

@interface GrowingWebCircle (XCTest)

- (void)stop;

#pragma mark - Websocket Delegate

- (void)webSocketDidOpen:(id<GrowingWebSocketService>)webSocket;

- (void)webSocket:(id<GrowingWebSocketService>)webSocket didReceiveMessage:(id)message;

- (void)webSocket:(id<GrowingWebSocketService>)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean;

- (void)webSocket:(id<GrowingWebSocketService>)webSocket didFailWithError:(NSError *)error;

@end

@implementation GrowingSRWebSocket (XCTest)

- (void)send:(id)data {
    [MockWebSocket.sharedInstance addMessage:data];
}

- (void)setDelegate:(id)delegate {
    // 在单测中，使用测试逻辑进行socket
}

- (NSInteger)readyState {
    return Growing_WS_OPEN;
}

@end

@interface WebCircleTest : KIFTestCase

@end

static __weak GrowingWebCircle *webCircle;

@implementation WebCircleTest

+ (void)setUp {
    NSArray *modules = [GrowingModuleManager sharedInstance].modules.copy;
    for (id module in modules) {
        if ([module isKindOfClass:[GrowingWebCircle class]]) {
            webCircle = (GrowingWebCircle *)module;
            break;
        }
    }
}

- (void)setUp {
    [[viewTester usingLabel:@"协议/接口"] tap];

    // mock
    NSURL *url = [NSURL URLWithString:
                            @"growing.bf30ad277eaae1aa://growingio/webservice?serviceType=circle&wsUrl"
                            @"=wss://portal.growingio.com/app/r85jV5gv/circle/faeb773a1d004663a86c227a159cc687"];
    [GrowingDeepLinkHandler handlerUrl:url];
    [webCircle webSocketDidOpen:nil];

    [MockWebSocket.sharedInstance cleanMessages];
}

- (void)tearDown {
    [webCircle stop];
    [[viewTester usingLabel:@"协议/接口"] tap];
}

- (void)test01SocketSend {
    [webCircle webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];

    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"WebCircle Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *message = MockWebSocket.sharedInstance.lastMessage;
        NSMutableDictionary *dic = [[message growingHelper_jsonObject] mutableCopy];
        [self webCircleSocketParamsCheck:dic];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)test02IncompatibleVersion {
    [webCircle webSocket:nil didReceiveMessage:@"{\"msgType\":\"incompatible_version\"}"];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)test03Quit {
    [webCircle webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [webCircle webSocket:nil didReceiveMessage:@"{\"msgType\":\"quit\"}"];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)test04SocketReopen {
    NSURL *url = [NSURL URLWithString:
                            @"growing.bf30ad277eaae1aa://growingio/webservice?serviceType=circle&wsUrl=wss://"
                            @"portal.growingio.com/app/r85jV5gv/circle/faeb773a1d004663a86c227a159cc687"];
    [GrowingDeepLinkHandler handlerUrl:url];
    [webCircle webSocketDidOpen:nil];
    [webCircle webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
}

- (void)test05SocketOpenTimeOut {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(11.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[viewTester usingLabel:@"知道了"] tap];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:15.0f handler:nil];
}

- (void)test06StatusTap {
    [webCircle webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
    [[viewTester usingLabel:@"正在进行GrowingIO移动端圈选"] tap];
    [[viewTester usingLabel:@"继续圈选"] tap];
    [[viewTester usingLabel:@"正在进行GrowingIO移动端圈选"] tap];
    [[viewTester usingLabel:@"退出圈选"] tap];
}

- (void)test07Hybrid {
    // 由于hybrid中getDomTree是个同步方法，KIF
    // tap方法内部也有一个同步的runLoop逻辑，这2者同时进行会卡死，所以在这里先tap，
    // 再执行webSocket:didReceiveMessage:以触发getDomTree
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"Hybrid"] tap];
    [viewTester waitForTimeInterval:5];

    [webCircle webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
    // 尝试通过tapPoint点击到html中的button
    [viewTester tapScreenAtPoint:CGPointMake(100, 200)];

    XCTestExpectation *expectation = [self expectationWithDescription:@"WebCircle Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *message = MockWebSocket.sharedInstance.lastMessage;
        NSMutableDictionary *dic = [[message growingHelper_jsonObject] mutableCopy];
        [self webCircleSocketParamsCheck:dic];

        // webView圈选数据
        NSArray *elements = dic[@"elements"];
        XCTAssertNotNil(elements);
        for (NSDictionary *element in elements) {
            if ([element[@"nodeType"] isEqualToString:@"WEB_VIEW"]) {
                XCTAssertNotNil(element[@"webView"]);
            }
        }

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:5.0f handler:nil];

    [[viewTester usingLabel:@"UI界面"] tap];
}

- (void)test08SocketDidCloseWithCode {
    [webCircle webSocket:nil didCloseWithCode:GrowingWebSocketStatusCodeGoingAway reason:nil wasClean:YES];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)test09SocketDidFail {
    [webCircle webSocket:nil didFailWithError:nil];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)webCircleSocketParamsCheck:(NSDictionary *)dic {
    XCTAssertEqualObjects(dic[@"msgType"], @"refreshScreenshot");
    XCTAssertNotNil(dic[@"screenWidth"]);
    XCTAssertNotNil(dic[@"screenHeight"]);
    XCTAssertNotNil(dic[@"snapshotKey"]);
    XCTAssertNotNil(dic[@"scale"]);
    XCTAssertNotNil(dic[@"screenshot"]);

    NSArray *elements = dic[@"elements"];
    XCTAssertNotNil(elements);
    for (NSDictionary *element in elements) {
        XCTAssertNotNil(element[@"left"]);
        XCTAssertNotNil(element[@"top"]);
        XCTAssertNotNil(element[@"width"]);
        XCTAssertNotNil(element[@"height"]);
        XCTAssertNotNil(element[@"nodeType"]);
        XCTAssertNotNil(element[@"domain"]);
        XCTAssertNotNil(element[@"zLevel"]);
        XCTAssertNotNil(element[@"xpath"]);
        XCTAssertNotNil(element[@"xcontent"]);
        XCTAssertNotNil(element[@"page"]);
        XCTAssertNotNil(element[@"isContainer"]);
    }

    NSArray *pages = dic[@"pages"];
    XCTAssertNotNil(pages);
    for (NSDictionary *page in pages) {
        XCTAssertNotNil(page[@"path"]);
        XCTAssertNotNil(page[@"top"]);
        XCTAssertNotNil(page[@"width"]);
        XCTAssertNotNil(page[@"left"]);
        XCTAssertNotNil(page[@"height"]);
    }
}

@end
