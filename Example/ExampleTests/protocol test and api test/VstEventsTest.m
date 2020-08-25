//
//  VstEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "VstEventsTest.h"
#import "MockEventQueue.h"
#import "GrowingTestHelper.h"
#import "NoburPoMeaProCheck.h"
#import "GrowingTracker.h"

@implementation VstEventsTest

- (void)beforeEach {
    //设置userid,确保cs1字段不空
    [Growing setLoginUserId:@"test"];
}
- (void)afterEach {
     //[GrowingTestHelper ExiteApp];
}

-(void)test1SetLocation{
    /**
     function:SetLocation触发，从null -> 非null 发一次。非null - 非null不发vst
     **/
    NSString *oldSession = [Growing getSessionId];
    XCTAssertNotNil(oldSession);
    [Growing cleanLocation];
    [MockEventQueue.sharedQueue cleanQueue];
    [Growing setLocation:[@30.11 doubleValue] longitude:[@32.22 doubleValue]];
    [tester waitForTimeInterval:1];
    NSArray *vstEventArray = [MockEventQueue.sharedQueue eventsFor:@"vst"];
    //NSLog(@"VST事件：%@",vstEventArray);
    if (vstEventArray.count>0)
    {
        NSDictionary *vstchr=[vstEventArray objectAtIndex:vstEventArray.count-1];

 //       NSDictionary *vstchr=[NoburPoMeaProCheck VstEventCheck:[vstEventArray objectAtIndex:vstEventArray.count-1]];
        NSLog(@"Check Result:%@",vstchr);
        //目前无地理位置请求和广告标识
//        XCTAssertEqualObjects(vstchr[@"KeysCheck"][@"chres"],@"Failed");
//        NSArray *incr=vstchr[@"ProCheck"][@"incre"];
//        NSArray *redu=vstchr[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(incr.count, 0);
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][0],@"latitude");
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][1],@"longitude");
        XCTAssertEqualObjects(vstchr[@"latitude"], @30.11);
        XCTAssertEqualObjects(vstchr[@"longitude"], @32.22);
        NSLog(@"setLocation 从null -> 非null 发vst，测试通过--Passed！");
    }
    else
    {
        NSLog(@"setLocation 从null -> 非null 发vst，测试不通过:%@",vstEventArray);
        XCTAssertEqual(1, 0);
    }

}

//-(void)test2UpdateUserId{
//    /**
//     function:更新setUserid触发vst事件
//     **/
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [tester scrollViewWithAccessibilityLabel:@"imp请求" byFractionOfSizeHorizontal:0.0f vertical:-10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"+ (void)setUserId:(NSString *)userId;"] tap];
//    [[viewTester usingLabel:@"SetUserID"] tap];
//    [[viewTester usingLabel:@"ChangeUID"] tap];
//    [tester waitForTimeInterval:2];
//    NSArray *vstEventArray = [MockEventQueue eventsFor:@"vst"];
//    //NSLog(@"VST事件：%@",vstEventArray);
//    if (vstEventArray.count>=1)
//    {
//        NSDictionary *vstchr=[NoburPoMeaProCheck VstEventCheck:[vstEventArray objectAtIndex:vstEventArray.count-1]];
//        //NSLog(@"Check Result:%@",vstchr);
//        //判断检测结果,目前无地理位置请求和广告标识
//        XCTAssertEqualObjects(vstchr[@"KeysCheck"][@"chres"],@"Failed");
//        NSArray *empty=vstchr[@"KeysCheck"][@"EmptyKeys"];
//        XCTAssertEqual(empty.count, 1);
//        XCTAssertEqualObjects(vstchr[@"KeysCheck"][@"EmptyKeys"][0],@"ui");
//
//        NSArray *incr=vstchr[@"ProCheck"][@"incre"];
//        NSArray *redu=vstchr[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(incr.count, 0);
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][0],@"latitude");
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][1],@"longitude");
//        NSLog(@"更新setUserid触发vst事件，测试通过--Passed！");
//    }
//    else
//    {
//        NSLog(@"更新setUserid触发vst事件，测试不通过:%@",vstEventArray);
//        XCTAssertEqual(1, 0);
//    }
//}

