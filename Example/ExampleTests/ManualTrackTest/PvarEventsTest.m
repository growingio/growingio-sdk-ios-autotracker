//
//  PvarEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/11.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  function:Pvar事件测试用例集

#import "PvarEventsTest.h"

#import <GrowingAutoTracker.h>

#import "LogOperHelper.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"

@implementation PvarEventsTest

- (void)setUp {
}

- (void)test1PvarNormal {
    /**
     function:setPageVariable正常情况
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"pvar请求"] tap];
    //    [tester tapViewWithAccessibilityLabel:@"PVarVal"];
    //    [tester enterTextIntoCurrentFirstResponder:@"{\"page1\":\"test\",\"ptvar\":\"flag1\"}"];
    //    [[viewTester usingLabel:@"SetPgVar"] tap];
    //    [Growing setPageAttributes:@{@"page1":@"test",@"ptvar":@"flag1"}];
    [tester waitForTimeInterval:2];
    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
    // NSLog(@"PVar事件：%@",pvarEventArray);
    if (pvarEventArray.count >= 1) {
        NSDictionary *pvarchr = [pvarEventArray objectAtIndex:pvarEventArray.count - 1];
        XCTAssertEqualObjects(pvarchr[@"eventType"], @"pvar");
        //        XCTAssertTrue([ManualTrackHelper CheckContainsKey:pvarchr :@"attributes"]);
        //        XCTAssertEqualObjects(pvarchr[@"attributes"][@"page1"], @"test");
        //        XCTAssertEqualObjects(pvarchr[@"attributes"][@"ptvar"], @"flag1");
        //        NSDictionary *chres=[ManualTrackHelper PvarEventCheck:pvarchr];
        //        //NSLog(@"Check Result:%@",chres);
        //        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        //        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"pvar事件， 测试通过-----passed");
    } else {
        NSLog(@"pvar事件， 测试失败:%@", pvarEventArray);
        XCTAssertEqual(1, 0);
    }
}

//-(void)test2PvarNil{
//    /**
//     function:setPageVariable,pvar为nil,为清除pvar事件
//     2019-1-7 优化测试用例
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarVal"];
////    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
////    [[viewTester usingLabel:@"SetPgVar"] tap];
////    [Growing setPageAttributes:NULL];
//    [tester waitForTimeInterval:2];
//    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
//
////    //将Log日志写入文件
////    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVar"] tap];
////    //检测日志输出
////    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
////    //恢复日志重定向
////    [LogOperHelper redirectLogBack];
//    if(pvarEventArray.count==0)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariable,pvar为nil,日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariable,pvar为nil,日志检测测试失败-----Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test3PvarEmpty{
//    /**
//     function:setPageVariable,pvar为空
//     2019-1-7,优化支持传空对象：{},为清除pvar事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarVal"];
////    [tester enterTextIntoCurrentFirstResponder:@"{}"];
////
////    [[viewTester usingLabel:@"SetPgVar"] tap];
////    [Growing setPageAttributes:@{}];
//
//    [tester waitForTimeInterval:2];
//    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
//    //NSLog(@"PVar事件：%@",pvarEventArray);
//    if (pvarEventArray.count==0)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariable,pvar为空测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariable,pvar为空测试失败:%@",pvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//
//
////    //将Log日志写入文件
////    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVar"] tap];
////    //检测日志输出
////    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
////    //恢复日志重定向
////    [LogOperHelper redirectLogBack];
////    if(chres)
////    {
////        XCTAssertEqual(1,1);
////        NSLog(@"pvar事件，setPageVariable,pvar为空,日志检测测试通过-----passed");
////    }
////    else
////    {
////        NSLog(@"pvar事件，setPageVariable,pvar为空,日志检测测试失败-----Failed");
////        XCTAssertEqual(1,0);
////    }
//
//}
//
//
//-(void)test4PvarKeyStr{
//    /**
//     function:setPageVariableWithKey:andStringValue添加变量
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"pvar1"];
////    [tester tapViewWithAccessibilityLabel:@"PVarSv"];
////    [tester enterTextIntoCurrentFirstResponder:@"pvalue"];
////    [[viewTester usingLabel:@"SetPgVS"] tap];
////    [Growing setPageAttributes:@{@"pvar1":@"pvalue"}];
//    [tester waitForTimeInterval:3];
//    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
//    //NSLog(@"PVar事件：%@",pvarEventArray);
//    if (pvarEventArray.count>=1)
//    {
//        NSDictionary *pvarchr=[pvarEventArray objectAtIndex:pvarEventArray.count-1];
//        XCTAssertEqualObjects(pvarchr[@"eventType"], @"pvar");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:pvarchr :@"attributes"]);
//        XCTAssertEqualObjects(pvarchr[@"attributes"][@"pvar1"], @"pvalue");
//        NSDictionary *chres=[ManualTrackHelper PvarEventCheck:pvarchr];
//        //NSLog(@"Check Result:%@",chres);
//        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue添加变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue添加变量测试失败:%@",pvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}

//-(void)test2PvarKeyStrUpdate{
//    /**
//     function:setPageVariableWithKey:andStringValue更新变量
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"pvar1"];
////    [tester tapViewWithAccessibilityLabel:@"PVarSv"];
////    [tester enterTextIntoCurrentFirstResponder:@"pupdate"];
////    [[viewTester usingLabel:@"SetPgVS"] tap];
////    [Growing setPageAttributes:@{@"pvar1":@"pupdate"}];
//    [tester waitForTimeInterval:3];
//    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
//    //NSLog(@"PVar事件：%@",pvarEventArray);
//    if (pvarEventArray.count>=1)
//    {
//        NSDictionary *pvarchr=[pvarEventArray objectAtIndex:pvarEventArray.count-1];
//        XCTAssertEqualObjects(pvarchr[@"eventType"], @"pvar");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:pvarchr :@"attributes"]);
//        XCTAssertEqualObjects(pvarchr[@"attributes"][@"pvar1"], @"pupdate");
//        NSDictionary *chres=[ManualTrackHelper PvarEventCheck:pvarchr];
//        //NSLog(@"Check Result:%@",chres);
//        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue更新变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue更新变量测试失败:%@",pvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
//
//-(void)test6PvarKeyStrKeyEmpty{
//    /**
//     function:setPageVariableWithKey:andStringValue key为空
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@""];
////    [tester tapViewWithAccessibilityLabel:@"PVarSv"];
////    [tester enterTextIntoCurrentFirstResponder:@"pupdate"];
//
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVS"] tap];
////    [Growing setPageAttributes:@{@"":@"pupdate"}];
//
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue key为空日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue key为空日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test7PvarKeyStrKeyNil{
//    /**
//     function:setPageVariableWithKey:andStringValue key为nil
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
////    [tester tapViewWithAccessibilityLabel:@"PVarSv"];
////    [tester enterTextIntoCurrentFirstResponder:@"pupdate"];
//
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVS"] tap];
////    [Growing setPageAttributes:@{[NSNull null]:@"pupdate"}];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue key为nil日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue key为nil日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test8PvarKeyStrValEmpty{
//    /**
//     function:setPageVariableWithKey:andStringValue Value为空
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"pvar1"];
////    [tester tapViewWithAccessibilityLabel:@"PVarSv"];
////    [tester enterTextIntoCurrentFirstResponder:@""];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVS"] tap];
////    [Growing setPageAttributes:@{@"pvar1":@""}];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue Value为空日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue Value为空日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//
//-(void)test9PvarKeyStrValNil{
//    /**
//     function:setPageVariableWithKey:andStringValue Value为Nil清除变量
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"pvar1"];
////    [tester tapViewWithAccessibilityLabel:@"PVarSv"];
////    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
////    [[viewTester usingLabel:@"SetPgVS"] tap];
////    [Growing setPageAttributes:@{@"pvar1":[NSNull NULL]}];
//    [tester waitForTimeInterval:3];
//    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
//    //NSLog(@"PVar事件：%@",pvarEventArray);
//    if(pvarEventArray.count==0)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue Value为Nil清除变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andStringValue Value为Nil清除变量测试失败:%@",pvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
////-(void)test10PvarKeyNumVal{
////    /**
////     function:setPageVariableWithKey:andNumValue 添加变量
////     **/
////    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"pnvar1"];
////    [tester tapViewWithAccessibilityLabel:@"PVarNv"];
////    [tester enterTextIntoCurrentFirstResponder:@"342"];
////    [[viewTester usingLabel:@"SetPgVN"] tap];
////    [tester waitForTimeInterval:3];
////    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
////    //NSLog(@"PVar事件：%@",pvarEventArray);
////    if (pvarEventArray.count>=1)
////    {
////        NSDictionary *pvarchr=[pvarEventArray objectAtIndex:pvarEventArray.count-1];
////        XCTAssertEqualObjects(pvarchr[@"eventType"], @"pvar");
////        XCTAssertTrue([ManualTrackHelper CheckContainsKey:pvarchr :@"attributes"]);
////        XCTAssertEqual([pvarchr[@"attributes"][@"pnvar1"] intValue],342);
////        NSDictionary *chres=[ManualTrackHelper PvarEventCheck:pvarchr];
////        //NSLog(@"Check Result:%@",chres);
////        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
////        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
////        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue 添加变量测试通过-----passed");
////    }
////    else
////    {
////        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue 添加变量测试失败:%@",pvarEventArray);
////        XCTAssertEqual(1,0);
////    }
////}
//
//-(void)test11PvarKeyNumValUpdate{
//    /**
//     function:setPageVariableWithKey:andNumValue 更新变量
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"pnvar1"];
////    [tester tapViewWithAccessibilityLabel:@"PVarNv"];
////    [tester enterTextIntoCurrentFirstResponder:@"78.27"];
////    [[viewTester usingLabel:@"SetPgVN"] tap];
////    [Growing setPageAttributes:@{@"pnvar1":@"78.27"}];
//    [tester waitForTimeInterval:3];
//    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:@"pvar"];
//    //NSLog(@"PVar事件：%@",pvarEventArray);
//    if (pvarEventArray.count>=1)
//    {
//        NSDictionary *pvarchr=[pvarEventArray objectAtIndex:pvarEventArray.count-1];
//        XCTAssertEqualObjects(pvarchr[@"eventType"], @"pvar");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:pvarchr :@"attributes"]);
//        NSString *fnum=@"78.27";
//        XCTAssertEqual([pvarchr[@"attributes"][@"pnvar1"] floatValue],[fnum floatValue]);
//        NSDictionary *chres=[ManualTrackHelper PvarEventCheck:pvarchr];
//        //NSLog(@"Check Result:%@",chres);
//        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue 更新变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue 更新变量测试失败:%@",pvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test12PvarKeyNumValKeyNil{
//    /**
//     function:setPageVariableWithKey:andNumValue Key为nil日志检测
//     **/
////    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
////    [tester tapViewWithAccessibilityLabel:@"PVarNv"];
////    [tester enterTextIntoCurrentFirstResponder:@"78.27"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVN"] tap];
////    [Growing setPageAttributes:@{[NSNull null]:@"78.27"}];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue Key为nil日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue Key为nil日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test13PvarKeyNumValKeyEmpty{
//    /**
//     function:setPageVariableWithKey:andNumValue Key为空日志检测
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@""];
////    [tester tapViewWithAccessibilityLabel:@"PVarNv"];
////    [tester enterTextIntoCurrentFirstResponder:@"78.27"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVN"] tap];
////    [Growing setPageAttributes:@{@"":@"78.27"}];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue Key为空日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue Key为空日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test14PvarKeyNumValValueStr{
//    /**
//     function:setPageVariableWithKey:andNumValue value为字符串日志检测
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"pvar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"PVarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"pnvar1"];
////    [tester tapViewWithAccessibilityLabel:@"PVarNv"];
////    [tester enterTextIntoCurrentFirstResponder:@"GIO Test"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetPgVN"] tap];
////    [Growing setPageAttributes:@{@"pnvar1":@"GIO Test"}];
//
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue value为字符串日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"pvar事件，setPageVariableWithKey:andNumValue value为字符串日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
@end
