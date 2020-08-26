//
//  TrackViewTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/8/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "TrackViewTest.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"

@implementation TrackViewTest

-(void) test1TackviewTrue{
    /**
     function:测试enableAllWebViews
     **/
//    [[viewTester usingLabel:@"接口"] tap];
//    [[viewTester usingLabel:@"接口"] tap];
//    [[viewTester usingLabel:@"+ GDPR(数据保护)"] tap];
//    [[viewTester usingLabel:@"采集"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"获取状态"] tap];
//    [tester waitForTimeInterval:1];
//    UILabel *slab=[tester waitForViewWithAccessibilityLabel:@"trackviewstatus"];
    [Growing setDataTrackEnabled:YES];
 //   [Growing isTrackingWebView];
    //NSLog(@"****获取当前trackingWebView****：%@",slab.text);
//    if(![slab.text isEqualToString:@""])
//    {
//        XCTAssertEqualObjects(slab.text, @"采集中...");
//        NSLog(@"测试enableAllWebViews，测试通过---passed");
//    }
//    else
//    {
//        NSLog(@"测试enableAllWebViews，测试失败，enableAllWebView状态：%@",slab.text);
//        XCTAssertEqual(1, 0);
//    }
}


-(void) test2TackviewFalse{
    /**
     function:测试enableAllWebViews
     **/
//    [[viewTester usingLabel:@"接口"] tap];
//    [[viewTester usingLabel:@"+ GDPR(数据保护)"] tap];
//    [[viewTester usingLabel:@"不采集"] tap];
//    [MockEventQueue.sharedQueue cleanQueue];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"获取状态"] tap];
//    [tester waitForTimeInterval:1];
//    UILabel *slab=[tester waitForViewWithAccessibilityLabel:@"trackviewstatus"];
    [Growing setDataTrackEnabled:NO];

    //NSLog(@"****获取当前trackingWebView****：%@",slab.text);
//    if(![slab.text isEqualToString:@""])
//    {
//        XCTAssertEqualObjects(slab.text, @"不采集！！！");
//        NSLog(@"测试enableAllWebView为False，测试通过---passed");
//    }
//    else
//    {
//        NSLog(@"测试enableAllWebViews为False，测试失败，enableAllWebView状态：%@",slab.text);
//        XCTAssertEqual(1, 0);
//    }
}

@end
