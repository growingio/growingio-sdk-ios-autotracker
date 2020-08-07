//
//  EvarEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/12.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import "EvarEventsTest.h"
#import "MockEventQueue.h"
#import "ManualTrackHelper.h"
#import "GrowingTracker.h"
#import "LogOperHelper.h"

@implementation EvarEventsTest

- (void)setUp{
    //设置userid,确保cs1字段不空
    [Growing setLoginUserId:@"test"];

}

-(void)test1SetEvarNormal{
    /**
     function:setEvar正常情况
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //    [[viewTester usingLabel:@"协议/接口"] tap];
    //    [[viewTester usingLabel:@"evar请求"] tap];
    //    [tester tapViewWithAccessibilityLabel:@"Evalue"];
    //    [tester enterTextIntoCurrentFirstResponder:@"{\"var1\":\"good\",\"var2\":\"excell\"}"];
    //    [[viewTester usingLabel:@"SendEvar"] tap];
    [Growing setConversionVariables:@{@"var1":@"good",@"var2":@"excell"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"evar"];
    NSLog(@"EVar事件：%@",evarEventArray);
    if (evarEventArray.count>=1)
    {
        NSDictionary *epvarchr=[evarEventArray objectAtIndex:evarEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"evar");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr :@"var"]);
        XCTAssertEqualObjects(epvarchr[@"var"][@"var1"], @"good");
        XCTAssertEqualObjects(epvarchr[@"var"][@"var2"], @"excell");
        
        NSDictionary *chres=[ManualTrackHelper EvarEventCheck:epvarchr];
        NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，setEvar正常情况测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvar正常情况测试失败:%@",evarEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test2SetEvarNil{
    /**
     function:setEvar Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //    [[viewTester usingLabel:@"协议/接口"] tap];
    //    [[viewTester usingLabel:@"evar请求"] tap];
    //    [tester tapViewWithAccessibilityLabel:@"Evalue"];
    //    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SendEvar"] tap];
    [Growing setConversionVariables:nil];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"EVar事件，setEvar，日志提醒测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvar，日志提醒测试失败!---Failed");
        XCTAssertEqual(1,0);
    }
}


-(void)test3SetEvarEmpty{
    /**
     function:setEvar 空字典
     2019-1-7,优化支持传空对象：{}
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //    [[viewTester usingLabel:@"协议/接口"] tap];
    //    [[viewTester usingLabel:@"evar请求"] tap];
    //    [tester tapViewWithAccessibilityLabel:@"Evalue"];
    //    [tester enterTextIntoCurrentFirstResponder:@"{}"];
    //    [[viewTester usingLabel:@"SendEvar"] tap];
    [Growing setConversionVariables:@{}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"evar"];
    //NSLog(@"EVar事件：%@",evarEventArray);
    
    if (evarEventArray.count>=1)
    {
        NSDictionary *epvarchr=[evarEventArray objectAtIndex:evarEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"evar");
        NSDictionary *chres=[ManualTrackHelper EvarEventCheck:epvarchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，setEvar正常情况测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvar正常情况测试失败:%@",evarEventArray);
        XCTAssertEqual(1,0);
    }
    
    
    //    //将Log日志写入文件
    //    [LogOperHelper writeLogToFile];
    //    [[viewTester usingLabel:@"SendEvar"] tap];
    //    //检测日志输出
    //    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //    //恢复日志重定向
    //    [LogOperHelper redirectLogBack];
    //    if(chres)
    //    {
    //        XCTAssertEqual(1,1);
    //        NSLog(@"EVar事件，setEvar空字典，日志提醒测试通过-----passed");
    //    }
    //    else
    //    {
    //        NSLog(@"EVar事件，setEvar空字典，日志提醒测试失败!---Failed");
    //        XCTAssertEqual(1,0);
    //    }
}

-(void)test4SetEvarKeyStr{
    /**
     function:setEvarWithKey:andStringValue设置变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //    [[viewTester usingLabel:@"协议/接口"] tap];
    //    [[viewTester usingLabel:@"evar请求"] tap];
    //    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
    //    [tester enterTextIntoCurrentFirstResponder:@"ekey1"];
    //    [tester tapViewWithAccessibilityLabel:@"EvarStrVal"];
    //    [tester enterTextIntoCurrentFirstResponder:@"Good"];
    //    [[viewTester usingLabel:@"SendESVar"] tap];
    [Growing setConversionVariables:@{@"ekey1":@"Good"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"evar"];
    //NSLog(@"EVar事件：%@",evarEventArray);
    if (evarEventArray.count>=1)
    {
        NSDictionary *epvarchr=[evarEventArray objectAtIndex:evarEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"evar");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr :@"var"]);
        XCTAssertEqualObjects(epvarchr[@"var"][@"ekey1"], @"Good");
        
        NSDictionary *chres=[ManualTrackHelper EvarEventCheck:epvarchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，setEvarWithKey:andStringValue设置变量测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andStringValue设置变量测试失败:%@",evarEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test2SetEvarKeyStrUpdate{
    /**
     function:setEvarWithKey:andStringValue更新变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //    [[viewTester usingLabel:@"协议/接口"] tap];
    //    [[viewTester usingLabel:@"evar请求"] tap];
    //    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
    //    [tester enterTextIntoCurrentFirstResponder:@"ekey1"];
    //    [tester tapViewWithAccessibilityLabel:@"EvarStrVal"];
    //    [tester enterTextIntoCurrentFirstResponder:@"Better"];
    //    [[viewTester usingLabel:@"SendESVar"] tap];
    [Growing setConversionVariables:@{@"ekey1":@"Better"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"evar"];
    //NSLog(@"EVar事件：%@",evarEventArray);
    if (evarEventArray.count>=1)
    {
        NSDictionary *epvarchr=[evarEventArray objectAtIndex:evarEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"evar");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr :@"var"]);
        XCTAssertEqualObjects(epvarchr[@"var"][@"ekey1"], @"Better");
        
        NSDictionary *chres=[ManualTrackHelper EvarEventCheck:epvarchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，setEvarWithKey:andStringValue更新变量测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andStringValue更新变量测试失败:%@",evarEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test6SetEvarKeyEmpty{
    /**
     function:setEvarWithKey:andStringValue关键字为空,检测日志
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    [tester tapViewWithAccessibilityLabel:@"EvarStrVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"Better"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SendESVar"] tap];
    [Growing setConversionVariables:@{@"":@"Better"}];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"EVar事件，setEvarWithKey:andStringValue关键字为空,日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andStringValue关键字为空,日志检测测试失败----Failed");
        XCTAssertEqual(1,0);
    }
}

-(void)test7SetEvarKeyNil{
    /**
     function:setEvarWithKey:andStringValue关键字为nil,检测日志
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    [tester tapViewWithAccessibilityLabel:@"EvarStrVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"Better"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SendESVar"] tap];
    [Growing setConversionVariables:@{[NSNull null]:@"Better"}];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"EVar事件，setEvarWithKey:andStringValue关键字为nil,日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andStringValue关键字为nil,日志检测测试失败----Failed");
        XCTAssertEqual(1,0);
    }
}


//-(void)test8SetEvarValNil{
//    /**
//     function:setEvarWithKey:andStringValue 值为Nil
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"evar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"ekey1"];
////    [tester tapViewWithAccessibilityLabel:@"EvarStrVal"];
////    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SendESVar"] tap];
////    [Growing setConversionVariables:@{@"ekey1":nil}];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"EVar事件，setEvarWithKey:andStringValue值为Nil,日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"EVar事件，setEvarWithKey:andStringValue值为Nil,日志检测测试失败-----Failed");
//        XCTAssertEqual(1,0);
//    }
//}

-(void)test9SetEvarValStrEmpty{
    /**
     function:setEvarWithKey:andStringValue Str值为空,不发送数据,日志检测
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"ekey1"];
//    [tester tapViewWithAccessibilityLabel:@"EvarStrVal"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SendESVar"] tap];
    [Growing setConversionVariables:@{@"ekey1":@""}];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"EVar事件，setEvarWithKey:andStringValue Str值为空,日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andStringValue Str值为空,日志检测测试失败-----Failed");
        XCTAssertEqual(1,0);
    }
}

-(void)test10SetEvarValNum{
    /**
     function:setEvarWithKey:andNumberValue设置变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"evkey1"];
//    [tester tapViewWithAccessibilityLabel:@"EvarNumVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"132"];
//    [[viewTester usingLabel:@"SendENVar"] tap];
    [Growing setConversionVariables:@{@"evkey1":@"132"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"evar"];
    //NSLog(@"EVar事件：%@",evarEventArray);
    if (evarEventArray.count>=1)
    {
        NSDictionary *epvarchr=[evarEventArray objectAtIndex:evarEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"evar");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr :@"var"]);
        XCTAssertEqual([epvarchr[@"var"][@"evkey1"] intValue],132);
        
        NSDictionary *chres=[ManualTrackHelper EvarEventCheck:epvarchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue设置变量测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue设置变量测试失败:%@",evarEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test11SetEvarValNumUpdate{
    /**
     function:setEvarWithKey:andNumberValue更新变量
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"evkey1"];
//    [tester tapViewWithAccessibilityLabel:@"EvarNumVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"43.22"];
//    [[viewTester usingLabel:@"SendENVar"] tap];
    [Growing setConversionVariables:@{@"evkey1":@"43.22"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"evar"];
    //NSLog(@"EVar事件：%@",evarEventArray);
    if (evarEventArray.count>=1)
    {
        NSDictionary *epvarchr=[evarEventArray objectAtIndex:evarEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"evar");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr :@"var"]);
        NSString *fvalue=@"43.22";
        XCTAssertEqual([epvarchr[@"var"][@"evkey1"] floatValue],[fvalue floatValue]);
        
        NSDictionary *chres=[ManualTrackHelper EvarEventCheck:epvarchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue更新变量测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue更新变量测试失败:%@",evarEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test12SetEvarValNumKeyEmpty{
    /**
     function:setEvarWithKey:andNumberValue Key为空,日志检测
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    [tester tapViewWithAccessibilityLabel:@"EvarNumVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"43.22"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
//   [[viewTester usingLabel:@"SendENVar"] tap];
    [Growing setConversionVariables:@{@"":@"43.22"}];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Key为空,日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Key为空,日志检测测试失败----Failed");
        XCTAssertEqual(1,0);
    }
}

//-(void)test13SetEvarValNumKeyNil{
//    /**
//     function:setEvarWithKey:andNumberValue Key为Nil
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"evar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
////    [tester tapViewWithAccessibilityLabel:@"EvarNumVal"];
////    [tester enterTextIntoCurrentFirstResponder:@"123"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SendENVar"] tap];
//    [Growing setConversionVariables:@{NULL:@"43.22"}];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Key为Nil，日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Key为Nil，日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}

-(void)test14SetEvarValNumValEmpty{
    /**
     function:setEvarWithKey:andNumberValue Value为空
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"enkey2"];
//    [tester tapViewWithAccessibilityLabel:@"EvarNumVal"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
 //   [[viewTester usingLabel:@"SendENVar"] tap];
    [Growing setConversionVariables:@{@"enkey2":@""}];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Value为空,日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Value为空,日志检测测试失败----Failed");
        XCTAssertEqual(1,0);
    }
}
//-(void)test12SetEvarValNumValNil{
//    /**
//     function:setEvarWithKey:andNumberValue Value为Nil
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
////    [[viewTester usingLabel:@"协议/接口"] tap];
////    [[viewTester usingLabel:@"evar请求"] tap];
////    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
////    [tester enterTextIntoCurrentFirstResponder:@"enkey2"];
////    [tester tapViewWithAccessibilityLabel:@"EvarNumVal"];
////    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
////    [Growing setConversionVariables:@{@"enkey2":NULL}];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
////    [[viewTester usingLabel:@"SendENVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Value为Nil，日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"EVar事件，setEvarWithKey:andNumberValue Value为Nil，日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}

-(void)test16SetEvarKeyStrChinese{
    /**
     function:setEvarWithKey:andStringValue关键字和值为中文
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"evar请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"EvarKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"关键字"];
//    [tester tapViewWithAccessibilityLabel:@"EvarStrVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"北京"];
//    [[viewTester usingLabel:@"SendESVar"] tap];
    [Growing setConversionVariables:@{@"关键字":@"北京"}];
    [tester waitForTimeInterval:3];
    NSArray *evarEventArray = [MockEventQueue.sharedQueue eventsFor:@"evar"];
    //NSLog(@"EVar事件：%@",evarEventArray);
    if (evarEventArray.count>=1)
    {
        NSDictionary *epvarchr=[evarEventArray objectAtIndex:evarEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"evar");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr :@"var"]);
        XCTAssertEqualObjects(epvarchr[@"var"][@"关键字"], @"北京");
        
        NSDictionary *chres=[ManualTrackHelper EvarEventCheck:epvarchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，setEvarWithKey:andStringValue关键字和值为中文测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvarWithKey:andStringValue关键字和值为中文测试失败:%@",evarEventArray);
        XCTAssertEqual(1,0);
    }
}


-(void)test17SetEvarDicOutRange{
    /**
     function:setEvar数值字典超过100个关键字
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"evar请求"] tap];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    [[viewTester usingLabel:@"EventAttributesOutRange"] tap];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"EVar事件，setEvar数值字典超过100个关键字，日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，setEvar数值字典超过100个关键字，日志检测测试失败---Failed");
        XCTAssertEqual(1,0);
    }
}

@end
