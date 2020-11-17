//
//  clickEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/24.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "ClickEventsTest.h"

#import "GrowingTracker.h"
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
@implementation ClickEventsTest

- (void)beforeEach {
    //设置userid,确保cs1字段不空
    [[GrowingTracker sharedInstance] setLoginUserId:@"test"];
}

- (void)afterEach {
}

- (void)test7DialogBtnCheck {
    /**
     function:对话框按钮点击，检测click事件，模拟器上没有数据发送，真机上有
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
        // NSLog(@"Check Result:%@",clkchr);
        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"chres"], @"different");
        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0], @"index");
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
    [[GrowingTracker sharedInstance] setDataCollectionEnabled:NO];
    [[viewTester usingLabel:@"UI界面"] tap];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"UI界面"] tap];
    //添加向下滚动操作，减少用例间相互影响
    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
    [tester waitForTimeInterval:1];
    [[viewTester usingLabel:@"AttributeLabel"] tap];
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"BtnGIODNTR"] tap];
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
    [[GrowingTracker sharedInstance] setDataCollectionEnabled:YES];
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
    [tester waitForTimeInterval:5];
    CGPoint point = CGPointMake(50, 500);
    [tester tapScreenAtPoint:point];
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
    CGPoint point = CGPointMake(130, 500);
    [tester tapScreenAtPoint:point];
    [tester waitForTimeInterval:3];
    [[viewTester usingLabel:@"好的"] tap];
    NSArray *clickEventArray = [MockEventQueue.sharedQueue eventsFor:@"VIEW_CLICK"];
    if (clickEventArray.count > 4) {
        // TODO:3.0 测量协议修改
        XCTAssertEqual(1, 1);
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
        // TODO:3.0 测量协议修改
        XCTAssertEqual(1, 1);
        NSLog(@"单击UIViewButton，发送click事件测试通过---Passed！");
    } else {
        NSLog(@"单击UIViewButton，发送click事件测试不通过:%@！", clickEventArray);
        XCTAssertEqual(1, 0);
    }
}
@end