//-(void)test3ColdBoot{
//    /**
//     function:冷启动App,Vst事件检测
//     **/
//    //[MockEventQueue cleanQueue];
//    [tester waitForTimeInterval:2];
//    NSArray *vstEventArray = [MockEventQueue eventsFor:@"vst"];
//    //NSLog(@"VST事件：%@",vstEventArray);
//    if (vstEventArray.count>0)
//    {
//        NSDictionary *vstchr=[NoburPoMeaProCheck VstEventCheck:[vstEventArray objectAtIndex:vstEventArray.count-1]];
//        //NSLog(@"Check Result:%@",vstchr);
//        //判断检测结果,目前无地理位置请求
//        XCTAssertEqualObjects(vstchr[@"KeysCheck"][@"chres"],@"Failed");
//        NSArray *empty=vstchr[@"KeysCheck"][@"EmptyKeys"];
//        XCTAssertEqual(empty.count, 1);
//        XCTAssertEqualObjects(vstchr[@"KeysCheck"][@"EmptyKeys"][0],@"ui");
//
//        NSArray *incr=vstchr[@"ProCheck"][@"incre"];
//        NSArray *redu=vstchr[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(incr.count, 0);
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][0],@"latitude");
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][1],@"longitude");
//        NSLog(@"冷启动App,Vst事件检测，测试通过---Passed!");
//    }
//    else
//    {
//        NSLog(@"冷启动App,Vst事件检测，测试不通过:%@！",vstEventArray);
//        XCTAssertEqual(1, 0);
//    }
//
//}


//-(void)test4BackGroundToBefore{
//    /*
//     function:后台停留30s,再唤醒到前台
//     */
//    @try {
//        [system deactivateAppForDuration:30];
//    } @catch (NSException *exception) {
//        NSLog(@"从后台启动app，异常处理！");
//        CGPoint point=CGPointMake(32.0f, 14.0f);
//        [tester tapScreenAtPoint:point];
//    } @finally {
//        NSLog(@"*****This is the end!******");
//    }
//    
//    [tester waitForTimeInterval:2];
//    NSArray *vstEventArray = [MockEventQueue eventsFor:@"vst"];
//    //NSLog(@"VST事件：%@",vstEventArray);
//    if (vstEventArray.count>1)
//    {
//        NSDictionary *vstchr=[NoburPoMeaProCheck VstEventCheck:[vstEventArray objectAtIndex:vstEventArray.count-1]];
//        //NSLog(@"Check Result:%@",vstchr);
//        //判断检测结果,目前无地理位置请求
//        XCTAssertEqualObjects(vstchr[@"KeysCheck"][@"chres"],@"Failed");
//        NSArray *empty=vstchr[@"KeysCheck"][@"EmptyKeys"];
//        XCTAssertEqual(empty.count, 1);
//        XCTAssertEqualObjects(vstchr[@"KeysCheck"][@"EmptyKeys"][0],@"ui");
//        
//        NSArray *incr=vstchr[@"ProCheck"][@"incre"];
//        NSArray *redu=vstchr[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(incr.count, 0);
//        XCTAssertEqual(redu.count, 2);
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][0],@"latitude");
//        XCTAssertEqualObjects(vstchr[@"ProCheck"][@"reduce"][1],@"longitude");
//        NSLog(@"后台停留30s,再唤醒到前台，测试通过--Passed!");
//    }
//    else
//    {
//        NSLog(@"后台停留30s,再唤醒到前台，测试不通过:%@",vstEventArray);
//        XCTAssertEqual(1, 0);
//    }
//    
//    
//}
//
//-(void)test2UandSChange{
//    /*
//     function:测试两次vst请求中，U和S字段的变化
//     */
//    @try {
//        [system deactivateAppForDuration:30];
//    } @catch (NSException *exception) {
//        NSLog(@"从后台启动app，异常处理！");
//        CGPoint point=CGPointMake(32.0f, 14.0f);
//        [tester tapScreenAtPoint:point];
//    } @finally {
//        NSLog(@"*****This is the end!******");
//    }
//    
//    [tester waitForTimeInterval:2];
//    NSArray *vstEventArray = [MockEventQueue eventsFor:@"vst"];
//    //NSLog(@"VST事件：%@",vstEventArray);
//    if (vstEventArray.count>1)
//    {
//        NSDictionary *vstchrfirst=[vstEventArray objectAtIndex:0];
//        NSDictionary *vstchrsecond=[vstEventArray objectAtIndex:1];
//        XCTAssertEqualObjects(vstchrfirst[@"userId"], vstchrsecond[@"userId"]);
//        XCTAssertNotEqualObjects(vstchrfirst[@"sessionId"], vstchrsecond[@"sessionId"]);
//        NSLog(@"测试两次vst请求中，U和S字段的变化，测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"测试两次vst请求中，U和S字段的变化，测试不通过:%@",vstEventArray);
//        XCTAssertEqual(1, 0);
//    }
//    
//    
//}
@end
