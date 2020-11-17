//
//  GDPRTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/19.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GDPRTest.h"

#import "GrowingTracker.h"
#import "MockEventQueue.h"

@implementation GDPRTest

- (void)test1DisableDataCollect {
    /**
     function:设置GDPR ， 不采集数据
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setDataCollectionEnabled:NO];
    [MockEventQueue.sharedQueue cleanQueue];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    NSLog(@"Click 事件：%@", clickEventArray);
    if (clickEventArray.count == 0) {
        //判断单击列表是否正确
        XCTAssertEqual(1, 1);
        NSLog(@"设置GDPR生效,不采取数据，测试通过--passed!");
    } else {
        NSLog(@"设置GDPR生效,测试失败，数据采集：%@", clickEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test2EnableDataCollect {
    /**
     function:设置GDPR失效
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setDataCollectionEnabled:NO];
    [MockEventQueue.sharedQueue cleanQueue];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    XCTAssertEqual(clickEventArray.count, 0);
    // GDPR失效
    [[GrowingTracker sharedInstance] setDataCollectionEnabled:YES];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"CLICK请求"] tap];
    [[viewTester usingLabel:@"send click event"] tap];

    NSArray *clickEventArray1 = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    NSLog(@"Click 事件：%@", clickEventArray1);
    if (clickEventArray1.count >= 1) {
        //判断单击列表是否正确
        NSDictionary *chevent = [clickEventArray1 objectAtIndex:clickEventArray1.count - 1];
        NSLog(@"###%@", chevent);
        XCTAssertEqual(1, 1);
        NSLog(@"设置GDPR失效,采取数据，测试通过--passed!");
    } else {
        NSLog(@"设置GDPR失效,测试失败，数据采集：%@", clickEventArray1);
        XCTAssertEqual(1, 0);
    }
}
@end
