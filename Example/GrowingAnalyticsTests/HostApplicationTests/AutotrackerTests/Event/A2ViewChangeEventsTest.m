//
//  ChgEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/28.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <KIF/KIF.h>

#import "GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "ManualTrackHelper.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"

@interface A2ViewChangeEventsTest : KIFTestCase

@end

@implementation A2ViewChangeEventsTest

+ (void)setUp {
    // userId userKey
    [GrowingAutotracker.sharedInstance setLoginUserId:@"xctest_userId" userKey:@"xctest_userKey"];
    // latitude longitude
    [GrowingAutotracker.sharedInstance setLocation:30.12345 longitude:31.123456];
}

- (void)setUp {
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)test01TextFields {
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"Text Fields"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"fisrtTF"] tap];
    [[viewTester usingFirstResponder] enterText:@"Good"];
    [[viewTester usingFirstResponder].view resignFirstResponder];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
    XCTAssertEqual(events.count, 1);
    
    GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewChange);
    XCTAssertTrue([ManualTrackHelper viewChangeEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    [[viewTester usingLabel:@"UI界面"] tap];
}

- (void)test02TextFieldsIgnore {
    [[viewTester usingLabel:@"UI界面"] tap];
    [[viewTester usingLabel:@"Text Fields"] tap];
    [viewTester waitForAnimationsToFinish];
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"fisrtTF"];
    {
        actor.view.growingViewIgnorePolicy = GrowingIgnoreSelf;
        [actor tap];
        [[viewTester usingFirstResponder] enterText:@"Bad"];
        [[viewTester usingFirstResponder].view resignFirstResponder];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 0);
    }
    
    {
        actor.view.growingViewIgnorePolicy = GrowingIgnoreNone;
        [actor tap];
        [[viewTester usingFirstResponder] clearText];
        [[viewTester usingFirstResponder].view resignFirstResponder];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 1);
        
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewChange);
        XCTAssertTrue([ManualTrackHelper viewChangeEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    }

    [[viewTester usingLabel:@"UI界面"] tap];
}

- (void)test03DataPicker {
    [[viewTester usingLabel:@"协议/接口"] tap];
    [[viewTester usingLabel:@"VIEW_CHANGE请求"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"dataPickerOper"] tap];
    
    NSArray *date = @[@"June", @"10", @"2019"];
    [viewTester selectDatePickerValue:date];
    [viewTester tapScreenAtPoint:CGPointMake(100, 100)];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
    XCTAssertEqual(events.count, 0);
    
    [[viewTester usingLabel:@"协议/接口"] tap];
}

@end
