////
////  AppVarEventsTest.m
////  GIOAutoTests
////
////  Created by GrowingIO on 2018/6/11.
////  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
////
//
//#import "AppVarEventsTest.h"
//#import "MockEventQueue.h"
//#import "ManualTrackHelper.h"
//#import "LogOperHelper.h"
//
//@implementation AppVarEventsTest
//
//-(void)test1AppVarNormal{
//    /**
//     function:setAppVariable正常情况
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVar"];
//    [tester enterTextIntoCurrentFirstResponder:@"{\"cs2\":\"GIO\",\"cs3\":\"QA\"}"];
//    [[viewTester usingLabel:@"SetAppVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *apvarEventArray = [MockEventQueue eventsFor:@"page"];
//    //NSLog(@"AppVar事件：%@",apvarEventArray);
//    if (apvarEventArray.count>=1)
//    {
//        NSDictionary *apvarchr=[apvarEventArray objectAtIndex:apvarEventArray.count-1];
//        XCTAssertEqualObjects(apvarchr[@"t"], @"page");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:apvarchr :@"var"]);
//        XCTAssertEqualObjects(apvarchr[@"var"][@"cs2"], @"GIO");
//        XCTAssertEqualObjects(apvarchr[@"var"][@"cs3"], @"QA");
//        NSLog(@"AppVar事件，setAppVariable正常情况测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable正常情况测试失败:%@",apvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test2AppVarNil{
//    /**
//     function:setAppVariable，var为nil
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVar"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetAppVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        
//        XCTAssertEqual(1, 1);
//        NSLog(@"AppVar事件，setAppVariable，var为nil日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable，var为nil日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test3AppVarEmpty{
//    /**
//     function:setAppVariable，var为Dict为空
//      2019-1-7,优化支持传空对象：{}
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVar"];
//    [tester enterTextIntoCurrentFirstResponder:@"{}"];
//    [[viewTester usingLabel:@"SetAppVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *apvarEventArray = [MockEventQueue eventsFor:@"page"];
//    //NSLog(@"AppVar事件：%@",apvarEventArray);
//    if (apvarEventArray.count>=1)
//    {
//        NSDictionary *apvarchr=[apvarEventArray objectAtIndex:apvarEventArray.count-1];
//        XCTAssertEqualObjects(apvarchr[@"t"], @"page");
//        NSLog(@"AppVar事件，setAppVariable，var为Dict为空测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable，var为Dict为空测试失败:%@",apvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//    
////    //将Log日志写入文件
////    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SetAppVar"] tap];
////    //检测日志输出
////    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
////    //恢复日志重定向
////    [LogOperHelper redirectLogBack];
////    if(chres)
////    {
////
////        XCTAssertEqual(1, 1);
////        NSLog(@"AppVar事件，setAppVariable，var为Dict为空日志检测测试通过-----passed");
////    }
////    else
////    {
////        NSLog(@"AppVar事件，setAppVariable，var为Dict为空日志检测测试失败---Failed");
////        XCTAssertEqual(1,0);
////    }
//}
//
//-(void)test4AppVarStr{
//    /**
//     function:setAppVariable:andStringValue设置变量
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs4"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"Addr BeiJing"];
//    [[viewTester usingLabel:@"SetApSVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *apvarEventArray = [MockEventQueue eventsFor:@"page"];
//    //NSLog(@"AppVar事件：%@",apvarEventArray);
//    if (apvarEventArray.count>=1)
//    {
//        NSDictionary *apvarchr=[apvarEventArray objectAtIndex:apvarEventArray.count-1];
//        XCTAssertEqualObjects(apvarchr[@"t"], @"page");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:apvarchr :@"var"]);
//        XCTAssertEqualObjects(apvarchr[@"var"][@"cs4"], @"Addr BeiJing");
//        NSLog(@"AppVar事件,setAppVariable:andStringValue设置变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andStringValue设置变量测试失败:%@",apvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test2AppVarStrUpdate{
//    /**
//     function:setAppVariable:andStringValue更新变量
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs4"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"Addr HeNan"];
//    [[viewTester usingLabel:@"SetApSVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *apvarEventArray = [MockEventQueue eventsFor:@"page"];
//    //NSLog(@"AppVar事件：%@",apvarEventArray);
//    if (apvarEventArray.count>=1)
//    {
//        NSDictionary *apvarchr=[apvarEventArray objectAtIndex:apvarEventArray.count-1];
//        XCTAssertEqualObjects(apvarchr[@"t"], @"page");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:apvarchr :@"var"]);
//        XCTAssertEqualObjects(apvarchr[@"var"][@"cs4"], @"Addr HeNan");
//        NSLog(@"AppVar事件,setAppVariable:andStringValue更新变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andStringValue更新变量测试失败:%@",apvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test6AppVarStrKeyEmpty{
//    /**
//     function:setAppVariable:andStringValue Key为空
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    [tester tapViewWithAccessibilityLabel:@"AppVarSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"Addr HeNan"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApSVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Key为空日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Key为空日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test7AppVarStrKeyNil{
//    /**
//     function:setAppVariable:andStringValue Key为Nil
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"Addr HeNan"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApSVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Key为nil日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Key为nil日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test8AppVarStrValueNil{
//    /**
//     function:setAppVariable:andStringValue Value为Nil,清除关键字，不发送数据
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs2"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"SetApSVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *apvarEventArray = [MockEventQueue eventsFor:@"page"];
//    NSLog(@"AppVar事件：%@",apvarEventArray);
//    if(apvarEventArray.count==0)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Value为Nil,清除关键字，不发送数据测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Value为Nil,清除关键字，不发送数据测试失败----Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test9AppVarStrValueEmpty{
//    /**
//     function:setAppVariable:andStringValue Value为空日志检测
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs2"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApSVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Value为空日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andStringValue Value为空日志检测测试失败----Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test10AppVarNumValue{
//    /**
//     function:setAppVariable:andNumberValue设置变量
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs2"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"422"];
//    [[viewTester usingLabel:@"SetApNVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *apvarEventArray = [MockEventQueue eventsFor:@"page"];
//    //NSLog(@"AppVar事件：%@",apvarEventArray);
//    if (apvarEventArray.count>=1)
//    {
//        NSDictionary *apvarchr=[apvarEventArray objectAtIndex:apvarEventArray.count-1];
//        //NSLog(@"*****AppVar事件：%@",apvarchr);
//        XCTAssertEqualObjects(apvarchr[@"t"], @"page");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:apvarchr :@"var"]);
//        XCTAssertEqual([apvarchr[@"var"][@"cs2"] intValue], 422);
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue设置变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue设置变量测试失败:%@",apvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test11AppVarNumValueUpdate{
//    /**
//     function:setAppVariable:andNumberValue更新变量
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs2"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"39.82"];
//    [[viewTester usingLabel:@"SetApNVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *apvarEventArray = [MockEventQueue eventsFor:@"page"];
//    //NSLog(@"AppVar事件：%@",apvarEventArray);
//    if (apvarEventArray.count>=1)
//    {
//        NSDictionary *apvarchr=[apvarEventArray objectAtIndex:apvarEventArray.count-1];
//        //NSLog(@"*****AppVar事件：%@",apvarchr);
//        XCTAssertEqualObjects(apvarchr[@"t"], @"page");
//        XCTAssertTrue([ManualTrackHelper CheckContainsKey:apvarchr :@"var"]);
//        NSString *floatchr=@"39.82";
//        XCTAssertEqual([apvarchr[@"var"][@"cs2"] floatValue], [floatchr floatValue]);
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue更新变量测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue更新变量测试失败:%@",apvarEventArray);
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test12AppVarNumValueKeyNil{
//    /**
//     function:setAppVariable:andNumberValue Key为nil
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"39.82"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApNVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Key为nil日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Key为nil日志检测测试失败----Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test13AppVarNumValueKeyEmpty{
//    /**
//     function:setAppVariable:andNumberValue Key为空
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    [tester tapViewWithAccessibilityLabel:@"AppVarNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"39.82"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApNVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Key为空日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Key为空日志检测测试失败----Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test14AppVarNumValueNumEmptyStr{
//    /**
//     function:setAppVariable:andNumberValue Number为空
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs6"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApNVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Number为空日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Number为空日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//-(void)test12AppVarNumValueNumStr{
//    /**
//     function:setAppVariable:andNumberValue Number为字符串
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"AppVarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"cs6"];
//    [tester tapViewWithAccessibilityLabel:@"AppVarNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"GIO"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApNVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Number为字符串日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable:andNumberValue Number为字符串日志检测测试失败-----Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//
//
//-(void)test16AppVarDictOutRange{
//    /**
//     function:setAppVariable字典为超过100个键值对
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"appvar请求"] tap];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetApOutR"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"AppVar事件，setAppVariable字典为超过100个键值对,日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"AppVar事件，setAppVariable字典为超过100个键值对,日志检测测试失败-----Failed");
//        XCTAssertEqual(1,0);
//    }
//}
//@end
