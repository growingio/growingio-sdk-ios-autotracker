//
//  VstrEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/7/12.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//  Function:vstr事件的测试
//

#import "VisitorAttributesEventsTest.h"

#import "GrowingTracker.h"
#import "LogOperHelper.h"
#import "ManualTrackHelper.h"
#import "MockEventQueue.h"

@implementation VisitorAttributesEventsTest

- (void)setUp {
    //设置userid,确保cs1字段不空
    [Growing setLoginUserId:@"test"];
}

- (void)test1VstrNormal {
    /**
     function:vstr正常情况
     **/
    [tester waitForTimeInterval:1];
    [MockEventQueue.sharedQueue cleanQueue];
    [Growing setVisitorAttributes:@{@"var1" : @"good", @"var2" : @"excell"}];
    NSArray *vstrEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISITOR_ATTRIBUTES"];
    NSLog(@"Vstr事件：%@", vstrEventArray);
    if (vstrEventArray.count >= 1) {
        NSDictionary *epvarchr = [vstrEventArray objectAtIndex:vstrEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"VISITOR_ATTRIBUTES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"var1"], @"good");
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"var2"], @"excell");

        NSDictionary *chres = [ManualTrackHelper visitorEventCheck:epvarchr];
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"EVar事件，vstr正常情况测试通过-----passed");
    } else {
        NSLog(@"EVar事件，vstr正常情况测试失败:%@", vstrEventArray);
        XCTAssertEqual(1, 0);
    }
}

@end
