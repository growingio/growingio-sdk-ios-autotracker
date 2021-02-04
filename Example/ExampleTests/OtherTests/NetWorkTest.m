//
// NetWorkTest.m
// ExampleTests
//
//  Created by gio on 2021/1/28.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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


#import "NetWorkTest.h"
#import "MockEventQueue.h"
#import "GrowingEventRequest.h"
#import "GrowingNetworkManager.h"
#import "GrowingNetworkConfig.h"
#import "GrowingNetworkInterfaceManager.h"


@implementation NetWorkTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


- (void)test1NetworkConfig{
    NSLog(@"growingApiHostEnd:%@",[[GrowingNetworkConfig sharedInstance] growingApiHostEnd]);//https://api.growingio.com
    XCTAssertEqualObjects(@"https://api.growingio.com",([[GrowingNetworkConfig sharedInstance] growingApiHostEnd]));
    NSLog(@"growingDataHostEnd:%@",[[GrowingNetworkConfig sharedInstance] growingDataHostEnd]);//https://www.growingio.com
    XCTAssertEqualObjects(@"https://www.growingio.com",([[GrowingNetworkConfig sharedInstance] growingDataHostEnd]));
    NSLog(@"customtagsHostWsHost:%@",[[GrowingNetworkConfig sharedInstance] tagsHost]);//https://tags.growingio.com
    XCTAssertEqualObjects(@"https://tags.growingio.com",([[GrowingNetworkConfig sharedInstance] tagsHost]));
    NSLog(@"customWsHost:%@",[[GrowingNetworkConfig sharedInstance] wsEndPoint]);//wss://ws.growingio.com/app/%@/circle/%@
    XCTAssertEqualObjects(@"wss://ws.growingio.com/app/%@/circle/%@",([[GrowingNetworkConfig sharedInstance] wsEndPoint]));
    NSLog(@"customWsHost:%@",[[GrowingNetworkConfig sharedInstance] dataCheckEndPoint]);//wss://ws.growingio.com/feeds/apps/%@/exchanges/data-check/%@?clientType=sdk
    XCTAssertEqualObjects(@"wss://ws.growingio.com/feeds/apps/%@/exchanges/data-check/%@?clientType=sdk",([[GrowingNetworkConfig sharedInstance] dataCheckEndPoint]));
}

//目前https://api.growingio.com返回404 测试不通过
//使用https://mock.mengxuegu.com/mock/601ac857298655584171053e/sendRequest/grtinfo#!method=get测试
- (void)test2sSendRequest{
    //判断有无网络
    if (![GrowingNetworkInterfaceManager sharedInstance].isReachable) {
        NSLog(@"没有网络");
        XCTAssertEqual(1, 0);
    }
    NSArray<NSString *> *rawEvents = @[@"{\"idfa\":\"\",\"eventType\":\"VISIT\",\"language\":\"en\",\"deviceBrand\":\"Apple\",\"deviceId\":\"10460045-ECE0-40CF-A197-8202272AA0DE\",\"globalSequenceId\":22,\"urlScheme\":\"growing.530c8231345c492d\",\"deviceType\":\"iPhone\",\"appVersion\":\"1.0\",\"latitude\":30.109999999999999,\"screenHeight\":2436,\"sessionId\":\"CB16D3FB-91EF-45D6-BEFF-92453528C6CB\",\"networkState\":\"WIFI\",\"domain\":\"GrowingIO.GrowingIOTest-\",\"platform\":\"iOS\",\"appName\":\"Example\",\"timestamp\":1611814475720,\"appState\":\"FOREGROUND\",\"longitude\":32.219999999999999,\"deviceModel\":\"x86_64\",\"screenWidth\":1125,\"idfv\":\"10460045-ECE0-40CF-A197-8202272AA0DE\",\"sdkVersion\":\"3.0.0\",\"platformVersion\":\"13.7\",\"eventSequenceId\":3}"];
    GrowingEventRequest *eventRequest = nil;
    eventRequest = [[GrowingEventRequest alloc] initWithEvents:rawEvents];
    [[GrowingNetworkManager shareManager]sendRequest:eventRequest success:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data) {
        NSLog(@"sendRequest测试通过---Passed！");
        XCTAssertEqual(1, 1);
        } failure:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data, NSError * _Nonnull error) {
            NSLog(@"sendRequest测试不通过！");
            XCTAssertEqual(1, 0);
        }];
    [tester waitForTimeInterval:5];
}

- (void)test3NetworkInterfac{
    [[GrowingNetworkInterfaceManager sharedInstance] updateInterfaceInfo];

    //判断有无网络
    if (![GrowingNetworkInterfaceManager sharedInstance].isReachable) {
        NSLog(@"没有网络");
    }

    if ([GrowingNetworkInterfaceManager sharedInstance].WiFiValid) {
        // do nothing
    }
    NSLog(@"networkType: %@",[[GrowingNetworkInterfaceManager sharedInstance] networkType]);
}

@end
