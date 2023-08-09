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
#import "GrowingAutotrackerCore/GrowingNode/GrowingNodeHelper.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"

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

- (void)checkWebCirclePathWithView:(UIView *)view xpath:(NSString *)xpathForView xcontent:(NSString *)xcontentForView originxcontent:(NSString *)originxcontentForView {
    // 检查圈选的计算逻辑得出的xpath、xcontent是否正确
    GrowingPage *page = [[GrowingPageManager sharedInstance] findPageByView:view];
    NSDictionary *pathInfo = page.pathInfo;
    NSString *pagexpath = pathInfo[@"xpath"];
    NSString *pagexcontent = pathInfo[@"xcontent"];
    [GrowingNodeHelper recalculateXpath:view block:^(NSString * _Nonnull xpath, NSString * _Nonnull xcontent, NSString * _Nonnull originxcontent) {
        xpath = [NSString stringWithFormat:@"%@/%@", pagexpath, xpath];
        xcontent = [NSString stringWithFormat:@"%@/%@", pagexcontent, xcontent];
        originxcontent = [NSString stringWithFormat:@"%@/%@", pagexcontent, originxcontent];
        XCTAssertEqualObjects(xpathForView, xpath);
        XCTAssertEqualObjects(xcontentForView, xcontent);
        XCTAssertEqualObjects(originxcontentForView, originxcontent);
    }];
}

- (void)test01AlertButtonClick {
    // 对话框按钮点击，检测click事件
    [[viewTester usingLabel:@"AttributeLabel"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"ShowAlert"] tap];
    [viewTester waitForAnimationsToFinish];
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"取消"];
    NSString *xpathForView = @"/UITabBarController/UINavigationController/GIOLabelAttributeViewController/UIView/"
    @"_UIAlertControllerInterfaceActionGroupView/UIView/_UIInterfaceActionRepresentationsSequenceView/_UIInterfac"
    @"eActionSeparatableSequenceView/UIStackView/_UIInterfaceActionCustomViewRepresentationView/Button";
    NSString *xcontentForView = @"/0/1/0/0/0/0/0/0/0/1/0";
    NSString *originxcontentForView = @"/0/1/0/0/0/0/0/0/0/1/0";
    [self checkWebCirclePathWithView:actor.view xpath:xpathForView xcontent:xcontentForView originxcontent:originxcontentForView];
    [actor tap];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertGreaterThanOrEqual(events.count, 2);
    
    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 1];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"path"], @"");
        XCTAssertEqualObjects(dic[@"textValue"], @"取消");
        XCTAssertEqualObjects(dic[@"xpath"], xpathForView);
        XCTAssertEqualObjects(dic[@"xcontent"], xcontentForView);
    }

    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 2];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"path"], @"");
        XCTAssertEqualObjects(dic[@"textValue"], @"ShowAlert");
        XCTAssertEqualObjects(dic[@"xpath"], @"/UITabBarController/UINavigationController/GIOLabelAttributeViewController/UIView/UIButton");
        XCTAssertEqualObjects(dic[@"xcontent"], @"/0/1/0/0/3");
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
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"Food"];
    NSString *xpathForView = @"/UITabBarController/UINavigationController/GIOSimpleUIElemtsViewController/UIView/UIView/UIButton";
    NSString *xcontentForView = @"/0/1/0/0/0/0";
    NSString *originxcontentForView = @"/0/1/0/0/0/0";
    [self checkWebCirclePathWithView:actor.view xpath:xpathForView xcontent:xcontentForView originxcontent:originxcontentForView];
    [actor tap];
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
        XCTAssertEqualObjects(dic[@"xpath"], xpathForView);
        XCTAssertEqualObjects(dic[@"xcontent"], xcontentForView);
    }
}

- (void)test04UIViewButtonClick {
    // 单击UIViewButton，检测click事件
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [viewTester waitForAnimationsToFinish];
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"Fire"];
    NSString *xpathForView = @"/UITabBarController/UINavigationController/GIOSimpleUIElemtsViewController/UIView/UIView/UIButton";
    NSString *xcontentForView = @"/0/1/0/0/0/1";
    NSString *originxcontentForView = @"/0/1/0/0/0/1";
    [self checkWebCirclePathWithView:actor.view xpath:xpathForView xcontent:xcontentForView originxcontent:originxcontentForView];
    [actor tap];
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
        XCTAssertEqualObjects(dic[@"xpath"], xpathForView);
        XCTAssertEqualObjects(dic[@"xcontent"], xcontentForView);
    }
}

- (void)test05UISegmentedControlClick {
    // 单击UISegmentedControl，检测click事件
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [viewTester waitForAnimationsToFinish];
    [[viewTester usingLabel:@"SecondSegment"] tap];
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"ThirdSegment"];
    NSString *xpathForView = @"/UITabBarController/UINavigationController/GIOSimpleUIElemtsViewController/UIView/UISegmentedControl/UISegment";
    NSString *xcontentForView = @"/0/1/0/0/0/-";
    NSString *originxcontentForView = @"/0/1/0/0/0/2";
    [self checkWebCirclePathWithView:actor.view xpath:xpathForView xcontent:xcontentForView originxcontent:originxcontentForView];
    [actor tap];
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
        XCTAssertEqualObjects(dic[@"xpath"], xpathForView);
        XCTAssertEqualObjects(dic[@"index"], @(2));
        XCTAssertEqualObjects(dic[@"xcontent"], xcontentForView);
    }
}

