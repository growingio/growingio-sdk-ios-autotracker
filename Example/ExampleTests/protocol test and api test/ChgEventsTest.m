//
//  ChgEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/28.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "ChgEventsTest.h"
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
#import "GrowingTracker.h"
@implementation ChgEventsTest


- (void)setUp{
    //设置userid,确保cs1字段不空
    [Growing setLoginUserId:@"test"];

}

-(void)test1TextFields{
    /**
     function:TextField输出内容，检测chng事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"Text Fields"] tap];
    [tester tapViewWithAccessibilityLabel:@"fisrtTF"];
    [tester enterTextIntoCurrentFirstResponder:@"Good"];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"secondTF"];
    [tester waitForTimeInterval:2];
    NSArray *chngEventArray = [MockEventQueue.sharedQueue eventsFor:@"chng"];
    //NSLog(@"chng事件：%@",chngEventArray);
    if(chngEventArray.count>0)
    {
        //判断单击列表是否正确
        NSDictionary *chevent=[chngEventArray objectAtIndex:chngEventArray.count-1];
        //检测发送事件情况
        NSDictionary *chngchr=[NoburPoMeaProCheck ChngEventCheck:chevent];
        NSLog(@"Check result:%@",chngchr);
        XCTAssertEqualObjects(chngchr[@"KeysCheck"][@"chres"], @"Passed");
        NSArray *incr=chngchr[@"ProCheck"][@"incre"];
        XCTAssertEqual(incr.count, 1);
        XCTAssertEqualObjects(chngchr[@"ProCheck"][@"incre"][0],@"index");
        NSLog(@"TextField输出内容，检测chng事件测试通过---Passed！");
    }
    else
    {
        NSLog(@"TextField输出内容，检测chng事件,测试不通过！没有发送chng事件");
        XCTAssertEqual(0, 1);
    }

}

//-(void)test2SearchBar{
//    /**
//     function:SearchBar输出内容，检测chng事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//
//    //受第一个测试用例的影响，点击两次以保证恢复到正确的页面
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"chng请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"SearchBarTest"];
//    [tester enterTextIntoCurrentFirstResponder:@"Good"];
//    [tester tapViewWithAccessibilityLabel:@"Search"];
//    [tester waitForTimeInterval:2];
//    NSArray *chngEventArray = [MockEventQueue.sharedQueue eventsFor:@"chng"];
//    //NSLog(@"chng事件：%@",chngEventArray);
//    if(chngEventArray.count>0)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[chngEventArray objectAtIndex:chngEventArray.count-1];
//        //检测发送事件情况
//        NSDictionary *chngchr=[NoburPoMeaProCheck ChngEventCheck:chevent];
//        //NSLog(@"Check result:%@",chngchr);
//        XCTAssertEqualObjects(chngchr[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqualObjects(chngchr[@"ProCheck"][@"chres"], @"same");
//         NSLog(@"SearchBar输出内容，检测chng事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"SearchBar输出内容，检测chng事件,测试不通过！没有发送chng事件");
//        XCTAssertEqual(0, 1);
//    }
//}

//-(void)test3UserNamePsd{
//    /**
//     function:用户名和密码，检测chng事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"chng请求"] tap];
//    [tester tapViewWithAccessibilityLabel:@"UserName"];
//    [tester enterTextIntoCurrentFirstResponder:@"SXF"];
//    [tester tapViewWithAccessibilityLabel:@"PassWord"];
//    [tester enterTextIntoCurrentFirstResponder:@"123426"];
//    [tester waitForTimeInterval:2];
//    NSArray *chngEventArray = [MockEventQueue.sharedQueue eventsFor:@"chng"];
//    //NSLog(@"chng事件：%@",chngEventArray);
//    if(chngEventArray.count>0)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[chngEventArray objectAtIndex:chngEventArray.count-1];
//        //检测发送事件情况
//        NSDictionary *chngchr=[NoburPoMeaProCheck ChngEventCheck:chevent];
//        //NSLog(@"Check result:%@",chngchr);
//        NSArray *empty=chngchr[@"KeysCheck"][@"EmptyKeys"];
//        XCTAssertEqual(empty.count, 1);
//        //TextField不采集输入的内容
//        XCTAssertEqualObjects(chngchr[@"KeysCheck"][@"EmptyKeys"][0], @"textValue");
//        XCTAssertEqualObjects(chngchr[@"ProCheck"][@"chres"], @"same");
//        NSLog(@"用户名和密码，检测chng事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"用户名和密码，检测chng事件,测试不通过！没有发送chng事件");
//        XCTAssertEqual(0, 1);
//    }
//}
//-(void)test4TextView{
//    /**
//     function:textview操作，检测chng事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //单击两次返回列表页
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [[viewTester usingLabel:@"NotUIControl"] tap];
//    [tester tapViewWithAccessibilityLabel:@"TextChgTest"];
//    [tester enterTextIntoCurrentFirstResponder:@"This is a test content!"];
//    [tester waitForTimeInterval:1];
//    [tester tapViewWithAccessibilityLabel:@"return"];
//    [tester waitForTimeInterval:2];
//    NSArray *chngEventArray = [MockEventQueue.sharedQueue eventsFor:@"chng"];
//    //NSLog(@"chng事件：%@",chngEventArray);
//    if(chngEventArray.count>0)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[chngEventArray objectAtIndex:chngEventArray.count-1];
//        //检测发送事件情况
//        NSDictionary *chngchr=[NoburPoMeaProCheck ChngEventCheck:chevent];
//        //NSLog(@"Check result:%@",chngchr);
//        NSArray *empty=chngchr[@"KeysCheck"][@"EmptyKeys"];
//        XCTAssertEqual(empty.count, 1);
//        XCTAssertEqualObjects(chngchr[@"KeysCheck"][@"EmptyKeys"][0], @"textValue");
//        XCTAssertEqualObjects(chngchr[@"ProCheck"][@"chres"], @"same");
//        NSLog(@"textview操作，检测chng事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"textview操作，检测chng事件,测试不通过！没有发送chng事件");
//        XCTAssertEqual(0, 1);
//    }
//}

-(void)test2DataPicker{
    /**
     function:日期控件操作，不发送chng事件
     **/
    [[viewTester usingLabel:@"协议/接口"] tap];
    //单击两次返回列表页
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"chng请求"] tap];
    [MockEventQueue.sharedQueue cleanQueue];
    NSArray *date = @[@"June", @"10", @"2019"];
    [tester selectDatePickerValue:date];
    [tester waitForTimeInterval:2];
    NSArray *chngEventArray = [MockEventQueue.sharedQueue eventsFor:@"chng"];
    //NSLog(@"chng事件：%@",chngEventArray);
    if (chngEventArray == NULL)
    {
        XCTAssertEqual(1, 1);
        NSLog(@"日期控件操作，不发送chng事件测试通过---Passed！");
    }
    else
    {
        NSLog(@"日期控件操作，不发送chng事件,测试不通过！发送了chng事件");
        XCTAssertEqual(0, 1);
    }
}
@end
