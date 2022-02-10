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


#import <XCTest/XCTest.h>

#import "GrowingAutotrackConfiguration.h"
#import "GrowingConfigurationManager.h"
#import "GrowingDeviceInfo.h"
#import "GrowingMobileDebugger.h"

@interface GrowingMobileDebugger (XCTest)

- (void)start;

- (void)stop;

- (NSString *)absoluteURL;

- (void)runWithMobileDebugger:(NSURL *)url;

- (void)_setNeedUpdateScreen;

+ (CGFloat)impressScale;

- (unsigned long)getSnapshotKey;

- (void)sendScreenShot;

- (UIImage *)screenShot;

- (void)remoteReady;

- (void)_stopWithError:(NSString *)error;

- (BOOL)isRunning;

- (void)sendJson:(id)json;

- (void)nextOne;

- (void)startTimer;

- (void)stopTimer;

- (NSDictionary *)userInfo;

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url;

#pragma mark - GrowingApplicationEventManager

- (void)growingApplicationEventSendEvent:(UIEvent *)event;

#pragma mark - websocket delegate

- (void)webSocketDidOpen:(id <GrowingWebSocketService>)webSocket;

- (void)webSocket:(id <GrowingWebSocketService>)webSocket didReceiveMessage:(id)message;

- (void)webSocket:(id <GrowingWebSocketService>)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean;

- (void)webSocket:(id <GrowingWebSocketService>)webSocket didFailWithError:(NSError *)error;

@end

@interface MobileDebuggerTest : XCTestCase

@end

@implementation MobileDebuggerTest

- (void)setUp {
    GrowingAutotrackConfiguration *config = [GrowingAutotrackConfiguration configurationWithProjectId:@"test"];
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingMobileDebugger {
    NSURL *url = [NSURL URLWithString:
                             @"growing.3612b67ce562c755://growingio/webservice?serviceType=debugger&wsUrl=wss://"
                             @"gta0.growingio.com/app/0wDaZmQ1/circle/ec7f5925458f458b8ae6f3901cacaa92"];
    GrowingMobileDebugger *mobileDebugger = [[GrowingMobileDebugger alloc] init];
    [mobileDebugger start];
    [mobileDebugger stop];
    [mobileDebugger absoluteURL];
    [mobileDebugger nextOne];
    [mobileDebugger startTimer];
    [mobileDebugger stopTimer];
    [mobileDebugger webSocketDidOpen:nil];
    [mobileDebugger webSocket:nil didReceiveMessage:@"{@\"msgType\":@\"ready\"}"];
    [mobileDebugger webSocket:nil didFailWithError:nil];
    [mobileDebugger growingHandlerUrl:url];
    [mobileDebugger growingApplicationEventSendEvent:nil];
}

@end
