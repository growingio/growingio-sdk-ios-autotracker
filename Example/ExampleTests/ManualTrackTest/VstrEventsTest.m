//
//  VstrEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/7/12.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  Function:vstr事件的测试
//

#import "VstrEventsTest.h"
#import "MockEventQueue.h"
#import "ManualTrackHelper.h"
#import "GrowingTracker.h"
#import "LogOperHelper.h"

@implementation VstrEventsTest

- (void)setUp{
    //设置userid,确保cs1字段不空
    [Growing setLoginUserId:@"test"];

}

-(void)test1VstrNormal{
    /**
     function:vstr正常情况
     **/
    [tester waitForTimeInterval:1];
    [MockEventQueue.sharedQueue cleanQueue];
    [Growing setVisitorAttributes:@{@"var1":@"good",@"var2":@"excell"}];
    NSArray *vstrEventArray = [MockEventQueue.sharedQueue eventsFor:@"vstr"];
    NSLog(@"Vstr事件：%@",vstrEventArray);
    if (vstrEventArray.count>=1)
    {
        NSDictionary *epvarchr=[vstrEventArray objectAtIndex:vstrEventArray.count-1];
        XCTAssertEqualObjects(epvarchr[@"t"], @"vstr");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr :@"var"]);
        XCTAssertEqualObjects(epvarchr[@"var"][@"var1"], @"good");
        XCTAssertEqualObjects(epvarchr[@"var"][@"var2"], @"excell");

        NSDictionary *chres=[ManualTrackHelper VstrEventCheck:epvarchr];
        //NSLog(@"Check Result:%@",chres);
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，vstr正常情况测试通过-----passed");
    }
    else
    {
        NSLog(@"EVar事件，vstr正常情况测试失败:%@",vstrEventArray);
        XCTAssertEqual(1,0);
    }
}

//-(void)test2VstrNil{
//    /**
//     function:vstr为Nil
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [tester scrollViewWithAccessibilityLabel:@"imp请求" byFractionOfSizeHorizontal:0.0f vertical:-10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"vstr请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"SetVstr"];
//    [tester enterTextIntoCurrentFirstResponder:@"NULL"];
//    [[viewTester usingLabel:@"SetVVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *vstrEventArray = [MockEventQueue eventsFor:@"vstr"];
//    //NSLog(@"Vstr事件：%@",vstrEventArray);
//    if (vstrEventArray.count==0)
//    {
//         XCTAssertEqual(1,1);
//        NSLog(@"EVar事件，vstr为Nil测试成功---Passed");
//    }
//    else
//    {
//        NSLog(@"EVar事件，vstr为Nil测试失败---Failed");
//        XCTAssertEqual(1,0);
//    }
//}


//-(void)test3VstrEmpty{
//    /**
//     function:vstr为空
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [tester scrollViewWithAccessibilityLabel:@"imp请求" byFractionOfSizeHorizontal:0.0f vertical:-10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"vstr请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"SetVstr"];
//    [tester enterTextIntoCurrentFirstResponder:@"{}"];
//    [[viewTester usingLabel:@"SetVVar"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *vstrEventArray = [MockEventQueue eventsFor:@"vstr"];
//    //NSLog(@"Vstr事件：%@",vstrEventArray);
//    if (vstrEventArray.count>=1)
//    {
//        NSDictionary *epvarchr=[vstrEventArray objectAtIndex:vstrEventArray.count-1];
//        XCTAssertEqualObjects(epvarchr[@"t"], @"vstr");
//        NSDictionary *chres=[ManualTrackHelper VstrEventCheck:epvarchr];
//        //NSLog(@"Check Result:%@",chres);
//        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
//        NSLog(@"EVar事件，vstr正常情况测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"EVar事件，vstr正常情况测试失败:%@",vstrEventArray);
//        XCTAssertEqual(1,0);
//    }
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetVVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"Vstr事件，vstr为空，日志提醒测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"Vstr事件，vstr为空，日志提醒，日志提醒测试失败!---Failed");
//        XCTAssertEqual(1,0);
//    }
//}

//-(void)test4VstrPartRight{
//    /**
//     function:vstr Dict部分正确
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [tester scrollViewWithAccessibilityLabel:@"imp请求" byFractionOfSizeHorizontal:0.0f vertical:-10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"vstr请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"SetVstr"];
//    [tester enterTextIntoCurrentFirstResponder:@"{\"Name\":\"SXF\",\"\":\"QA\"}"];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetVVar"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getFlagErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"Vstr事件，Dict部分正确，日志提醒测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"Vstr事件，Dict部分正确，日志提醒，日志提醒测试失败!---Failed");
//        XCTAssertEqual(1,0);
//    }
//}

//-(void)test2VstrLargeDic{
//    /**
//     function:vstr Dict为超过100个键值对
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [tester scrollViewWithAccessibilityLabel:@"imp请求" byFractionOfSizeHorizontal:0.0f vertical:-10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"vstr请求"] tap];
//    //将Log日志写入文件
//    [LogOperHelper writeLogToFile];
//    [[viewTester usingLabel:@"SetVVarOR"] tap];
//    //检测日志输出
//    Boolean chres=[LogOperHelper CheckLogOutput:[LogOperHelper getValueErrNsLog]];
//    //恢复日志重定向
//    [LogOperHelper redirectLogBack];
//    if(chres)
//    {
//        XCTAssertEqual(1,1);
//        NSLog(@"Vstr事件，Dict为超过100个键值对，日志提醒测试通过-----passed");
//    }
//    else
//    {
//        NSLog(@"Vstr事件，Dict为超过100个键值对，日志提醒测试失败!---Failed");
//        XCTAssertEqual(1,0);
//    }
//}
@end
