//
//  GetEnableLogTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/19.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GetEnableLogTest.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"

@implementation GetEnableLogTest
static NSString * const kGrowingProjectId = @"0a1b4118dd954ec3bcc69da5138bdb96";

-(void)test1GetEnableLog{
    /**
     Function:获取显示日志状态
     **/
    //    [[viewTester usingLabel:@"接口"] tap];
    //    [[viewTester usingLabel:@"+ getEnableLog(日志开关状态)"] tap];
    //    [[viewTester usingLabel:@"获取日志状态"] tap];
    // Config GrowingIO
    GrowingConfiguration *configuration = [[GrowingConfiguration alloc] initWithProjectId:kGrowingProjectId
                                                                            launchOptions:nil];
    [configuration setLogEnabled:YES];
    bool *log = [configuration logEnabled];
    NSLog(@"日志打开状态，%@",log?@"YES":@"NO");
    NSString *logab = log ? @"1" : @"0";
    [tester waitForTimeInterval:1];
    //   UILabel *logab=[tester waitForViewWithAccessibilityLabel:@"ShowLogDeInfo"];
    //NSLog(@"****获取发送时间间隔****：%@",slab.text);
    if(![logab isEqualToString:@""])
    {
        XCTAssertEqualObjects(logab, @"1");
        NSLog(@"获取显示日志状态，测试通过---passed");
    }
    else
    {
        NSLog(@"获取显示日志状态，测试失败，获取时间错误：%@",logab);
        XCTAssertEqual(1, 0);
    }
    
    
}
@end
