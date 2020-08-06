//
//  GetIDsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/8/21.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import "GetIDsTest.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"

@implementation GetIDsTest

-(void)test1GetDeviceID{
    /*
     Function:测试getDeviceId
     */
    [MockEventQueue.sharedQueue cleanQueue];

    NSString *slab = [Growing getDeviceId];
    [tester waitForTimeInterval:1];
//    UILabel *slab=[tester waitForViewWithAccessibilityLabel:@"ShowDevId"];
    NSLog(@"****获取设备ID****：%@",slab);
    if(![slab isEqualToString:@""])
    {
        XCTAssertEqual(1, 1);
        NSLog(@"测试getDeviceId，测试通过---passed");
    }
    else
    {
        NSLog(@"测试getDeviceId，测试失败，获取设备ID：%@",slab);
        XCTAssertEqual(1, 0);
    }
    
    
}

-(void)test2GetUID{
    /*
     Function:测试getVisitUserId
     */
    [MockEventQueue.sharedQueue cleanQueue];
    [tester waitForTimeInterval:1];
//    UILabel *slab=[tester waitForViewWithAccessibilityLabel:@"ShowUid"];
    NSString *slab = [Growing getDeviceId];
    NSLog(@"****获取当前UID****：%@",slab);
    if(![slab isEqualToString:@""])
    {
        XCTAssertEqual(1, 1);
        NSLog(@"测试getVisitUserId，测试通过---passed");
    }
    else
    {
        NSLog(@"测试getVisitUserId，测试失败，获取当前UID：%@",slab);
        XCTAssertEqual(1, 0);
    }
}

-(void)test3GetSID{
    /*
     Function:测试getSessionId
     */
    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"接口"] tap];
//    [[viewTester usingLabel:@"+ FlushInterval(发送数据间隔)"] tap];
//    [[viewTester usingLabel:@"获取当前访问ID"] tap];
//    [tester waitForTimeInterval:5];
//    UILabel *slab=[tester waitForViewWithAccessibilityLabel:@"ShowVistId"];
    NSString *slab = [Growing getSessionId];
    NSLog(@"****获取当前访问ID****：%@",slab);
    if(![slab isEqualToString:@""])
    {
        XCTAssertEqual(1, 1);
        NSLog(@"测试getSessionId，测试通过---passed");
    }
    else
    {
        NSLog(@"测试getSessionId，测试失败，获取当前访问ID：%@",slab);
        XCTAssertEqual(1, 0);
    }
}
@end
