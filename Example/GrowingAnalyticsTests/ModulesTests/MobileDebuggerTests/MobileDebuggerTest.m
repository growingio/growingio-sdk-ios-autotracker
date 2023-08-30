//
//  MobileDebuggerTest.m
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

#import <KIF/KIF.h>

#import "ManualTrackHelper.h"
#import "WebSocketTestHelper.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "Modules/MobileDebugger/GrowingMobileDebugger.h"

@interface GrowingMobileDebugger (XCTest)

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

@interface MobileDebuggerTest : KIFTestCase

@end

static __weak GrowingMobileDebugger *mobileDebugger;

@implementation MobileDebuggerTest

+ (void)setUp {
    NSArray *modules = [GrowingModuleManager sharedInstance].modules.copy;
    for (id module in modules) {
        if ([module isKindOfClass:[GrowingMobileDebugger class]]) {
            mobileDebugger = (GrowingMobileDebugger *)module;
            break;
        }
    }
}

- (void)setUp {
    [[viewTester usingLabel:@"协议/接口"] tap];
    
    // mock
    NSURL *url = [NSURL URLWithString:
                  @"growing.3612b67ce562c755://growingio/webservice?serviceType=debugger&wsUrl=wss://"
                  @"gta0.growingio.com/app/0wDaZmQ1/circle/ec7f5925458f458b8ae6f3901cacaa92"];
    [GrowingDeepLinkHandler handlerUrl:url];
    [mobileDebugger webSocketDidOpen:nil];

    [MockWebSocket.sharedInstance cleanMessages];
}

- (void)tearDown {
    [mobileDebugger stop];
    [[viewTester usingLabel:@"协议/接口"] tap];
}

- (void)test01SocketSend {
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(@"isRunning");
    if (mobileDebugger && [mobileDebugger respondsToSelector:selector]) {
        XCTAssertTrue([mobileDebugger performSelector:selector]);
    }
#pragma clang diagnostic pop

    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"MobileDebugger Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSString *message in MockWebSocket.sharedInstance.messages) {
            NSMutableDictionary *dic = [[message growingHelper_jsonObject] mutableCopy];
            [self mobileDebuggerSocketParamsCheck:dic];
        }
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)test02IncompatibleVersion {
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"incompatible_version\"}"];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)test03Quit {
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"quit\"}"];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)test04SocketReopen {
    NSURL *url = [NSURL URLWithString:
                  @"growing.3612b67ce562c755://growingio/webservice?serviceType=debugger&wsUrl=wss://"
                  @"gta0.growingio.com/app/0wDaZmQ1/circle/ec7f5925458f458b8ae6f3901cacaa92"];
    [GrowingDeepLinkHandler handlerUrl:url];
    [mobileDebugger webSocketDidOpen:nil];
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
}

- (void)test05StatusTap {
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
    [[viewTester usingLabel:@"正在进行Debugger"] tap];
    [[viewTester usingLabel:@"继续Debugger"] tap];
    [[viewTester usingLabel:@"正在进行Debugger"] tap];
    [[viewTester usingLabel:@"退出Debugger"] tap];
}

- (void)test06SocketDidCloseWithCode {
    [mobileDebugger webSocket:nil didCloseWithCode:GrowingWebSocketStatusCodeGoingAway reason:nil wasClean:YES];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)test07SocketDidFail {
    [mobileDebugger webSocket:nil didFailWithError:nil];
    [[viewTester usingLabel:@"知道了"] tap];
}

- (void)test08Logger {
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"ready\"}"];
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"logger_open\"}"];

    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [viewTester tapRowInTableViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"MobileDebugger Test failed : timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSString *message in MockWebSocket.sharedInstance.messages) {
            NSMutableDictionary *dic = [[message growingHelper_jsonObject] mutableCopy];
            [self mobileDebuggerSocketParamsCheck:dic];
        }
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:5.0f handler:nil];
    
    [mobileDebugger webSocket:nil didReceiveMessage:@"{\"msgType\":\"logger_close\"}"];
}

- (void)mobileDebuggerSocketParamsCheck:(NSDictionary *)dic {
    NSString *msgType = dic[@"msgType"];
    if ([msgType isEqualToString:@"refreshScreenshot"]) {
        XCTAssertNotNil(dic[@"screenWidth"]);
        XCTAssertNotNil(dic[@"screenHeight"]);
        XCTAssertNotNil(dic[@"snapshotKey"]);
        XCTAssertNotNil(dic[@"scale"]);
        XCTAssertNotNil(dic[@"screenshot"]);
    } else if ([msgType isEqualToString:@"debugger_data"]) {
        XCTAssertNotNil(dic[@"sdkVersion"]);

        NSDictionary *event = dic[@"data"];
        XCTAssertNotNil(event);
        NSString *eventType = event[@"eventType"];
        if ([eventType isEqualToString:@"VISIT"]) {
            XCTAssertTrue([ManualTrackHelper visitEventCheck:event]);
        } else if ([eventType isEqualToString:@"CUSTOM"]) {
            XCTAssertTrue([ManualTrackHelper customEventCheck:event]);
        } else if ([eventType isEqualToString:@"PAGE"]) {
            XCTAssertTrue([ManualTrackHelper pageEventCheck:event]);
        } else if ([eventType isEqualToString:@"VIEW_CLICK"]) {
            XCTAssertTrue([ManualTrackHelper viewClickEventCheck:event]);
        }
    } else if ([msgType isEqualToString:@"client_info"]) {
        XCTAssertNotNil(dic[@"sdkVersion"]);

        NSDictionary *info = dic[@"data"];
        XCTAssertNotNil(info);
        XCTAssertNotNil(info[@"os"]);
        XCTAssertNotNil(info[@"appVersion"]);
        XCTAssertNotNil(info[@"appChannel"]);
        XCTAssertNotNil(info[@"osVersion"]);
        XCTAssertNotNil(info[@"deviceType"]);
        XCTAssertNotNil(info[@"deviceBrand"]);
        XCTAssertNotNil(info[@"deviceModel"]);
    } else if ([msgType isEqualToString:@"logger_data"]) {
        XCTAssertNotNil(dic[@"sdkVersion"]);

        NSArray *logs = dic[@"data"];
        XCTAssertNotNil(logs);
        for (NSDictionary *log in logs) {
            XCTAssertNotNil(log[@"message"]);
            XCTAssertNotNil(log[@"subType"]);
            XCTAssertNotNil(log[@"type"]);
            XCTAssertNotNil(log[@"time"]);
        }
    }
}

@end
