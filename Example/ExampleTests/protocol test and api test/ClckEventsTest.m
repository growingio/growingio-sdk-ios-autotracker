//
//  ClckEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/2/24.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import "ClckEventsTest.h"
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
#import "GrowingTracker.h"
@implementation ClckEventsTest

- (void)beforeEach {
    //设置userid,确保cs1字段不空
    [Growing setLoginUserId:@"test"];

}

- (void)afterEach {
    
}


//-(void)test1BtnClick{
//    /**
//     function:按钮点击操作，测试clck事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//      [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Buttons & AlertView"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Button"] tap];
//
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
//    if(clckEventArray.count>=3)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-1];
//        //XCTAssertEqualObjects(chevent[@"v"],@"Button");
//        //检测发送事件情况
//        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
//        //NSLog(@"Check Result:%@",clkchr);
//        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqual(clkchr[@"ProCheck"][@"chres"],@"same");
//        NSLog(@"按钮点击操作，测试clck事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"按钮点击操作，测试clck事件没有发送事件测试不通过,%@！",clckEventArray);
//        XCTAssertEqual(1, 0);
//    }
//    [[viewTester usingLabel:@"OK"] tap];
//}

//-(void)test2BtnClickPPTMCheck{
//    /**
//     function:按钮点击操作，测试clck事件与page事件的p,ptm字段是否一致
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Buttons & AlertView"] tap];
//    [[viewTester usingLabel:@"Button"] tap];
//
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
//    NSDictionary *clickchr=[clckEventArray objectAtIndex:clckEventArray.count-1];
//
//    NSArray *pageEventArray = [MockEventQueue.sharedQueue eventsFor:@"page"];
//    //NSLog(@"page事件：%@",[pageEventArray objectAtIndex:pageEventArray.count-1]);
//    NSDictionary *pagechr=[pageEventArray objectAtIndex:pageEventArray.count-1];
//    if(clickchr.count>0 && pagechr.count>0)
//    {
//        XCTAssertEqualObjects(clickchr[@"p"],pagechr[@"p"]);
//        XCTAssertEqualObjects(clickchr[@"ptm"],pagechr[@"ptm"]);
//        NSLog(@"检测clck事件与page事件的p,ptm字段的一致性测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"检测clck事件与page事件的p,ptm字段的一致性测试不通过:%@！",pagechr);
//        XCTAssertEqual(1, 0);
//    }
//    [[viewTester usingLabel:@"OK"] tap];
//}

//-(void)test3BtnSwipeCheck{
//    /**
//     function:拖拽按钮，检测clck事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Buttons & AlertView"] tap];
//    [tester swipeViewWithAccessibilityLabel:@"Button" inDirection:KIFSwipeDirectionRight];
//
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck事件个数：%lu",(unsigned long)clckEventArray.count);
//    if(clckEventArray.count==6)
//    {
//         XCTAssertEqual(1, 1);
//        NSLog(@"拖拽按钮，不发送clck事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"拖拽按钮，不发送clck事件不测试通过：%@！",clckEventArray);
//        XCTAssertEqual(1, 0);
//    }
//}

//-(void)test4LongPressCheck{
//    /**
//     function:按下并抬起按钮，检测clck事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Buttons & AlertView"] tap];
//    [[viewTester usingLabel:@"Button"] longPress];
//
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck事件个数：%lu",(unsigned long)clckEventArray.count);
//    if(clckEventArray.count>=3)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-1];
//        //NSLog(@"clck事件：%@",chevent);
//        XCTAssertEqualObjects(chevent[@"v"],@"Button");
//        //检测发送事件情况
//        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
//        //NSLog(@"Check Result:%@",clkchr);
//        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"chres"],@"same");
//        NSLog(@"按下并抬起按钮，检测clck事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"按下并抬起按钮，检测clck事件没有发送事件测试不通过:%@！",clckEventArray);
//        XCTAssertEqual(1, 0);
//    }
//    [[viewTester usingLabel:@"OK"] tap];
//}

//-(void)test2SegmentCheck{
//    /**
//     function:多选控件点击，clck事件检测
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Simple UI Elements"] tap];
//    [[viewTester usingLabel:@"Second"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
//    if(clckEventArray.count>=3)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-1];
//        //NSLog(@"Clck事件：%@",chevent);
//        XCTAssertEqualObjects(chevent[@"v"],@"Second");
//        //检测发送事件情况
//        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
//        NSLog(@"Check Result:%@",clkchr);
//        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
//        NSArray *reduc=clkchr[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(reduc.count, 1);
//        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0],@"idx");
//        NSLog(@"多选控件点击，clck事件检测测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"多选控件点击，clck事件检测没有发送事件测试不通过:%@！",clckEventArray);
//        XCTAssertEqual(1, 0);
//    }
//}

