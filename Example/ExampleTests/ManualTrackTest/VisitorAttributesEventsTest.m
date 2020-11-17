//
//  visitorAttributesEventsTest.m
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
    [[GrowingTracker sharedInstance] setLoginUserId:@"test"];
    [[viewTester usingLabel:@"UI界面"] tap];

}

- (void)test1VstrNormal {
    /**
     function:vstr正常情况
     **/
    [tester waitForTimeInterval:1];
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingTracker sharedInstance] setVisitorAttributes:@{@"var1" : @"good", @"var2" : @"excell"}];
    NSArray *visitorAttributesEventArray = [MockEventQueue.sharedQueue eventsFor:@"VISITOR_ATTRIBUTES"];
    NSLog(@"VISITOR_ATTRIBUTES 事件：%@", visitorAttributesEventArray);
    if (visitorAttributesEventArray.count >= 1) {
        NSDictionary *epvarchr = [visitorAttributesEventArray objectAtIndex:visitorAttributesEventArray.count - 1];
        XCTAssertEqualObjects(epvarchr[@"eventType"], @"VISITOR_ATTRIBUTES");
        XCTAssertTrue([ManualTrackHelper CheckContainsKey:epvarchr:@"attributes"]);
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"var1"], @"good");
        XCTAssertEqualObjects(epvarchr[@"attributes"][@"var2"], @"excell");

        NSDictionary *chres = [ManualTrackHelper visitorAttributesEventCheck:epvarchr];
        XCTAssertEqualObjects(chres[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(chres[@"ProCheck"][@"chres"], @"same");
        NSLog(@"CONVERSION_VARIABLES事件，vstr正常情况测试通过-----passed");
    } else {
        NSLog(@"CONVERSION_VARIABLES事件，vstr正常情况测试失败:%@", visitorAttributesEventArray);
        XCTAssertEqual(1, 0);
    }
}

@end