- (void)test06ClickCustomContent {
    // 单击自定义content的UISegmentedControl，检测textValue
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [viewTester waitForAnimationsToFinish];
    
    [MockEventQueue.sharedQueue cleanQueue];

    KIFUIViewTestActor *actor = [viewTester usingLabel:@"Fire"];
    {
        // Fire -> Water
        actor.view.growingViewCustomContent = @"Water";
        [actor tap];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
        XCTAssertEqual(events.count, 1);
        
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"textValue"], @"Water");
        XCTAssertEqualObjects(dic[@"xpath"], @"/UITabBarController/UINavigationController/GIOSimpleUIElemtsViewController/UIView/UIView/UIButton");
        XCTAssertEqualObjects(dic[@"xcontent"], @"/0/1/0/0/0/1");
    }
    
    [[viewTester usingLabel:@"好的"] tap];
}

- (void)test07UITableViewHeaderFooterViewButtonClick {
    // 单击UITableViewHeaderFooterView上的Button，检测click事件
    [[viewTester usingLabel:@"协议/接口"] tap];
    [viewTester waitForAnimationsToFinish];
    
    KIFUIViewTestActor *actor = [viewTester usingLabel:@"header1"];
    NSString *xpathForView = @"/UITabBarController/UINavigationController/GIOMeasurementProtocolTableViewController/UITableView/UITableViewHeaderFooterView/UIButton";
    NSString *xcontentForView = @"/0/0/0/0/1/0";
    NSString *originxcontentForView = @"/0/0/0/0/1/0";
    [self checkWebCirclePathWithView:actor.view xpath:xpathForView xcontent:xcontentForView originxcontent:originxcontentForView];
    [actor tap];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 2);

    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)events[events.count - 1];
        NSDictionary *dic = event.toDictionary;
        XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
        XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
        XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
        
        XCTAssertEqualObjects(dic[@"textValue"], @"header1");
        XCTAssertEqualObjects(dic[@"xpath"], xpathForView);
        XCTAssertEqualObjects(dic[@"xcontent"], xcontentForView);
    }
}

- (void)test08IgnoreViewClass {
    [[viewTester usingLabel:@"IgnoreViewClass"] tap];
    [viewTester waitForAnimationsToFinish];
    
    [[viewTester usingLabel:@"ignoreViewClass"] tap];
    [viewTester waitForAnimationsToFinish];
    
    [MockEventQueue.sharedQueue cleanQueue];

    [[viewTester usingLabel:@"IgnoreButton1"] tap];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 0);
    
    [[viewTester usingLabel:@"IgnoreButton2"] tap];
    [[viewTester usingLabel:@"IgnoreButton3"] tap];
    [[viewTester usingLabel:@"NotIgnoreButton4"] tap];
    events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 3);
    GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
    XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"textValue"], @"IgnoreButton2");
    XCTAssertEqualObjects(dic[@"xpath"], @"/UITabBarController/UINavigationController/GrowingIgnoreViewViewController/UIView/GrowingIgnoreButton2");
    XCTAssertEqualObjects(dic[@"xcontent"], @"/0/1/0/0/0");
}

- (void)test09IgnoreViewClasses {
    [[viewTester usingLabel:@"IgnoreViewClass"] tap];
    [viewTester waitForAnimationsToFinish];
    
    [[viewTester usingLabel:@"ignoreViewClasses"] tap];
    [viewTester waitForAnimationsToFinish];
    
    [MockEventQueue.sharedQueue cleanQueue];

    [[viewTester usingLabel:@"IgnoreButton1"] tap];
    [[viewTester usingLabel:@"IgnoreButton2"] tap];
    [[viewTester usingLabel:@"IgnoreButton3"] tap];
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 0);
    
    [[viewTester usingLabel:@"NotIgnoreButton4"] tap];
    events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);
    GrowingViewElementEvent *event = (GrowingViewElementEvent *)events.firstObject;
    NSDictionary *dic = event.toDictionary;
    XCTAssertEqualObjects(dic[@"eventType"], GrowingEventTypeViewClick);
    XCTAssertTrue([ManualTrackHelper viewClickEventCheck:dic]);
    XCTAssertTrue([ManualTrackHelper contextOptionalPropertyCheck:dic]);
    
    XCTAssertEqualObjects(dic[@"textValue"], @"NotIgnoreButton4");
    XCTAssertEqualObjects(dic[@"xpath"], @"/UITabBarController/UINavigationController/GrowingIgnoreViewViewController/UIView/GrowingNotIgnoreButton4");
    XCTAssertEqualObjects(dic[@"xcontent"], @"/0/1/0/0/0");
}

@end
