//
//  EvarEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/12.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "ConversionVariablesEventsTest.h"

#import "GrowingTracker.h"
#import "LogOperHelper.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"

@implementation ConversionVariablesEventsTest

- (void)setUp {
    //设置userid,确保cs1字段不空
    [[GrowingTracker sharedInstance] setLoginUserId:@"test"];
}

- (void)test1SetEvarNormal {
    /**
     function:setEvar正常情况
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"var1" : @"good", @"var2" : @"excell"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    NSLog(@"CONVERSION_VARIABLES事件：%@", evarEventArray);
    if (evarEventArray.count >= 1) {
        NSDictionary *epvarchr = [evarEventArray objectAtIndex:evarEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"CONVERSION_VARIABLES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"var1"], @"good");
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"var2"], @"excell");

        NSDictionary *chres = [ManualTrackHelper conversionVariablesEventCheck:epvarchr];
        NSLog(@"Check Result:%@", chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，setEvar正常情况测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvar正常情况测试失败:%@", evarEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test2SetEvarNil {
    /**
     function:setEvar Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SendEvar"] tap];
    [[GrowingTracker sharedInstance] setConversionVariables:nil];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"CONVERSION_VARIABLES事件，setEvar，日志提醒测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvar，日志提醒测试失败!---Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test3SetEvarEmpty {
    /**
     function:setEvar 空字典
     2019-1-7,优化支持传空对象：{}
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setConversionVariables:@{}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    // NSLog(@"CONVERSION_VARIABLES事件：%@",evarEventArray);

    if (evarEventArray.count >= 1) {
        NSDictionary *epvarchr = [evarEventArray objectAtIndex:evarEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"CONVERSION_VARIABLES");
        NSDictionary *chres = [ManualTrackHelper conversionVariablesEventCheck:epvarchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，setEvar正常情况测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvar正常情况测试失败:%@", evarEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test4SetEvarKeyStr {
    /**
     function:setEvarWithKey:andStringValue设置变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"ekey1" : @"Good"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    // NSLog(@"CONVERSION_VARIABLES事件：%@",evarEventArray);
    if (evarEventArray.count >= 1) {
        NSDictionary *epvarchr = [evarEventArray objectAtIndex:evarEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"CONVERSION_VARIABLES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"ekey1"], @"Good");

        NSDictionary *chres = [ManualTrackHelper conversionVariablesEventCheck:epvarchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue设置变量测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue设置变量测试失败:%@", evarEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test2SetEvarKeyStrUpdate {
    /**
     function:setEvarWithKey:andStringValue更新变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"ekey1" : @"Better"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    // NSLog(@"CONVERSION_VARIABLES事件：%@",evarEventArray);
    if (evarEventArray.count >= 1) {
        NSDictionary *epvarchr = [evarEventArray objectAtIndex:evarEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"CONVERSION_VARIABLES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"ekey1"], @"Better");

        NSDictionary *chres = [ManualTrackHelper conversionVariablesEventCheck:epvarchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue更新变量测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue更新变量测试失败:%@", evarEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test6SetEvarKeyEmpty {
    /**
     function:setEvarWithKey:andStringValue关键字为空,检测日志
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SendESVar"] tap];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"" : @"Better"}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue关键字为空,日志检测测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue关键字为空,日志检测测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test7SetEvarKeyNil {
    /**
     function:setEvarWithKey:andStringValue关键字为nil,检测日志
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SendESVar"] tap];
    [[GrowingTracker sharedInstance] setConversionVariables:@{[NSNull null] : @"Better"}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue关键字为nil,日志检测测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue关键字为nil,日志检测测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test9SetEvarValStrEmpty {
    /**
     function:setEvarWithKey:andStringValue Str值为空,不发送数据,日志检测
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SendESVar"] tap];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"ekey1" : @""}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue Str值为空,日志检测测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue Str值为空,日志检测测试失败-----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test10SetEvarValNum {
    /**
     function:setEvarWithKey:andNumberValue设置变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"evkey1" : @"132"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    // NSLog(@"CONVERSION_VARIABLES事件：%@",evarEventArray);
    if (evarEventArray.count >= 1) {
        NSDictionary *epvarchr = [evarEventArray objectAtIndex:evarEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"CONVERSION_VARIABLES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        XCTAssertEqual([epvarchr[@"attributes"][@"evkey1"] intValue], 132);

        NSDictionary *chres = [ManualTrackHelper conversionVariablesEventCheck:epvarchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue设置变量测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue设置变量测试失败:%@", evarEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test11SetEvarValNumUpdate {
    /**
     function:setEvarWithKey:andNumberValue更新变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"evkey1" : @"43.22"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    // NSLog(@"CONVERSION_VARIABLES事件：%@",evarEventArray);
    if (evarEventArray.count >= 1) {
        NSDictionary *epvarchr = [evarEventArray objectAtIndex:evarEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"CONVERSION_VARIABLES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        NSString *fvalue = @"43.22";
        XCTAssertEqual([epvarchr[@"attributes"][@"evkey1"] floatValue], [fvalue floatValue]);

        NSDictionary *chres = [ManualTrackHelper conversionVariablesEventCheck:epvarchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue更新变量测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue更新变量测试失败:%@", evarEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test12SetEvarValNumKeyEmpty {
    /**
     function:setEvarWithKey:andNumberValue Key为空,日志检测
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //   [[viewTester usingLabel:@"SendENVar"] tap];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"" : @"43.22"}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue Key为空,日志检测测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue Key为空,日志检测测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test14SetEvarValNumValEmpty {
    /**
     function:setEvarWithKey:andNumberValue Value为空
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //   [[viewTester usingLabel:@"SendENVar"] tap];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"enkey2" : @""}];
    //检测日志输出
    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if (chres) {
        XCTAssertEqual(1, 1);
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue Value为空,日志检测测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andNumberValue Value为空,日志检测测试失败----Failed");
        XCTAssertEqual(1, 0);
    }
}

- (void)test16SetEvarKeyStrChinese {
    /**
     function:setEvarWithKey:andStringValue关键字和值为中文
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setConversionVariables:@{@"关键字" : @"北京"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"CONVERSION_VARIABLES"];
    // NSLog(@"CONVERSION_VARIABLES事件：%@",evarEventArray);
    if (evarEventArray.count >= 1) {
        NSDictionary *epvarchr = [evarEventArray objectAtIndex:evarEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"CONVERSION_VARIABLES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"关键字"], @"北京");

        NSDictionary *chres = [ManualTrackHelper conversionVariablesEventCheck:epvarchr];
        // NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue关键字和值为中文测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，setEvarWithKey:andStringValue关键字和值为中文测试失败:%@", evarEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test17SetEvarDicOutRange {
    /**
     function:setEvar数值字典超过100个关键字
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"CONVERSION_VARIABLES请求"] tap];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    [[viewTester usingLabel:@"EventAttributesOutRange"] tap];
    //检测日志输出
//    Boolean chres = [LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
//    if (chres) {
//        XCTAssertEqual(1, 1);
//        NSLog(@"CONVERSION_VARIABLES事件，setEvar数值字典超过100个关键字，日志检测测试通过-----passed");
//    } else {
//        NSLog(@"CONVERSION_VARIABLES事件，setEvar数值字典超过100个关键字，日志检测测试失败---Failed");
//        XCTAssertEqual(1, 0);
//    }
}

@end
