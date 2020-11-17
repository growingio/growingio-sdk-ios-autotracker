//
//  CstmEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/6.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//
//  修改记录：
//    1，根据bugs处理结果，优化测试用例  2018-06-26
//

#import "CustomEventsTest.h"

#import "GrowingTracker.h"
#import "LogOperHelper.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"

@implementation CustomEventsTest

- (void)setUp {
    //设置userid,确保cs1字段不空
    [[GrowingTracker sharedInstance] setLoginUserId:@"test"];
    [tester waitForTimeInterval:1];
}
- (void)tearDown {
    [[viewTester usingLabel:@"协议/接口"] tap];
}
- (void)test1TrackNormal {
    /**
     function:EventId合法
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"GrowingIO2018"];
    [tester waitForTimeInterval:2];
    NSArray *cstmEventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    // NSLog(@"Cstm事件：%@",cstmEventArray);
    if (cstmEventArray.count >= 1) {
        NSDictionary *cstmchr = [cstmEventArray objectAtIndex:cstmEventArray.count - 1];
        // NSLog(@"Cstm事件：%@",cstmchr);
        XCTAssertEqualObjects(cstmchr[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(cstmchr[@"eventName"], @"GrowingIO2018");
        NSDictionary *chres = [ManualTrackHelper customEventCheck:cstmchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        //存在着与测量协议不一致的情况

//        NSArray *redu=chres[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][0],@"num");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][1],@"var");

        NSLog(@"cstm事件，EventId合法测试通过-----passed");
    } else {
        NSLog(@"cstm事件，EventId合法测试通过:%@", cstmEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test2SpecialChar {
    /**
     function:EventId为特殊字符，正常发送数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"GIO%#*/"];
    [tester waitForTimeInterval:2];
    NSArray *cstmEventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    // NSLog(@"Cstm事件：%@",cstmEventArray);
    if (cstmEventArray.count >= 1) {
        NSDictionary *cstmchr = [cstmEventArray objectAtIndex:cstmEventArray.count - 1];
        XCTAssertEqualObjects(cstmchr[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(cstmchr[@"eventName"], @"GIO%#*/");
        NSDictionary *chres = [ManualTrackHelper customEventCheck:cstmchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        //存在着与测量协议不一致的情况

//        NSArray *redu=chres[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][0],@"num");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][1],@"var");

        NSLog(@"cstm事件,EventId为特殊字符测试通过---passed!");
    } else {
        NSLog(@"cstm事件,EventId为特殊字符测试失败，cstm的n为：%@", cstmEventArray[0][@"eventName"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test3ChineseChar {
    /**
     function:EventId为中文，正常发送数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"企业增长"];
    [tester waitForTimeInterval:2];
    NSArray *cstmEventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    // NSLog(@"Cstm事件：%@",cstmEventArray);
    if (cstmEventArray.count >= 1) {
        NSDictionary *cstmchr = [cstmEventArray objectAtIndex:cstmEventArray.count - 1];
        XCTAssertEqualObjects(cstmchr[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(cstmchr[@"eventName"], @"企业增长");
        NSDictionary *chres = [ManualTrackHelper customEventCheck:cstmchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        //存在着与测量协议不一致的情况

//        NSArray *redu=chres[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][0],@"num");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][1],@"var");

        NSLog(@"cstm事件,EventId为中文测试通过---passed!");
    } else {
        NSLog(@"cstm事件,EventId为中文测试失败，cstm的n为：%@", cstmEventArray[0][@"eventName"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test4EventIdOutRange {
    /**
     function:EventId越界,不发送cstm事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"CUSTOM请求"] tap];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    [[viewTester usingLabel:@"EventNameOutRange"] tap];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,EventId越界,不发送数据测试通过---passed!");
    } else {
        NSLog(@"cstm事件,EventId越界,不发送数据测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test5EventIDNil {
    /**
     function:EventId为Nil,检测日志
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"Track请求"] tap];
    [[GrowingTracker sharedInstance] trackCustomEvent:NULL];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,EventId为Nil,检测日志测试通过---passed!");
    } else {
        NSLog(@"cstm事件,EventId为Nil,检测日志测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test6EventIDEmpty {
    /**
     function:EventId为空,检测日志
     **/
    [MockEventQueue.sharedQueue cleanQueue];

    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"Track请求"] tap];
    [[GrowingTracker sharedInstance] trackCustomEvent:@""];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,EventId为空,检测日志测试通过---passed!");
    } else {
        NSLog(@"cstm事件,EventId为空,检测日志测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test9WithNumKeyNil {
    /**
     function:WithNumber，EventId为Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"TrackNum"] tap];
    [[GrowingTracker sharedInstance] trackCustomEvent:NULL withAttributes:@{@"num" : @"企业增长"}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,WithNumber，EventId为Nil,检测日志测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithNumber，EventId为Nil,检测日志测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test10WithNumKeyEmpty {
    /**
     function:WithNumber，EventId为空
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"TrackNum"] tap];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"" withAttributes:@{@"num" : @"企业增长"}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,WithNumber，EventId为空,检测日志测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithNumber，EventId为空,检测日志测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test18WithVariable {
    /**
     function:WithVariable，正常情况
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"GIO" withAttributes:@{@"name" : @"GIO", @"title" : @"QA"}];

    [tester waitForTimeInterval:2];
    NSArray *cstmEventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    // NSLog(@"Cstm事件：%@",cstmEventArray);
    if (cstmEventArray.count >= 1) {
        NSDictionary *cstmchr = [cstmEventArray objectAtIndex:cstmEventArray.count - 1];
        //判断关键字段
        XCTAssertEqualObjects(cstmchr[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(cstmchr[@"eventName"], @"GIO");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:cstmchr:@"attributes"]);
        XCTAssertEqualObjects(cstmchr[@"attributes"][@"name"], @"GIO");
        XCTAssertEqualObjects(cstmchr[@"attributes"][@"title"], @"QA");
        //判断测量协议
        NSDictionary *chres = [ManualTrackHelper customEventCheck:cstmchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        //存在着与测量协议不一致的情况

//        NSArray *incr=chres[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(incr.count, 1);
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][0],@"num");

        NSLog(@"cstm事件,WithVariable，正常情况测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithVariable，正常情况测试失败，cstm的n为：%@", cstmEventArray[0][@"num"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test19WithVariableUpdate {
    /**
     function:WithVariable，更新数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"GIO" withAttributes:@{@"name" : @"GrowingIO", @"title" : @"RD"}];
    [tester waitForTimeInterval:2];
    NSArray *cstmEventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    // NSLog(@"Cstm事件：%@",cstmEventArray);
    if (cstmEventArray.count >= 1) {
        NSDictionary *cstmchr = [cstmEventArray objectAtIndex:cstmEventArray.count - 1];
        //判断关键字段
        XCTAssertEqualObjects(cstmchr[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(cstmchr[@"eventName"], @"GIO");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:cstmchr:@"attributes"]);
        XCTAssertEqualObjects(cstmchr[@"attributes"][@"name"], @"GrowingIO");
        XCTAssertEqualObjects(cstmchr[@"attributes"][@"title"], @"RD");
        //判断测量协议
        NSDictionary *chres = [ManualTrackHelper customEventCheck:cstmchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        //存在着与测量协议不一致的情况

//        NSArray *incr=chres[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(incr.count, 1);
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][0],@"num");

        NSLog(@"cstm事件,WithVariable，更新数据测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithVariable，更新数据测试失败，cstm的n为：%@", cstmEventArray[0][@"num"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test20WithVariableNil {
    /**
     function:WithVariable，var为Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"TrackWV"] tap];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"GIO" withAttributes:NULL];

    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,WithVariable，var为Nil测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithVariable，var为Nil测试失败---Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test22TrackChinese {
    /**
     function:EventId中文
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"北京"];
    [tester waitForTimeInterval:2];
    NSArray *cstmEventArray = [MockEventQueue.sharedQueue eventsFor:@"CUSTOM"];
    // NSLog(@"Cstm事件：%@",cstmEventArray);
    if (cstmEventArray.count >= 1) {
        NSDictionary *cstmchr = [cstmEventArray objectAtIndex:cstmEventArray.count - 1];
        //判断关键字段
        XCTAssertEqualObjects(cstmchr[@"eventType"], @"CUSTOM");
        XCTAssertEqualObjects(cstmchr[@"eventName"], @"北京");
        //判断测量协议
        NSDictionary *chres = [ManualTrackHelper customEventCheck:cstmchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        //存在着与测量协议不一致的情况

        NSArray *redu=chres[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][0],@"num");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"reduce"][1],@"var");

        NSLog(@"cstm事件,EventId中文测试通过---passed!");
    } else {
        NSLog(@"cstm事件,EventId中文测试失败，cstm的n为：%@", cstmEventArray[0][@"eventName"]);
        XCTAssertEqual(1, 0);
    }
}

- (void)test23WithVariableEventidNil {
    /**
     function:WithVariable，EventId为nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //   [[viewTester usingLabel:@"TrackWV"] tap];
    [[GrowingTracker sharedInstance] trackCustomEvent:NULL withAttributes:@{@"name" : @"GrowingIO"}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,WithVariable，EventId为nil测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithVariable，EventId为nil测试失败---Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test24WithVariableEventidEmpty {
    /**
     function:WithVariable，EventId为空
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"TrackWV"] tap];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"" withAttributes:@{@"name" : @"GrowingIO"}];

    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,WithVariable，EventId为空测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithVariable，EventId为空测试失败---Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test25TrackVarOutOfRange {
    /**
     function:WithVariable，值为超过100个键值对
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"CUSTOM请求"] tap];

    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    [tester tapViewWithAccessibilityLabel:@"EventAttributesOutRange"];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"cstm事件,WithVariable，值为超过100个键值对测试通过---passed!");
    } else {
        NSLog(@"cstm事件,WithVariable，值为超过100个键值对测试失败---Failed");
        XCTAssertEqual(1, 0);
    }
}
@end
