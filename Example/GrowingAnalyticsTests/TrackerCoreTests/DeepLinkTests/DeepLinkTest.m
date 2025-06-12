//
//  DeepLinkTest.m
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

#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler+Private.h"

@interface DeepLinkTest : XCTestCase <GrowingDeepLinkHandlerProtocol>

@end

@implementation DeepLinkTest

- (void)setUp {

}

- (void)tearDown {

}

- (void)testDeepLinkhandlerUrl {
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    [GrowingDeepLinkHandler handleURL:url];
    [[GrowingDeepLinkHandler sharedInstance] removeHandlersObject:self];
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandleURL:(NSURL *)url {
    XCTAssertEqualObjects(url.absoluteString, @"https://www.baidu.com");
    return YES;
}

@end
