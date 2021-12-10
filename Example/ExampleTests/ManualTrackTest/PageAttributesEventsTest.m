//
//  PvarEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/11.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  function:Pvar事件测试用例集

#import "PageAttributesEventsTest.h"

#import "LogOperHelper.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"
#import "GrowingAutotrackEventType.h"

@implementation PageAttributesEventsTest

- (void)setUp {
    [[viewTester usingLabel:@"协议/接口"] tap];
}

- (void)test1PvarNormal {
    /**
     function:setPageVariable正常情况
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"PAGE_ATTRIBUTES请求"] tap];
    NSArray *pvarEventArray = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypePageAttributes];
    if (pvarEventArray.count >= 1) {
        NSDictionary *pvarchr = [pvarEventArray objectAtIndex:pvarEventArray.count - 1];
        XCTAssertEqualObjects(pvarchr[@"eventType"], GrowingEventTypePageAttributes);
        TestSuccess(@"PAGE_ATTRIBUTES事件， 测试通过-----passed");
    } else {
        TestFailed(@"PAGE_ATTRIBUTES事件， 测试失败:%@", pvarEventArray);
        XCTAssertEqual(1, 0);
    }
}
@end
