//
//  PPLEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/8.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  function:LOGIN_USER_ATTRIBUTES事件相关测试用例

#import "LoginUserAttributerEventsTest.h"

#import "GrowingTracker.h"
#import "LogOperHelper.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"
#import "GrowingAutotracker.h"
#import "GrowingAutotrackEventType.h"

@implementation LoginUserAttributerEventsTest

//-(void)tearDown{
//     [[viewTester usingLabel:@"协议/接口"] tap];
//}
- (void)test1PplNormal {
    /**
     function:setPeopleVariable正常情况
     **/
    [[GrowingAutotracker sharedInstance] setLoginUserId:@"test"];
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"name" : @"测试名字", @"title" : @"QA"}];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    NSLog(@"LOGIN_USER_ATTRIBUTES事件：%@", pplEventArray);
    if (pplEventArray.count >= 1) {
        NSDictionary *customchr = [pplEventArray objectAtIndex:pplEventArray.count - 1];
        XCTAssertEqualObjects(customchr[@"eventType"], GrowingEventTypeLoginUserAttributes);
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:customchr:@"attributes"]);
        XCTAssertEqualObjects(customchr[@"attributes"][@"name"], @"测试名字");
        XCTAssertEqualObjects(customchr[@"attributes"][@"title"], @"QA");
        NSDictionary *chres = [ManualTrackHelper PplEventCheck:customchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariable正常情况测试通过-----passed");
    } else {
        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariable正常情况测试失败:%@", pplEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test2PplNil {
    /**
     function:setPeopleVariable为nil,日志检测
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SetPV"] tap];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:nil];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
//    if (chres) {
//        XCTAssertEqual(1, 1);
//        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariable为nil,日志检测测试通过-----passed");
//    } else {
//        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariable为nil,日志检测测试失败---Failed");
//        XCTAssertEqual(1, 0);
//    }
}

- (void)test3PplEmpty {
    /**
     function:setPeopleVariable为空
     2019-1-7,优化支持传空对象：{}
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{}];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    NSLog(@"PPL事件：%@", pplEventArray);
    if (pplEventArray.count >= 1) {
        NSDictionary *customchr = [pplEventArray objectAtIndex:pplEventArray.count - 1];
        XCTAssertEqualObjects(customchr[@"eventType"], GrowingEventTypeLoginUserAttributes);
        NSDictionary *chres = [ManualTrackHelper PplEventCheck:customchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        TestSuccess(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariable为空测试通过-----passed");
    } else {
        TestFailed(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariable为空测试失败:%@", pplEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test4SpvAndStr {
    /**
     function:setPeopleVariableWithKey:andStringValue,发送正常数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"name" : @"GrowingIO"}];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    // NSLog(@"LOGIN_USER_ATTRIBUTES事件：%@",pplEventArray);
    if (pplEventArray.count >= 1) {
        NSDictionary *customchr = [pplEventArray objectAtIndex:pplEventArray.count - 1];
        XCTAssertEqualObjects(customchr[@"eventType"], GrowingEventTypeLoginUserAttributes);
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:customchr:@"attributes"]);
        XCTAssertEqualObjects(customchr[@"attributes"][@"name"], @"GrowingIO");
        NSDictionary *chres = [ManualTrackHelper PplEventCheck:customchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        TestSuccess(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andStringValue,发送正常数据测试通过-----passed");
    } else {
        TestFailed(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andStringValue,发送正常数据测试失败:%@",
              pplEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test5SpvAndStrUpdate {
    /**
     function:setPeopleVariableWithKey:andStringValue,更新数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"name" : @"GIO"}];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    // NSLog(@"LOGIN_USER_ATTRIBUTES事件：%@",pplEventArray);
    if (pplEventArray.count >= 1) {
        NSDictionary *customchr = [pplEventArray objectAtIndex:pplEventArray.count - 1];
        XCTAssertEqualObjects(customchr[@"eventType"], GrowingEventTypeLoginUserAttributes);
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:customchr:@"attributes"]);
        XCTAssertEqualObjects(customchr[@"attributes"][@"name"], @"GIO");
        NSDictionary *chres = [ManualTrackHelper PplEventCheck:customchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        TestSuccess(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andStringValue,更新数据测试通过-----passed");
    } else {
        TestFailed(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andStringValue,更新数据测试失败:%@", pplEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test6SpvAndStrKeyError {
    /**
     function:setPeopleVariableWithKey:andStringValue,Key为空
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"" : @"GIO"}];
    //  [[viewTester usingLabel:@"SetPVS"] tap];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
//    if (chres) {
//        XCTAssertEqual(1, 1);
//        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Key为空日志检测测试通过-----passed");
//    } else {
//        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Key为空日志检测测试失败---Failed");
//        XCTAssertEqual(1, 0);
//    }
}

- (void)test7SpvAndStrKeyNil {
    /**
     function:setPeopleVariableWithKey:andStringValue,Key为Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //   [[viewTester usingLabel:@"SetPVS"] tap];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{[NSNull null] : @"GIO"}];

    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
//    if (chres) {
//        XCTAssertEqual(1, 1);
//        NSLog(
//            @"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Key为nil日志检测测试通过-----passed");
//    } else {
//        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Key为nil日志检测测试失败---Failed");
//        XCTAssertEqual(1, 0);
//    }
}

- (void)test8SpvAndStrValueNil {
    /**
     function:setPeopleVariableWithKey:andStringValue,Value为Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //   [[viewTester usingLabel:@"SetPVS"] tap];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"name" : [NSNull null]}];

    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
//    if (chres) {
//        XCTAssertEqual(1, 1);
//        NSLog(
//            @"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Value为Nil日志检测测试通过-----"
//            @"passed");
//    } else {
//        NSLog(
//            @"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Value为Nil日志检测测试失败---Failed");
//        XCTAssertEqual(1, 0);
//    }
}

- (void)test9SpvAndStrValueEmpty {
    /**
     function:setPeopleVariableWithKey:andStringValue,Value为Empty
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //   [[viewTester usingLabel:@"SetPVS"] tap];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"name" : @""}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
//    if (chres) {
//        XCTAssertEqual(1, 1);
//        NSLog(
//            @"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Value为Empty日志检测测试通过-----"
//            @"passed");
//    } else {
//        NSLog(
//            @"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andStringValue,Value为Empty日志检测测试失败---"
//            @"Failed");
//        XCTAssertEqual(1, 0);
//    }
}
- (void)test10SpvAndNum {
    /**
     function:setPeopleVariableWithKey:andNumberValue正整数
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"score" : @"98"}];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    // NSLog(@"LOGIN_USER_ATTRIBUTES事件：%@",pplEventArray);
    if (pplEventArray.count >= 1) {
        NSDictionary *customchr = [pplEventArray objectAtIndex:pplEventArray.count - 1];
        NSLog(@"LOGIN_USER_ATTRIBUTES Result:%@", customchr);
        XCTAssertEqualObjects(customchr[@"eventType"], GrowingEventTypeLoginUserAttributes);
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:customchr:@"attributes"]);
        NSString *customnum = customchr[@"attributes"][@"score"];
        XCTAssertEqual([customnum intValue], 98);
        NSDictionary *chres = [ManualTrackHelper PplEventCheck:customchr];
        NSLog(@"Check Result:%@", chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        TestSuccess(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andNumberValue正整数测试通过-----passed");
    } else {
        TestFailed(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andNumberValue正整数测试失败:%@", pplEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test11SpvAndNumUpdate {
    /**
     function:setPeopleVariableWithKey:andNumberValue更新为浮点数
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"score" : @"23.62"}];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeLoginUserAttributes];
    // NSLog(@"LOGIN_USER_ATTRIBUTES事件：%@",pplEventArray);
    if (pplEventArray.count >= 1) {
        NSDictionary *customchr = [pplEventArray objectAtIndex:pplEventArray.count - 1];
        XCTAssertEqualObjects(customchr[@"eventType"], GrowingEventTypeLoginUserAttributes);
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:customchr:@"attributes"]);
        NSString *customnum = customchr[@"attributes"][@"score"];
        NSString *floatchr = @"23.62";
        XCTAssertEqual([customnum floatValue], [floatchr floatValue]);
        NSDictionary *chres = [ManualTrackHelper PplEventCheck:customchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        TestSuccess(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andNumberValue更新为浮点数测试通过-----passed");
    } else {
        TestFailed(@"LOGIN_USER_ATTRIBUTES事件,setPeopleVariableWithKey:andNumberValue更新为浮点数测试失败:%@",
              pplEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test13SpvAndNumKeyError {
    /**
     function:setPeopleVariableWithKey:andNumberValue Key为空不发送事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SetPVN"] tap];
    [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"" : @"42"}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
//    if (chres) {
//        XCTAssertEqual(1, 1);
//        NSLog(
//            @"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andNumberValue，Key为空日志检测测试通过-----passed");
//    } else {
//        NSLog(@"LOGIN_USER_ATTRIBUTES事件，setPeopleVariableWithKey:andNumberValue，Key为空日志检测测试失败---Failed");
//        XCTAssertEqual(1, 0);
//    }
}
@end
