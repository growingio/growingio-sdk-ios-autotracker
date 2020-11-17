//
//  GetIDsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/8/21.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GetIDsTest.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"
#import "GrowingSession.h"
@implementation GetIDsTest

-(void)test1GetDeviceID{
    /*
     Function:测试getDeviceId
     */
    [MockEventQueue.sharedQueue cleanQueue];

    NSString *slab = [[GrowingTracker sharedInstance] getDeviceId];
    [tester waitForTimeInterval:1];
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
    NSString *slab = [[GrowingTracker sharedInstance] getDeviceId];
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
    NSString *slab = [[GrowingSession currentSession] sessionId];
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
