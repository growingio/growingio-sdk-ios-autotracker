//
//  ChgEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/28.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "ViewChangeEventsTest.h"
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
#import "GrowingTracker.h"
@implementation ViewChangeEventsTest


- (void)setUp{
    //设置userid,确保cs1字段不空
    [[GrowingTracker sharedInstance] setLoginUserId:@"test"];

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
    NSArray *chngEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CHANGE"];
    if (chngEventArray.count>0) {
        //判断单击列表是否正确
        NSDictionary *chevent=[chngEventArray objectAtIndex:chngEventArray.count-1];
        //检测发送事件情况
        NSDictionary *chngchr=[NoburPoMeaProCheck viewChangeEventCheck:chevent];
        NSLog(@"Check result:%@",chngchr);
        XCTAssertEqualObjects(chngchr[@"KeysCheck"][@"chres"], @"Passed");
//        NSArray *incr=chngchr[@"ProCheck"][@"incre"];
//        XCTAssertEqual(incr.count, 1);
//        XCTAssertEqualObjects(chngchr[@"ProCheck"][@"incre"][0],@"index");
        NSLog(@"TextField输出内容，检测chng事件测试通过---Passed！");
    } else {
        NSLog(@"TextField输出内容，检测chng事件,测试不通过！没有发送chng事件");
        XCTAssertEqual(0, 1);
    }

}

-(void)test2DataPicker{
    /**
     function:日期控件操作，不发送chng事件
     **/
    [[viewTester usingLabel:@"协议/接口"] tap];
    //单击两次返回列表页
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"VIEW_CHANGE请求"] tap];
    [MockEventQueue.sharedQueue cleanQueue];
    NSArray *date = @[@"June", @"10", @"2019"];
    [tester selectDatePickerValue:date];
    [tester waitForTimeInterval:2];
    NSArray *chngEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CHANGE"];
    if (chngEventArray == NULL) {
        XCTAssertEqual(1, 1);
        NSLog(@"日期控件操作，不发送chng事件测试通过---Passed！");
    } else {
        NSLog(@"日期控件操作，不发送chng事件,测试不通过！发送了chng事件");
        XCTAssertEqual(0, 1);
    }
}
@end
