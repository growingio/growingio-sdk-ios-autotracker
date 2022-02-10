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

#import "GrowingDeepLinkHandler.h"
#import "GrowingSceneDelegateAutotracker.h"

@interface SceneDelegate_XCTest : UIResponder

@end

@implementation SceneDelegate_XCTest

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity API_AVAILABLE(ios(13.0)) {
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts API_AVAILABLE(ios(13.0)) {
    
}

@end

@interface DeepLinkTest : XCTestCase <GrowingDeepLinkHandlerProtocol>

@property (nonatomic, copy) NSString *urlString;

@end

@implementation DeepLinkTest

- (void)setUp {
    self.urlString = @"growing.9683a369c615f77d://growing/oauth2/token"
                     @"?messageId=GPnmM2RY&gtouchType=preview&msgType=popupWindow&";
}

- (void)tearDown {

}

- (void)testGrowingSceneDelegateAutotracker {
    XCTAssertNoThrow([GrowingSceneDelegateAutotracker track:SceneDelegate_XCTest.class]);
}

- (void)testDeepLinkhandlerUrl {
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
    NSURL *url = [NSURL URLWithString:self.urlString];
    [GrowingDeepLinkHandler handlerUrl:url];
    [[GrowingDeepLinkHandler sharedInstance] removeHandlersObject:self];
}

- (void)testGrowingWebWatcher {
    NSURL *url = [NSURL URLWithString:@"growing.9683a369c615f77d://growing/oauth2/token?openConsoleLog=Yes"];
    [GrowingDeepLinkHandler handlerUrl:url];
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
    XCTAssertEqualObjects(url.absoluteString, self.urlString);
}

@end
