//
//  clickEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/24.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "ClickEventsTest.h"
#import "GrowingAutotracker.h"
#import "GrowingTracker.h"
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
@implementation ClickEventsTest

- (void)beforeEach {
 
    //设置userid,确保userId字段不空
//    [Growing setLoginUserId:@"test"];
 
    //设置userid,确保cs1字段不空
    [[GrowingAutotracker sharedInstance] setLoginUserId:@"test"];
    [[viewTester usingLabel:@"UI界面"] tap];
}

- (void)afterEach {
}

- (void)test7DialogBtnCheck {
    /**
     function:对话框按钮点击，检测click事件，
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    //添加向下滚动操作，减少用例间相互影响
    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"AttributeLabel"] tap];
    [[viewTester usingLabel:@"ShowAlert"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"取消"] tap];
    [tester waitForTimeInterval:3];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    //是否发送click事件，需要确认
    if (clickEventArray.count >= 2) {
        //判断单击列表是否正确
        NSDictionary *chevent = [clickEventArray objectAtIndex:clickEventArray.count - 1];
        NSDictionary *clkchr = [NoburPoMeaProCheck clickEventCheck:chevent];
         NSLog(@"Check Result:%@",clkchr);
        // 校验最后一次点击事件 pageName  textValue  xpath 一致
        XCTAssertEqualObjects(chevent[@"path"],@"/UITabBarController/UINavigationController[1]/GIOLabelAttributeViewController[0]");

        XCTAssertEqualObjects(chevent[@"textValue"],@"取消");
        XCTAssertEqualObjects(chevent[@"xpath"],@"/Page/UIAlertController/UIView[0]/_UIAlertControllerInterfaceActionGroupView[0]/UIView[0]/_UIInterfaceActionRepresentationsSequenceView[0]/_UIInterfaceActionSeparatableSequenceView[0]/UIStackView[0]/_UIInterfaceActionCustomViewRepresentationView[1]/Button[0]");
        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
  //      XCTAssertEqualObjects(clkchr[@"ProCheck"][@"chres"], @"different");
  //      XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0], @"index");
        // 校验 点击ShowAlert事件 path  textValue  xpath 一致
        NSDictionary *chevent2 = [clickEventArray objectAtIndex:clickEventArray.count - 2];
        XCTAssertEqualObjects(chevent2[@"path"],@"/UITabBarController/UINavigationController[1]/GIOLabelAttributeViewController[0]");
        XCTAssertEqualObjects(chevent2[@"textValue"],@"ShowAlert");
        XCTAssertEqualObjects(chevent2[@"xpath"],@"/Page/UIButton[3]");


        NSLog(@"对话框按钮点击，检测click事件测试通过---Passed！");
    } else {
        NSLog(@"对话框按钮点击，检测click事件测试不通过:%@！", clickEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test10BtnGIONotTrackClick {
    /**
     function:setDataCollectionEnabled:NO，不发送click事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:NO];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    //添加向下滚动操作，减少用例间相互影响
    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"AttributeLabel"] tap];
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"GIODontTrackBtn"] tap];
    [tester waitForTimeInterval:3];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    if (clickEventArray == NULL) {
        XCTAssertEqual(1, 1);
        NSLog(@"setDataCollectionEnabled:NO，不发送click事件测试通过---Passed！");
    } else {
        NSLog(@"setDataCollectionEnabled:NO，不发送click事件测试不通过:%@！", clickEventArray);
        XCTAssertEqual(1, 0);
    }
    //恢复track状态
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:YES];
}

- (void)test11ColorButtonCheck {
    /**
     function:单击ColorButton，检测click事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    //添加向下滚动操作，减少用例间相互影响
    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
//    [tester waitForTimeInterval:5];
//    CGPoint point = CGPointMake(50, 500);
//    [tester tapScreenAtPoint:point];
    [[viewTester usingLabel:@"Fire"] tap];
    [tester waitForTimeInterval:3];
    [[viewTester usingLabel:@"好的"] tap];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    if (clickEventArray.count > 4) {
        // TODO:3.0 测量协议修改
        XCTAssertEqual(1, 1);
        NSLog(@"单击ColorButton，发送click事件测试通过---Passed！");
    } else {
        NSLog(@"单击ColorButton，发送click事件测试不通过:%@！", clickEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test12ButtonWithImageViewCheck {
    /**
     function:单击ButtonWithImageView，检测click事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    //添加向下滚动操作，减少用例间相互影响
    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [tester waitForTimeInterval:1];
//    CGPoint point = CGPointMake(130, 500);
//    [tester tapScreenAtPoint:point];
    [[viewTester usingLabel:@"Food"] tap];
    [tester waitForTimeInterval:3];
    [[viewTester usingLabel:@"好的"] tap];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    if (clickEventArray.count > 4) {
        NSDictionary *chevent = [clickEventArray objectAtIndex:clickEventArray.count-2];
        XCTAssertEqualObjects(chevent[@"textValue"],@"Food");
        XCTAssertEqualObjects(chevent[@"xpath"],@"/Page/UIView[0]/UIButton[0]");
        NSLog(@"单击ButtonWithImageView，发送click事件测试通过---Passed！");
    } else {
        NSLog(@"单击ButtonWithImageView，发送click事件测试不通过:%@！", clickEventArray);
        XCTAssertEqual(1, 0);
    }
}

- (void)test13UIViewButtonCheck {
    /**
     function:单击UIViewButton，检测click事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    //添加向下滚动操作，减少用例间相互影响
    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"Simple UI Elements"] tap];
    [tester waitForTimeInterval:5];
    [[viewTester usingLabel:@"Fire"] tap];
    [tester waitForTimeInterval:3];
    [[viewTester usingLabel:@"好的"] tap];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    if (clickEventArray.count > 3) {
        NSDictionary *chevent = [clickEventArray objectAtIndex:clickEventArray.count-2];
        XCTAssertEqualObjects(chevent[@"textValue"],@"Fire");
        XCTAssertEqualObjects(chevent[@"xpath"],@"/Page/UIView[0]/UIButton[1]");
        NSLog(@"单击UIViewButton，发送click事件测试通过---Passed！");
    } else {
        NSLog(@"单击UIViewButton，发送click事件测试不通过:%@！", clickEventArray);
        XCTAssertEqual(1, 0);
    }
}
@end
