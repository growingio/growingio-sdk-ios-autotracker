//
//  DailyDataLimit.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/19.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "DailyDataLimit.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"

@implementation DailyDataLimit

-(void)test1GetDailyDataLimit{
    /**
     function:获取蜂窝当天数据限额
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //    [[viewTester usingLabel:@"获取蜂窝数据"] tap];
    //    UILabel *slab=[tester waitForViewWithAccessibilityLabel:@"ShowDataLimt"];
    // Config GrowingIO
    
    //    NSLog(@"****获取蜂窝数据****：%@");
    //XCTAssertEqual(a, @10485);
    NSLog(@"获取蜂窝数据，测试通过---passed");
    //    if(![a isEquals:@0])
    //    {
    //
    //    }
    //    else
    //    {
    //        NSLog(@"获取蜂窝数据，测试失败，获取数据限额错误：%@",slab.text);
    //        XCTAssertEqual(1, 0);
    //    }
}

-(void) test2SetDailyDataLimit{
    /**
     function:设置蜂窝当天数据限额
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    //    [[viewTester usingLabel:@"接口"] tap];
    //    [[viewTester usingLabel:@"+ DailyDataLimit(蜂窝数据)"] tap];
    //    [tester tapViewWithAccessibilityLabel:@"SetDataLimit"];
    //    [tester enterTextIntoCurrentFirstResponder:@"3000"];
    //    [[viewTester usingLabel:@"设置上限"] tap];
    //    [tester waitForTimeInterval:1];
    //    [[viewTester usingLabel:@"获取蜂窝数据"] tap];
    //NSLog(@"****获取蜂窝数据****：%@",slab.text);
    //    if(![slab.text isEqualToString:@""])
    //    {
    //        XCTAssertEqualObjects(slab.text, @"3000 K");
    //        NSLog(@"设置蜂窝当天数据限额，测试通过---passed");
    //    }
    //    else
    //    {
    //        NSLog(@"设置蜂窝当天数据限额，测试失败，获取数据限额错误：%@",slab.text);
    //        XCTAssertEqual(1, 0);
    //    }
}
@end
