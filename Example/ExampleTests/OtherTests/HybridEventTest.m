//
// 
//
//  Created by gio on 2021/1/21.
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



#import "HybridEventTest.h"
#import "MockEventQueue.h"
#import "GIOHybridEventTestController.h"



@implementation HybridEventTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test1Appclose {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [system deactivateAppForDuration:5];
    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"APP_CLOSED"];
    if (pvarEventArray.count >= 1) {
        NSDictionary *pvarchr = [pvarEventArray objectAtIndex:pvarEventArray.count - 1];
        XCTAssertEqualObjects(pvarchr[@"eventType"], @"APP_CLOSED");
        NSLog(@"APP_CLOSED事件， 测试通过-----passed");
    } else {
        NSLog(@"APP_CLOSED事件， 测试失败:%@", pvarEventArray);
        XCTAssertEqual(1, 0);
    }
    
}


- (void)test2sendMockCustomEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockCustomEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    
     if (EventArray.count > 0) {
         NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
         XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
         XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
         XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
         XCTAssertEqualObjects(chevent[@"eventName"],@"test_name");
         NSLog(@"内嵌Hybrid页面测试，发送CUSTOM事件测试通过---Passed！");
     } else {
         NSLog(@"内嵌Hybrid页面测试，发送CUSTOM事件测试不通过:%@！", EventArray);
         XCTAssertEqual(1, 0);
     }
}

- (void)test3CustomEventWithAttributes{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockCustomEventWithAttributes()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
        XCTAssertEqualObjects(chevent[@"eventName"],@"test_name");
        NSLog(@"内嵌Hybrid页面测试，发送CUSTOM事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送CUSTOM事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
    
}
/* TODO js后续添加
- (void)test4VisitorAttributesEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"Hybrid"] tap];
    [tester waitForTimeInterval:3];
 
    NSString * jsStr = [NSString stringWithFormat:@"sendMockVisitorAttributesEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];

    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"VISITOR_ATTRIBUTES"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
        XCTAssertEqualObjects(chevent[@"eventName"],@"test_name");
        NSLog(@"内嵌Hybrid页面测试，发送CUSTOM事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送CUSTOM事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
}
*/


- (void)test5LoginUserAttributesEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    
    NSString * jsStr = [NSString stringWithFormat:@"sendMockLoginUserAttributesEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"LOGIN_USER_ATTRIBUTES"];
    
     if (EventArray.count > 0) {
         NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
         XCTAssertEqualObjects(chevent[@"attributes"][@"key1"],@"value1");
         XCTAssertEqualObjects(chevent[@"attributes"][@"key2"],@"value2");
         NSLog(@"内嵌Hybrid页面测试，发送LOGIN_USER_ATTRIBUTES事件测试通过---Passed！");
     } else {
         NSLog(@"内嵌Hybrid页面测试，发送LOGIN_USER_ATTRIBUTES事件测试不通过:%@！", EventArray);
         XCTAssertEqual(1, 0);
     }
    
}


- (void)test6ConversionVariablesEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    
    NSString * jsStr = [NSString stringWithFormat:@"sendMockConversionVariablesEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:8];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertNotNil(chevent[@"attributes"]);
        
        NSLog(@"内嵌Hybrid页面测试，发送CONVERSION_VARIABLES事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送CUCONVERSION_VARIABLESSTOM事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
}
- (void)test7SendPageEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockPageEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"PAGE"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"title"],@"Hybrid测试页面");
        NSLog(@"内嵌Hybrid页面测试，发送PAGE事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送PAGE事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
}


- (void)test8PageEventWithQuery{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockPageEventWithQuery()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"PAGE"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"title"],@"Hybrid测试页面");
        XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
        NSLog(@"内嵌Hybrid页面测试，发送PAGE事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送PAGE事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
}


- (void)test10PageAttributesEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockPageAttributesEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"PAGE_ATTRIBUTES"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
        NSLog(@"内嵌Hybrid页面测试，发送PAGE_ATTRIBUTES事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送PAGE_ATTRIBUTES事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
}


- (void)test11ViewClickEvent{
    
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockViewClickEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
        XCTAssertEqualObjects(chevent[@"textValue"],@"登录");
        NSLog(@"内嵌Hybrid页面测试，发送VIEW_CLICK事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送VIEW_CLICK事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
    
}



- (void)test12ViewChangeEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockViewChangeEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CHANGE"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
        XCTAssertEqualObjects(chevent[@"textValue"],@"输入内容");
        NSLog(@"内嵌Hybrid页面测试，发送VIEW_CHANGE事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送VIEW_CHANGE事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test13FormSubmitEvent{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"sendMockFormSubmitEvent()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
    NSArray *EventArray = [MockEventQueue.sharedQueue eventsFor:@"FORM_SUBMIT"];
    
    if (EventArray.count > 0) {
        NSDictionary *chevent = [EventArray objectAtIndex:EventArray.count-1];
        XCTAssertEqualObjects(chevent[@"domain"],@"test-browser.growingio.com");
        XCTAssertEqualObjects(chevent[@"path"],@"/push/web.html");
        XCTAssertEqualObjects(chevent[@"query"],@"a=1&b=2");
        NSLog(@"内嵌Hybrid页面测试，发送FORM_SUBMIT事件测试通过---Passed！");
    } else {
        NSLog(@"内嵌Hybrid页面测试，发送FORM_SUBMIT事件测试不通过:%@！", EventArray);
        XCTAssertEqual(1, 0);
    }
}


- (void)test14setUserId{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"setUserId('test_name_jsStr')"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
}

- (void)test15clearUserId{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"clearUserId()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
}

- (void)test16mockDomChanged{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"HybridEventTest"] tap];
    [tester waitForTimeInterval:3];
    NSString * jsStr = [NSString stringWithFormat:@"mockDomChanged()"];
    [[HybirdEventSender sharedInstance] testHybirdEventSender:jsStr];
    [tester waitForTimeInterval:3];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
