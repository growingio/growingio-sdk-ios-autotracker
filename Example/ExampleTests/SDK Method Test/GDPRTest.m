//
//  GDPRTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/19.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GDPRTest.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"

@implementation GDPRTest

-(void) test1DisableDataCollect{
    /**
     function:设置GDPR ， 不采集数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"接口"] tap];
//    [[viewTester usingLabel:@"+ GDPR(数据保护)"] tap];
//    [[viewTester usingLabel:@"GDPR生效"] tap];
    [Growing setDataTrackEnabled:NO];
    [MockEventQueue.sharedQueue cleanQueue];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    NSLog(@"Clck 事件：%@",clckEventArray);
    if(clckEventArray.count==0)
    {
        //判断单击列表是否正确
        XCTAssertEqual(1, 1);
        NSLog(@"设置GDPR生效,不采取数据，测试通过--passed!");
    }
    else
    {
        NSLog(@"设置GDPR生效,测试失败，数据采集：%@",clckEventArray);
        XCTAssertEqual(1, 0);
    }
}


-(void) test2EnableDataCollect{
    /**
     function:设置GDPR失效
     **/
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"接口"] tap];
//    [[viewTester usingLabel:@"+ GDPR(数据保护)"] tap];
//    //GDPR生效
//    [[viewTester usingLabel:@"GDPR生效"] tap];
    [Growing setDataTrackEnabled:NO];
    [MockEventQueue.sharedQueue cleanQueue];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    XCTAssertEqual(clckEventArray.count,0);
    //GDPR失效
    [Growing setDataTrackEnabled:YES];
//    [[viewTester usingLabel:@"GDPR失效"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"clck请求"] tap];
    [[viewTester usingLabel:@"send clck event"] tap];

    NSArray *clckEventArray1 = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    NSLog(@"Clck 事件：%@",clckEventArray1);
    if(clckEventArray1.count>=1)
    {
        //判断单击列表是否正确
        NSDictionary *chevent=[clckEventArray1 objectAtIndex:clckEventArray1.count-1];
        NSLog(@"###%@",chevent);
 //       XCTAssertEqualObjects(chevent[@"textValue"], @"send clck event");
        XCTAssertEqual(1, 1);
        NSLog(@"设置GDPR失效,采取数据，测试通过--passed!");
    }
    else
    {
        NSLog(@"设置GDPR失效,测试失败，数据采集：%@",clckEventArray1);
        XCTAssertEqual(1, 0);
    }
}
@end
