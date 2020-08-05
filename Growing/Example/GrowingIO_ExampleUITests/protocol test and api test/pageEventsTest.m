//
//  PageEventsTest.m
//  GIOAutoTests
//
//  Created by GIO-baitianyu on 31/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import <KIF/KIF.h>
#import "MockEventQueue.h"
#import "GrowingTestHelper.h"

static NSString *pageType = @"page";

@interface PageEventsTest : KIFTestCase

@end

@implementation PageEventsTest


- (void)beforeEach {

}

- (void)afterEach {
    
}

//冷启动app && 第一次进入page 请求页面
//- (void)test1NotRunningToActive {
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"page请求"] tap];
//
//    //虽然产生了page事件，但是并没有添加到 MockEventQueue 中，所以设置10s延时
//    [tester waitForTimeInterval:10];
//    NSArray *pageEventArray = [MockEventQueue eventsFor:@"page"];
//    NSInteger count = [self calculateEventsCountWithTitle:@"page 请求" fromEventsArray:pageEventArray];
//    XCTAssertEqual(count, 1);
//
//    [[[[viewTester usingLabel:@"Previous"] usingTraits:UIAccessibilityTraitButton] usingAbsenceOfTraits:UIAccessibilityTraitKeyboardKey] tap];
//}

//app 退到后台, 重新启动后进入page页面
//- (void)test2BackgroundToActive {
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"page请求"] tap];
//    //进入后台10秒
//    [GrowingTestHelper deactivateAppForDuration:10];
//    //从后台唤醒app
//    [GrowingTestHelper reactivateApp];
//
//    [tester waitForTimeInterval:10];
//    NSArray *pageEventArray = [MockEventQueue eventsFor:@"page"];
//    NSInteger count = [self calculateEventsCountWithTitle:@"page 请求" fromEventsArray:pageEventArray];
//    //进入page请求页面时有1个page请求，进入后台再进入page页面还会有一个page请求
//    XCTAssertEqual(count, 2);
//
//    [[[[viewTester usingLabel:@"Previous"] usingTraits:UIAccessibilityTraitButton] usingAbsenceOfTraits:UIAccessibilityTraitKeyboardKey] tap];
//}

//因TabBarController item切换发送 page 请求
//- (void)test3TabBarControllerSelectNewItem {
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"UI界面"] tap];
//
//    NSArray *pageEventArray = [MockEventQueue eventsFor:@"page"];
//    //检验page请求的tl是否合理
//    NSInteger count = [self calculateEventsCountWithTitle:@"UI 测试" fromEventsArray:pageEventArray];
//
//    XCTAssertEqual(count, 1);
//}

//因UINavigationController 切换发送 page 请求
//- (void)test4EnterNavController {
//    [[viewTester usingLabel:@"协议/接口"] tap];
//    [[viewTester usingLabel:@"page请求"] tap];
//    [tester waitForTimeInterval:10];
//    [MockEventQueue cleanQueue];
//
//    [[viewTester usingLabel:@"进入测试"] tap];
//    [tester waitForTimeInterval:10];
//    NSUInteger pageEventCount = [[MockEventQueue eventsFor:@"page"] count];
//
//    XCTAssertEqual(pageEventCount, 1);
//}

//ContainerViewController 添加了两个子VC
//由 FirstViewController 切换到 SecondViewController
//- (void)test5SwitchToSecondViewController {
//    [MockEventQueue cleanQueue];
//    [[viewTester usingLabel:@"第二页"] tap];
//    [tester waitForTimeInterval:10];
//    NSUInteger pageEventCount = [[MockEventQueue eventsFor:@"page"] count];
//    XCTAssertEqual(pageEventCount, 1);
//}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

//统计 tl 为 title 的event个数
- (NSInteger)calculateEventsCountWithTitle:(NSString *)title fromEventsArray:(NSArray *)array {
    NSInteger eventsCount = 0;
    for (NSDictionary *dic in array) {
        if ([dic[@"tl"] isEqualToString:title]) {
            eventsCount += 1;
        }
    }
    return eventsCount;
}

@end