//-(void)test6TabelViewCellCheck{
//    /**
//     function:单击列表行，检测clck事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Simple UI Elements"] tap];
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
//    if(clckEventArray.count>=2)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-1];
//        XCTAssertEqualObjects(chevent[@"v"],@"Simple UI Elements");
//        //检测发送事件情况
//        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
//        //NSLog(@"Check Result:%@",clkchr);
//        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
//        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"chres"],@"same");
//        NSLog(@"单击列表行，检测clck事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"单击列表行，检测clck事件测试不通过:%@！",clckEventArray);
//        XCTAssertEqual(1, 0);
//    }
//}

-(void)test7DialogBtnCheck{
    /**
     function:对话框按钮点击，检测clck事件，模拟器上没有数据发送，真机上有
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
    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
    //NSLog(@"Clck 事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
    //NSLog(@"Clck 事件个数：%lu",clckEventArray.count);
    //是否发送clck事件，需要确认
    if(clckEventArray.count>=2)
    {
        //判断单击列表是否正确
        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-1];
        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
        //NSLog(@"Check Result:%@",clkchr);
        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"chres"],@"different");
        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0],@"idx");
        NSLog(@"对话框按钮点击，检测clck事件测试通过---Passed！");
    }
    else
    {
        NSLog(@"对话框按钮点击，检测clck事件测试不通过:%@！",clckEventArray);
        XCTAssertEqual(1, 0);
    }
}
//-(void)test8PicClick{
//    /**
//     function:点击图片,不发送clck事件
//     **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"Page Control & ImageView"] tap];
//    [tester waitForTimeInterval:1];
//    UIStepper *repsStepper = (UIStepper*)[tester waitForViewWithAccessibilityLabel:@"PageImageView"];
//    CGPoint stepperCenter = [repsStepper.window convertPoint:repsStepper.center
//                                                    fromView:repsStepper.superview];
//    [tester tapScreenAtPoint:stepperCenter];
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck 事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
//    if(clckEventArray.count==6)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-1];
//        XCTAssertEqualObjects(chevent[@"v"],@"Page Control & ImageView");
//        XCTAssertEqual(1, 1);
//        NSLog(@"点击图片,不发送clck事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"点击图片,不发送clck事件测试不通过:%@！",clckEventArray);
//        XCTAssertEqual(1, 0);
//    }
//
//}

//-(void)test9NotUIClick{
///**
// function:UITapGestureRecognizer触发，发送clck事件
// **/
//    [MockEventQueue.sharedQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"UI界面"] tap];
//    //添加向下滚动操作，减少用例间相互影响
//    [tester scrollViewWithAccessibilityLabel:@"CollectionView" byFractionOfSizeHorizontal:0.0f vertical:-10.0f];
//    [tester waitForTimeInterval:1];
//    [[viewTester usingLabel:@"NotUIControl"] tap];
//    //[[viewTester usingLabel:@"非UIControl，为UILabel"] tap];
//    [tester waitForTimeInterval:1];
//    //iphoneX
//    CGPoint point=CGPointMake(179, 114);
//    [tester tapScreenAtPoint:point];
//    [tester waitForTimeInterval:3];
//    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
//    //NSLog(@"Clck 事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
//    if(clckEventArray.count>4)
//    {
//        //判断单击列表是否正确
//        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-1];
//        XCTAssertEqualObjects(chevent[@"v"],@"非UIControl，为UILabel");
//        //检测发送事件情况
//        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
//        //NSLog(@"Check Result:%@",clkchr);
//        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
//        NSArray *reduc=clkchr[@"ProCheck"][@"reduce"];
//        XCTAssertEqual(reduc.count, 1);
//        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0],@"idx");
//        NSLog(@"UITapGestureRecognizer触发，发送clck事件测试通过---Passed！");
//    }
//    else
//    {
//        NSLog(@"UITapGestureRecognizer触发，发送clck事件测试不通过:%@！",clckEventArray);
//        XCTAssertEqual(1, 0);
//    }
//    [[viewTester usingLabel:@"好的"] tap];
//}

-(void)test10BtnGIONotTrackClick{
    /**
     function:setGrowingAttributesDonotTrack:YES，不发送clck事件
     **/
    [MockEventQueue.sharedQueue cleanQueue];
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
    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
    //NSLog(@"Clck 事件：%@",clckEventArray);
    if(clckEventArray==NULL)
    {
        XCTAssertEqual(1, 1);
        NSLog(@"setGrowingAttributesDonotTrack:YES，不发送clck事件测试通过---Passed！");
    }
    else
    {
        NSLog(@"setGrowingAttributesDonotTrack:YES，不发送clck事件测试不通过:%@！",clckEventArray);
        XCTAssertEqual(1, 0);
    }
}

-(void)test11ColorButtonCheck{
    /**
     function:单击ColorButton，检测clck事件
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
    CGPoint point=CGPointMake(50,500);
    [tester tapScreenAtPoint:point];
    [tester waitForTimeInterval:3];
     [[viewTester usingLabel:@"好的"] tap];
    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
    //NSLog(@"Clck 事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
    if(clckEventArray.count>4)
    {
        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-2];
        XCTAssertEqualObjects(chevent[@"v"],@"");
        //检测发送事件情况
        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
        //NSLog(@"Check Result:%@",clkchr);
        NSArray *ekey=clkchr[@"KeysCheck"][@"EmptyKeys"];
        XCTAssertEqual(ekey.count, 1);
        XCTAssertEqualObjects(clkchr[@"KeysCheck"][@"EmptyKeys"][0],@"v");
        NSArray *reduc=clkchr[@"ProCheck"][@"reduce"];
        XCTAssertEqual(reduc.count, 1);
        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0],@"idx");
        NSLog(@"单击ColorButton，发送clck事件测试通过---Passed！");
    }
    else
    {
        NSLog(@"单击ColorButton，发送clck事件测试不通过:%@！",clckEventArray);
        XCTAssertEqual(1, 0);
    }
   
}

-(void)test12ButtonWithImageViewCheck{
    /**
     function:单击ButtonWithImageView，检测clck事件
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
    CGPoint point=CGPointMake(130,500);
    [tester tapScreenAtPoint:point];
    [tester waitForTimeInterval:3];
     [[viewTester usingLabel:@"好的"] tap];
    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
    //NSLog(@"Clck 事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
    if(clckEventArray.count>4)
    {
        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-2];
        XCTAssertEqualObjects(chevent[@"v"],@"邮件");
        //检测发送事件情况
        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
        //NSLog(@"Check Result:%@",clkchr);
        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
        NSArray *reduc=clkchr[@"ProCheck"][@"reduce"];
        XCTAssertEqual(reduc.count, 1);
        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0],@"idx");
        NSLog(@"单击ButtonWithImageView，发送clck事件测试通过---Passed！");
    }
    else
    {
        NSLog(@"单击ButtonWithImageView，发送clck事件测试不通过:%@！",clckEventArray);
        XCTAssertEqual(1, 0);
    }
   
}

-(void)test13UIViewButtonCheck{
    /**
     function:单击UIViewButton，检测clck事件
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
//    CGPoint point=CGPointMake(200,500);
//    [tester tapScreenAtPoint:point];
    [[viewTester usingLabel:@"Fire"] tap];
    [tester waitForTimeInterval:3];
    [[viewTester usingLabel:@"好的"] tap];
    NSArray *clckEventArray = [MockEventQueue.sharedQueue eventsFor:@"clck"];
    //NSLog(@"Clck 事件：%@",[clckEventArray objectAtIndex:clckEventArray.count-1]);
    if(clckEventArray.count>3)
    {
        NSDictionary *chevent=[clckEventArray objectAtIndex:clckEventArray.count-2];
        //检测发送事件情况
        NSDictionary *clkchr=[NoburPoMeaProCheck ClckEventCheck:chevent];
        //NSLog(@"Check Result:%@",clkchr);
        XCTAssertEqual(clkchr[@"KeysCheck"][@"chres"], @"Passed");
        NSArray *reduc=clkchr[@"ProCheck"][@"reduce"];
        XCTAssertEqual(reduc.count, 1);
        XCTAssertEqualObjects(clkchr[@"ProCheck"][@"reduce"][0],@"idx");
        NSLog(@"单击UIViewButton，发送clck事件测试通过---Passed！");
    }
    else
    {
        NSLog(@"单击UIViewButton，发送clck事件测试不通过:%@！",clckEventArray);
        XCTAssertEqual(1, 0);
    }
}
@end
