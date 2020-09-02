//
//  GrowingIO_ExampleTests.m
//  GrowingIO_ExampleTests
//
//  Created by BeyondChao on 2020/8/5.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "MockEventQueue.h"

@interface GrowingIO_ExampleTests : XCTestCase

@end

@implementation GrowingIO_ExampleTests


// beforeEach 的作用参考KIF，简单概括就是构造测试Case的必要条件
- (void)beforeEach {
    [[viewTester usingLabel:@"VIEW_CHANGE请求"] tap];
}

// afterEach 的作用参考KIF，简单概括就是恢复app状态到初始状态，使得本case不对下次测试造成影响
- (void)afterEach {
    [[[[viewTester usingLabel:@"Previous"] usingTraits:UIAccessibilityTraitButton] usingAbsenceOfTraits:UIAccessibilityTraitKeyboardKey] tap];
}

- (void)setUp {
    self.continueAfterFailure = NO;

}

- (void)tearDown {
    
}

- (void)testExample {
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app launch];
}

@end
