//
//  PPLEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/8.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  function:ppl事件相关测试用例

#import "PPLEventsTest.h"
#import "MockEventQueue.h"
#import "ManualTrackHelper.h"
#import "LogOperHelper.h"
#import "GrowingTracker.h"

@implementation PPLEventsTest

//-(void)tearDown{
//     [[viewTester usingLabel:@"协议/接口"] tap];
//}
-(void)test1PplNormal{
    /**
     function:setPeopleVariable正常情况
     **/
    [Growing setLoginUserId:@"test"];
    [MockEventQueue.sharedQueue cleanQueue];
    [Growing setLoginUserAttributes:@{@"name":@"测试名字",@"title":@"QA"}];
    [tester waitForTimeInterval:2];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:@"ppl"];
    NSLog(@"PPL事件：%@",pplEventArray);
    if (pplEventArray.count>=1)
    {
        NSDictionary *cstmchr=[pplEventArray objectAtIndex:pplEventArray.count-1];
        XCTAssertEqualObjects(cstmchr[@"t"], @"ppl");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:cstmchr :@"var"]);
        XCTAssertEqualObjects(cstmchr[@"var"][@"name"], @"测试名字");
        XCTAssertEqualObjects(cstmchr[@"var"][@"title"], @"QA");
        NSDictionary *chres=[ManualTrackHelper PplEventCheck:cstmchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"ppl事件，setPeopleVariable正常情况测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariable正常情况测试失败:%@",pplEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test2PplNil{
    /**
     function:setPeopleVariable为nil,日志检测
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PVariable"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
    
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
 //    [[viewTester usingLabel:@"SetPV"] tap];
    [Growing setLoginUserAttributes:nil];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"ppl事件，setPeopleVariable为nil,日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariable为nil,日志检测测试失败---Failed");
        XCTAssertEqual(1,0);
    }
}

-(void)test3PplEmpty{
    /**
     function:setPeopleVariable为空
     2019-1-7,优化支持传空对象：{}
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [Growing setLoginUserAttributes:@{}];
    [tester waitForTimeInterval:2];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:@"ppl"];
    NSLog(@"PPL事件：%@",pplEventArray);
    if (pplEventArray.count>=1)
    {
        NSDictionary *cstmchr=[pplEventArray objectAtIndex:pplEventArray.count-1];
        XCTAssertEqualObjects(cstmchr[@"t"], @"ppl");
        NSDictionary *chres=[ManualTrackHelper PplEventCheck:cstmchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"ppl事件，setPeopleVariable为空测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariable为空测试失败:%@",pplEventArray);
        XCTAssertEqual(1,0);
    }
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetPV"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"ppl事件，setPeopleVariable为空,日志检测测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"ppl事件，setPeopleVariable为空,日志检测测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
}

-(void)test4SpvAndStr{
    /**
     function:setPeopleVariableWithKey:andStringValue,发送正常数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"name"];
//    [tester tapViewWithAccessibilityLabel:@"PplSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"GrowingIO"];
    [Growing setLoginUserAttributes:@{@"name":@"GrowingIO"}];
 //   [[viewTester usingLabel:@"SetPVS"] tap];

    [tester waitForTimeInterval:2];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:@"ppl"];
    //NSLog(@"PPL事件：%@",pplEventArray);
    if (pplEventArray.count>=1)
    {
        NSDictionary *cstmchr=[pplEventArray objectAtIndex:pplEventArray.count-1];
        XCTAssertEqualObjects(cstmchr[@"t"], @"ppl");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:cstmchr :@"var"]);
        XCTAssertEqualObjects(cstmchr[@"var"][@"name"], @"GrowingIO");
        NSDictionary *chres=[ManualTrackHelper PplEventCheck:cstmchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"ppl事件,setPeopleVariableWithKey:andStringValue,发送正常数据测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件,setPeopleVariableWithKey:andStringValue,发送正常数据测试失败:%@",pplEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test5SpvAndStrUpdate{
    /**
     function:setPeopleVariableWithKey:andStringValue,更新数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"name"];
//    [tester tapViewWithAccessibilityLabel:@"PplSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"GIO"];
//    [[viewTester usingLabel:@"SetPVS"] tap];
    [Growing setLoginUserAttributes:@{@"name":@"GIO"}];
    [tester waitForTimeInterval:2];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:@"ppl"];
    //NSLog(@"PPL事件：%@",pplEventArray);
    if (pplEventArray.count>=1)
    {
        NSDictionary *cstmchr=[pplEventArray objectAtIndex:pplEventArray.count-1];
        XCTAssertEqualObjects(cstmchr[@"t"], @"ppl");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:cstmchr :@"var"]);
        XCTAssertEqualObjects(cstmchr[@"var"][@"name"], @"GIO");
        NSDictionary *chres=[ManualTrackHelper PplEventCheck:cstmchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"ppl事件,setPeopleVariableWithKey:andStringValue,更新数据测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件,setPeopleVariableWithKey:andStringValue,更新数据测试失败:%@",pplEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test6SpvAndStrKeyError{
    /**
     function:setPeopleVariableWithKey:andStringValue,Key为空
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    [tester tapViewWithAccessibilityLabel:@"PplSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"GIO"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
    [Growing setLoginUserAttributes:@{@"":@"GIO"}];
  //  [[viewTester usingLabel:@"SetPVS"] tap];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Key为空日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Key为空日志检测测试失败---Failed");
        XCTAssertEqual(1,0);
    }
}


-(void)test7SpvAndStrKeyNil{
    /**
     function:setPeopleVariableWithKey:andStringValue,Key为Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    [tester tapViewWithAccessibilityLabel:@"PplSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"GIO"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
 //   [[viewTester usingLabel:@"SetPVS"] tap];
    [Growing setLoginUserAttributes:@{[NSNull null]:@"GIO"}];

    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Key为nil日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Key为nil日志检测测试失败---Failed");
        XCTAssertEqual(1,0);
    }
}

-(void)test8SpvAndStrValueNil{
    /**
     function:setPeopleVariableWithKey:andStringValue,Value为Nil
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"name"];
//    [tester tapViewWithAccessibilityLabel:@"PplSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
 //   [[viewTester usingLabel:@"SetPVS"] tap];
    [Growing setLoginUserAttributes:@{@"name":[NSNull null]}];

    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Value为Nil日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Value为Nil日志检测测试失败---Failed");
        XCTAssertEqual(1,0);
    }
    
}

-(void)test9SpvAndStrValueEmpty{
    /**
     function:setPeopleVariableWithKey:andStringValue,Value为Empty
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"name"];
//    [tester tapViewWithAccessibilityLabel:@"PplSVal"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
 //   [[viewTester usingLabel:@"SetPVS"] tap];
    [Growing setLoginUserAttributes:@{@"name":@""}];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Value为Empty日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariableWithKey:andStringValue,Value为Empty日志检测测试失败---Failed");
        XCTAssertEqual(1,0);
    }
    
}
-(void)test10SpvAndNum{
    /**
     function:setPeopleVariableWithKey:andNumberValue正整数
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [Growing setLoginUserAttributes:@{@"score":@"98"}];
    [tester waitForTimeInterval:2];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:@"ppl"];
    //NSLog(@"PPL事件：%@",pplEventArray);
    if (pplEventArray.count>=1)
    {
        NSDictionary *cstmchr=[pplEventArray objectAtIndex:pplEventArray.count-1];
        NSLog(@"ppl Result:%@",cstmchr);
        XCTAssertEqualObjects(cstmchr[@"t"], @"ppl");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:cstmchr :@"var"]);
        NSString *cstmnum=cstmchr[@"var"][@"score"];
        XCTAssertEqual([cstmnum intValue],98);
        NSDictionary *chres=[ManualTrackHelper PplEventCheck:cstmchr];
        NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"ppl事件,setPeopleVariableWithKey:andNumberValue正整数测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件,setPeopleVariableWithKey:andNumberValue正整数测试失败:%@",pplEventArray);
        XCTAssertEqual(1,0);
    }
}

-(void)test11SpvAndNumUpdate{
    /**
     function:setPeopleVariableWithKey:andNumberValue更新为浮点数
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@"score"];
//    [tester tapViewWithAccessibilityLabel:@"PplNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"23.62"];
//    [[viewTester usingLabel:@"SetPVN"] tap];
    [Growing setLoginUserAttributes:@{@"score":@"23.62"}];
    [tester waitForTimeInterval:2];
    NSArray *pplEventArray = [MockEventQueue.sharedQueue eventsFor:@"ppl"];
    //NSLog(@"PPL事件：%@",pplEventArray);
    if (pplEventArray.count>=1)
    {
        NSDictionary *cstmchr=[pplEventArray objectAtIndex:pplEventArray.count-1];
        XCTAssertEqualObjects(cstmchr[@"t"], @"ppl");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:cstmchr :@"var"]);
        NSString *cstmnum=cstmchr[@"var"][@"score"];
        NSString *floatchr=@"23.62";
        XCTAssertEqual([cstmnum floatValue],[floatchr floatValue]);
        NSDictionary *chres=[ManualTrackHelper PplEventCheck:cstmchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"ppl事件,setPeopleVariableWithKey:andNumberValue更新为浮点数测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件,setPeopleVariableWithKey:andNumberValue更新为浮点数测试失败:%@",pplEventArray);
        XCTAssertEqual(1,0);
    }
}



-(void)test13SpvAndNumKeyError{
    /**
     function:setPeopleVariableWithKey:andNumberValue Key为空不发送事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"ppl请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"PplKey"];
//    [tester enterTextIntoCurrentFirstResponder:@""];
//    [tester tapViewWithAccessibilityLabel:@"PplNVal"];
//    [tester enterTextIntoCurrentFirstResponder:@"42"];
    //将Log日志写入文件
    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetPVN"] tap];
    [Growing setLoginUserAttributes:@{@"":@"42"}];
    //检测日志输出
    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
    //恢复日志重定向
    [LogOperHelper redirectLogBack];
    if(chres)
    {
        XCTAssertEqual(1,1);
        NSLog(@"ppl事件，setPeopleVariableWithKey:andNumberValue，Key为空日志检测测试通过-----passed");
    }
    else
    {
        NSLog(@"ppl事件，setPeopleVariableWithKey:andNumberValue，Key为空日志检测测试失败---Failed");
        XCTAssertEqual(1,0);
    }
}
@end
