//
//  GrowingIO_ExampleTests.m
//  GrowingIO_ExampleTests
//
//  Created by BeyondChao on 2020/8/5.
//  Copyright © 2020 3255289628@qq.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "MockEventQueue.h"

@interface GrowingIO_ExampleTests : XCTestCase

@end

@implementation GrowingIO_ExampleTests


// beforeEach 的作用参考KIF，简单概括就是构造测试Case的必要条件
- (void)beforeEach {
    [[viewTester usingLabel:@"chng请求"] tap];
}

// afterEach 的作用参考KIF，简单概括就是恢复app状态到初始状态，使得本case不对下次测试造成影响
- (void)afterEach {
    [[[[viewTester usingLabel:@"Previous"] usingTraits:UIAccessibilityTraitButton] usingAbsenceOfTraits:UIAccessibilityTraitKeyboardKey] tap];
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

//- (void)testExample {
//    //构造chng事件
//    [[viewTester usingLabel:@"UserName"] enterText:@"GrowingIOUser\n"];
//    [[viewTester usingLabel:@"PassWord"] waitToBecomeFirstResponder];
//    [[viewTester usingLabel:@"PassWord"] waitForView];
//    [[viewTester usingLabel:@"PassWord"] enterText:@"GrowingIO" expectedResult:@"GrowingIO"];
//
//    //MockEventQueue 缓存事件并提供了几个高效的接口
//    NSUInteger chngEventCount = [[MockEventQueue eventsFor:@"chng"] count];
//
//    NSUInteger acvEventCount = [[MockEventQueue eventsFor:@"app_activate"] count];
//
//    //使用XCTAssert断言，该部分可参考apple 文档
//    XCTAssertEqual(chngEventCount, 1);
//    XCTAssertEqual(acvEventCount, 1);
//}

@end
