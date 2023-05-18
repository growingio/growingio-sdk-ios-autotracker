//
//  clickEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/24.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import <KIF/KIF.h>

#import "GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "ManualTrackHelper.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"

@interface A1ViewClickEventsTest : KIFTestCase

@end

@implementation A1ViewClickEventsTest

+ (void)setUp {
    // userId userKey
    [GrowingAutotracker.sharedInstance setLoginUserId:@"xctest_userId" userKey:@"xctest_userKey"];
    // latitude longitude
    [GrowingAutotracker.sharedInstance setLocation:30.12345 longitude:31.123456];
}

- (void)setUp {
    [[viewTester usingLabel:@"UI界面"] tap];
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    [[viewTester usingLabel:@"UI界面"] tap];
}

- (void)test01AlertButtonClick {
    // 对话框按钮点击，检测click事件
    [[viewTester usingLabel:@"AttributeLabel"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"ShowAlert"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"取消"] tap];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertGreaterThanOrEqual(events.count, 2);
    
    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 1];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"path"],
                              @"/UITabBarController/UINavigationController[1]/GIOLabelAttributeViewController[0]");
        XCTAssertEqualObjects(dic[@"textValue"], @"取消");
        XCTAssertEqualObjects(dic[@"xpath"],
            @"/Page/UIAlertController/UIView[0]/_UIAlertControllerInterfaceActionGroupView[0]/UIView[0]/"
            @"_UIInterfaceActionRepresentationsSequenceView[0]/_UIInterfaceActionSeparatableSequenceView[0]/"
            @"UIStackView[0]/_UIInterfaceActionCustomViewRepresentationView[1]/Button[0]");
    }

    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 2];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"path"],
                              @"/UITabBarController/UINavigationController[1]/GIOLabelAttributeViewController[0]");
        XCTAssertEqualObjects(dic[@"textValue"], @"ShowAlert");
        XCTAssertEqualObjects(dic[@"xpath"], @"/Page/UIButton[3]");
    }
}

- (void)test02ClickDoNotTrack {
    [[viewTester usingLabel:@"AttributeLabel"] tap];
    [viewTester waitForAnimationsToFinish];
    
    [MockEventQueue.sharedQueue cleanQueue];
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"GIODontTrackBtn"];
    {
        actor.view.growingViewIgnorePolicy = GrowingIgnoreSelf;
        [actor tap];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 0);
    }
    
    [MockEventQueue.sharedQueue cleanQueue];
    
    {
        actor.view.growingViewIgnorePolicy = GrowingIgnoreNone;
        [actor tap];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 1);
        
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    }
    
    [MockEventQueue.sharedQueue cleanQueue];
    
    {
        [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:NO];
        [actor tap];
        
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 0);
        
        [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:YES];
    }
}

- (void)test03ButtonWithImageViewClick {
    // 单击ButtonWithImageView，检测click事件
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"Food"] tap];
    [[viewTester usingLabel:@"好的"] tap];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 3);
    
    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 2];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"textValue"], @"Food");
        XCTAssertEqualObjects(dic[@"xpath"], @"/Page/UIView[0]/UIButton[0]");
    }
}

- (void)test04UIViewButtonClick {
    // 单击UIViewButton，检测click事件
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"Fire"] tap];
    [[viewTester usingLabel:@"好的"] tap];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 3);

    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 2];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"textValue"], @"Fire");
        XCTAssertEqualObjects(dic[@"xpath"], @"/Page/UIView[0]/UIButton[1]");
    }
}

- (void)test05UISegmentedControlClick {
    // 单击UISegmentedControl，检测click事件
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"SecondSegment"] tap];
    [[viewTester usingLabel:@"ThirdSegment"] tap];
    [viewTester waitForAnimationsToFinish];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 3);

    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 1];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"textValue"], @"Third");
        XCTAssertEqualObjects(dic[@"xpath"], @"/Page/UISegmentedControl[0]/UISegment[-]");
        XCTAssertEqualObjects(dic[@"index"], @(2));
    }
}

- (void)test06ClickCustomContent {
    // 单击自定义content的UISegmentedControl，检测textValue
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [viewTester waitForAnimationsToFinish];
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"ThirdSegment"];
    {
        actor.view.growingViewCustomContent = @"Four";
        [actor tap];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 1);
        
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"textValue"], @"Four");
        XCTAssertEqualObjects(dic[@"xpath"], @"/Page/UISegmentedControl[0]/UISegment[-]");
        XCTAssertEqualObjects(dic[@"index"], @(2));
    }
}

@end
