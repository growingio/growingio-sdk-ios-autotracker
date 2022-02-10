//
//  ApplicationEventManagerTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/18.
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

#import "GrowingApplicationEventManager.h"

@interface ApplicationEventManagerTest : XCTestCase <GrowingApplicationEventProtocol>

@property (nonatomic, strong) UIEvent *event;

@end

@implementation ApplicationEventManagerTest

- (void)setUp {
    self.event = [[UIEvent alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingStatusBarEventManager {
    GrowingApplicationEventManager *manager = GrowingApplicationEventManager.sharedInstance;
    XCTAssertNotNil(manager);

    // for safe sharedInstance
    GrowingApplicationEventManager *manager2 = [[GrowingApplicationEventManager alloc] init];
    XCTAssertEqualObjects(manager, manager2);
    XCTAssertEqualObjects(manager, manager.copy);
    XCTAssertEqualObjects(manager, manager.mutableCopy);

    XCTAssertNoThrow([manager addApplicationEventObserver:self]);
    XCTAssertNoThrow([manager dispatchApplicationEventSendAction:@selector(test)
                                                              to:self
                                                            from:manager
                                                        forEvent:self.event]);
    XCTAssertNoThrow([manager dispatchApplicationEventSendEvent:self.event]);
    XCTAssertNoThrow([manager removeApplicationEventObserver:self]);
}

#pragma mark - GrowingApplicationEventProtocol

- (void)growingApplicationEventSendAction:(SEL)action
                                       to:(nullable id)target
                                     from:(nullable id)sender
                                 forEvent:(nullable UIEvent *)event {
    XCTAssertEqual(action, @selector(test));
    XCTAssertEqualObjects(target, self);
    XCTAssertEqualObjects(sender, GrowingApplicationEventManager.sharedInstance);
    XCTAssertEqualObjects(event, self.event);
}

- (void)growingApplicationEventSendEvent:(UIEvent *)event {
    XCTAssertEqualObjects(event, self.event);
}

@end
