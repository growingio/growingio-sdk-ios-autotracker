//
//  CS1ManualTrackTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "CS1ManualTrackTest.h"

#import "GrowingTracker.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"
#import "GrowingSession.h"

@implementation CS1ManualTrackTest

- (void)beforeEach {
    [[viewTester usingLabel:@"协议/接口"] tap];
}

- (void)tearDown {
    [[viewTester usingLabel:@"协议/接口"] tap];
}

- (void)test1SetUserID {
    //正常测试SetUserID，检查cs1
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [tester waitForTimeInterval:1];
    // Find MeasurementProtocolTableViewController tableView with accessibilityIdentifier and scroll it.
    [tester scrollViewWithAccessibilityIdentifier:@"MeasurementProtocolTableView"
                       byFractionOfSizeHorizontal:0.0f
                                         vertical:-0.3f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"+ (void)setUserId:(NSString *)userId;"] tap];
    [[viewTester usingLabel:@"SetUserId"] tap];
    [tester tapViewWithAccessibilityLabel:@"userIdTextField"];

    NSString *newestUserId = @"newest_user_id";
    [tester enterTextIntoCurrentFirstResponder:newestUserId];
    [[viewTester usingLabel:@"CustomSet"] tap];
    [tester waitForTimeInterval:2];
    NSArray<NSDictionary *> *visitEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];

    if (visitEventArray.count >= 1) {
        NSDictionary *visit_chr = visitEventArray.lastObject;
        // NSLog(@"Check Result:%@",vstchr);
        XCTAssertEqualObjects(visit_chr[@"userId"], newestUserId);
        NSLog(@"正常测试SetUserID，检查cs1测试通过-----passed");
    } else {
        NSLog(@"正常测试SetUserID，测试失败!Problems:%@", visitEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test2ChangeUserID {
    /**
     function:更新UID，检测cs1
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [tester scrollViewWithAccessibilityIdentifier:@"MeasurementProtocolTableView"
                       byFractionOfSizeHorizontal:0.0f
                                         vertical:-0.3f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"+ (void)setUserId:(NSString *)userId;"] tap];
    //设置初值
    [tester tapViewWithAccessibilityLabel:@"userIdTextField"];
    [tester enterTextIntoCurrentFirstResponder:@"SXF001"];
    [[viewTester usingLabel:@"CustomSet"] tap];
    [tester waitForTimeInterval:1];
    // 先获取第一次setUserID的信息，供后面比较
    NSArray *customEventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    if (customEventArray.count >= 1) {
        NSDictionary *cstmchr = customEventArray.lastObject;
        XCTAssertNotNil(cstmchr[@"sessionId"]);
    }

    //更新UID
    [tester tapViewWithAccessibilityLabel:@"userIdTextField"];
    [tester clearTextFromAndThenEnterTextIntoCurrentFirstResponder:@"SxfChange"];
    [[viewTester usingLabel:@"CustomSet"] tap];
    [tester waitForTimeInterval:2];

    NSArray *visitEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];

    if (visitEventArray.count >= 1) {
        NSDictionary *visit_chr = visitEventArray.lastObject;
        XCTAssertEqualObjects(visit_chr[@"userId"], @"SxfChange");
        XCTAssertNotNil(visit_chr[@"sessionId"]);
        // 校验sessions 变化
        XCTAssertNotEqual(customEventArray.lastObject[@"sessionId"], visit_chr[@"sessionId"]);
        NSLog(@"更新UID，检测cs1测试通过-----passed");
    } else {
        NSLog(@"更新UID，检测cs1测试失败!Problems:%@", visitEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test3SpecailCharCheck {
    /**
     function:UID为特殊字符
     ***/
    [MockEventQueue.sharedQueue cleanQueue];
    [tester scrollViewWithAccessibilityIdentifier:@"MeasurementProtocolTableView"
                       byFractionOfSizeHorizontal:0.0f
                                         vertical:-0.3f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"+ (void)setUserId:(NSString *)userId;"] tap];
    //设置初值
    [tester tapViewWithAccessibilityLabel:@"userIdTextField"];
    [tester clearTextFromAndThenEnterTextIntoCurrentFirstResponder:@"%$#./"];
    [[viewTester usingLabel:@"CustomSet"] tap];
    [tester waitForTimeInterval:2];
    NSArray *visitEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];

    if (visitEventArray.count >= 1) {
        NSDictionary *vstchr = visitEventArray.lastObject;

        XCTAssertEqualObjects(vstchr[@"userId"], @"%$#./");
        NSLog(@"UID为特殊字符，检测cs1测试通过-----passed");
    } else {
        NSLog(@"UID为特殊字符，检测cs1测试失败!Problems:%@", visitEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test4ChineseCharCheck {
    /**
     function:UID为中文字符
     ***/
    [MockEventQueue.sharedQueue cleanQueue];
    [tester scrollViewWithAccessibilityIdentifier:@"MeasurementProtocolTableView"
                       byFractionOfSizeHorizontal:0.0f
                                         vertical:-0.3f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"+ (void)setUserId:(NSString *)userId;"] tap];
    //设置初值
    [tester tapViewWithAccessibilityLabel:@"userIdTextField"];
    [tester clearTextFromAndThenEnterTextIntoCurrentFirstResponder:@"数据分析"];
    [[viewTester usingLabel:@"CustomSet"] tap];
    [tester waitForTimeInterval:2];
    NSArray *visitEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];

    if (visitEventArray.count >= 1) {
        NSDictionary *vstchr = visitEventArray.lastObject;
        XCTAssertEqualObjects(vstchr[@"userId"], @"数据分析");
        NSLog(@"UID为中文字符，检测cs1测试通过-----passed");
    } else {
        NSLog(@"UID为中文字符，检测cs1测试失败!Problems:%@", visitEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test5EmptyCheck {
    /**
     function:UID为空
     ***/
    [MockEventQueue.sharedQueue cleanQueue];
    [tester scrollViewWithAccessibilityIdentifier:@"MeasurementProtocolTableView"
                       byFractionOfSizeHorizontal:0.0f
                                         vertical:-0.3f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"+ (void)setUserId:(NSString *)userId;"] tap];
    //设置初值
    [tester tapViewWithAccessibilityLabel:@"userIdTextField"];
    [tester clearTextFromAndThenEnterTextIntoCurrentFirstResponder:@""];
    [[viewTester usingLabel:@"CustomSet"] tap];
    [tester waitForTimeInterval:2];
    NSArray *visitEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];

    if (visitEventArray.count == 0) {
        XCTAssertEqual(1, 1);
        NSLog(@"UID为空,检测CS1测试通过---passed!");
    } else {
        NSLog(@"UID为空,检测CS1测试失败，VST中的CS1为：%@", visitEventArray.firstObject[@"userId"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test6NilCheck {
    /**
     function:UID为nil
     ***/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setLoginUserId:NULL];
    [tester waitForTimeInterval:2];
    NSArray *visitEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];

    if (visitEventArray.count == 0) {
        XCTAssertEqual(1, 1);
        NSLog(@"UID为nil,检测CS1测试通过---passed!");
    } else {
        NSLog(@"UID为nil,检测CS1测试失败，VST中的CS1为：%@", visitEventArray.firstObject[@"userId"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test7OutRangeCheck {
    /**
     function:UID为超过1000个字符

     ***/
    [MockEventQueue.sharedQueue cleanQueue];
    [tester scrollViewWithAccessibilityIdentifier:@"MeasurementProtocolTableView"
                       byFractionOfSizeHorizontal:0.0f
                                         vertical:-0.3f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"+ (void)setUserId:(NSString *)userId;"] tap];
    [[viewTester usingLabel:@"SetUserIdOutRange"] tap];
    [tester waitForTimeInterval:2];
    NSArray *visitEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];

    if (visitEventArray.count == 0) {
        XCTAssertEqual(1, 1);
        NSLog(@"UID为超过1000个字符,检测CS1测试通过---passed!");
    } else {
        NSLog(@"UID为超过1000个字符,检测CS1测试失败，VST中的CS1为：%@", visitEventArray.firstObject[@"userId"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test8ClearUIDCheck {
    /**
     function:清除UID,page事件中无cs1字段
     记录：重构后的打点事件，没有page事件   2018-07-24
     ***/
    [MockEventQueue.sharedQueue cleanQueue];
    [tester scrollViewWithAccessibilityLabel:@"LOGIN_USER_ATTRIBUTES请求" byFractionOfSizeHorizontal:0.0f vertical:-10.0f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"+ (void)clearUserId;"] tap];
    [[viewTester usingLabel:@"SetUserId"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:2];
    NSArray *page1Array = [MockEventQueue.sharedQueue eventsFor:@"PAGE"];
    // NSLog(@"page1事件：%@",page1Array);
    if (page1Array.count > 0) {
        // pageg事件包含cs1字段
        NSDictionary *page1chr = [page1Array objectAtIndex:page1Array.count - 1];
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:page1chr:@"userId"]);
    }

    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"CleanUserId"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:2];
    NSArray *page2Array = [MockEventQueue.sharedQueue eventsFor:@"PAGE"];
    // NSLog(@"VST事件：%@",page2Array);
    if (page2Array.count > 0) {
        // pageg事件包含cs1字段
        NSDictionary *page2chr = [page2Array objectAtIndex:page2Array.count - 1];
        XCTAssertFalse([ManualTrackHelper CheckContainsKey:page2chr:@"userId"]);
        NSLog(@"清除UID,page事件中无cs1字段测试通过---passed!");
    } else {
        NSLog(@"清除UID,page事件中无cs1字段测试失败，page事件为：%@!", page2Array);
        XCTAssertEqual(1, 0);
    }
}

- (void)test9CheckSessionChangeByChangeUserID {
    // userID 从A到空，再到B  sessionid 变
    [MockEventQueue.sharedQueue cleanQueue];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%lld", (long long)[datenow timeIntervalSince1970] * 1000LL];
    // 时间戳setUserId 方便触发事件获取session
    [[GrowingTracker sharedInstance] setLoginUserId:timeSp];
    [tester waitForTimeInterval:2];
    NSString *oldSession = [[GrowingSession currentSession] sessionId];
    XCTAssertNotNil(oldSession);
    [[GrowingTracker sharedInstance] cleanLoginUserId];

    [[GrowingTracker sharedInstance] setLoginUserId:@"lisi"];
    NSString *newSession = [[GrowingSession currentSession] sessionId];
    XCTAssertNotNil(newSession);
    XCTAssertNotEqual(oldSession, newSession);
    NSLog(@"old:%@,new:%@", oldSession, newSession);
}
- (void)test10CheckSessionChangeByChangeUserIDAndBG {
    // userID 从A到空，切换后台后，再到B  sessionid 变
    [MockEventQueue.sharedQueue cleanQueue];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%lld", (long long)[datenow timeIntervalSince1970] * 1000LL];
    // 时间戳setUserId 方便触发事件获取session
    [[GrowingTracker sharedInstance] setLoginUserId:timeSp];
    NSString *oldSession = [[GrowingSession currentSession] sessionId];
    XCTAssertNotNil(oldSession);

    [[GrowingTracker sharedInstance] cleanLoginUserId];
    [self enterBackground];
    [self enterForeground];
    [[GrowingTracker sharedInstance] setLoginUserId:@"lisi"];
    NSString *newSession = [[GrowingSession currentSession] sessionId];
    XCTAssertNotNil(newSession);
    XCTAssertNotEqual(oldSession, newSession);
    NSLog(@"old:%@,new:%@", oldSession, newSession);
}

- (void)enterBackground {
    UIApplication *app = [UIApplication sharedApplication];
    [app.delegate applicationWillResignActive:app];
    [app.delegate applicationDidEnterBackground:app];
}

- (void)enterForeground {
    UIApplication *app = [UIApplication sharedApplication];
    [app.delegate applicationWillEnterForeground:app];
    [app.delegate applicationDidBecomeActive:app];
}

@end
