//
//  VstEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "VisitorEventsTest.h"
#import "MockEventQueue.h"
#import "GrowingTestHelper.h"
#import "NoburPoMeaProCheck.h"
#import "GrowingTracker.h"

@implementation VisitorEventsTest

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
    NSArray *vstEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISIT"];
    //NSLog(@"VST事件：%@",vstEventArray);
    if (vstEventArray.count>0)
    {
        NSDictionary *vstchr=[vstEventArray objectAtIndex:vstEventArray.count-1];
        NSLog(@"Check Result:%@",vstchr);
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

@end
