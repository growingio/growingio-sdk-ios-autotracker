//
//  TrackAPIMainThreadTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2019/11/8.
//  Copyright © 2019 GrowingIO. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "GrowingTracker.h"
#import "GrowingAutotracker.h"
#import <objc/runtime.h>
#import "GrowingEventManager.h"
#import <UIKit/UIKit.h>

#import "GrowingSession.h"
#import "GrowingDispatchManager.h"
@interface GrowingEventManager (GrowingAutoTest)

@end


@implementation GrowingEventManager (GrowingAutoTest)

static NSString *isGrowingThread = @"1";
static NSMutableArray *originalEventArray = nil;
static NSMutableArray *dbEventArray = nil;
static GrowingBaseEvent *originalEvent = nil;

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = NSClassFromString(@"GrowingEventManager");
        
        NSDictionary *swizzleDic = @{@"sendEventsOfChannel_unsafe:":@"sendEventsOfChannel_unsafeProxy:", @"writeToDatabaseWithEvent:":@"writeToDBWithEventTest:"};
        
        for (NSString *key in swizzleDic) {
            
            SEL originalSelector = NSSelectorFromString(key);
            SEL swizzledSelector = NSSelectorFromString(swizzleDic[key]);
            
            Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
            Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
            
            BOOL didAddMethod =
            class_addMethod(clazz,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(clazz,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }

        }
        
    });
}

- (void)sendEventsOfChannel_unsafeProxy:(id)channel {
    
    [self sendEventsOfChannel_unsafeProxy:channel];
    
    //  判断是否在Growing线程
    if (![[NSThread currentThread].name hasPrefix:@"com.growing"]) {
        isGrowingThread = @"0";
    }
}


//  判断入库事件带上 gesid 和 esid
- (void)writeToDBWithEventTest:(GrowingBaseEvent *)event {
    
    
    [self writeToDBWithEventTest:event];
    
    if (!dbEventArray) {
        dbEventArray = [NSMutableArray array];
    }
    [dbEventArray addObject:event];
    
    //  判断是否在Growing线程
    if (![[NSThread currentThread].name hasPrefix:@"com.growing"]) {

        isGrowingThread = @"0";
    }
}


@end


@interface A1TrackAPIMainThreadTest : KIFTestCase <GrowingEventInterceptor>

@end

@implementation A1TrackAPIMainThreadTest

+ (void)setUp {
    [super setUp];
    [[GrowingEventManager shareInstance] addInterceptor:self];
}

+ (void)tearDown {
    [super tearDown];
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *)event {
    originalEvent = event;
    if (!originalEventArray) {
        originalEventArray = [NSMutableArray array];
    }
    [originalEventArray addObject:event];
}

#pragma mark -GrowingCoreKit API Test
- (void)test1SetUserIdTest {
    isGrowingThread = @"1";
    //  hook 入库方法，在 handleEvent:   GrowingBaseEventManager
    //  设置一个变量进行判断
    [[GrowingAutotracker sharedInstance] cleanLoginUserId];
    XCTestExpectation *expectation = [self expectationWithDescription:@"setUserId: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *userId = @"123456789";
        [[GrowingAutotracker sharedInstance] setLoginUserId:userId];
        [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
            XCTAssertEqual([GrowingSession currentSession].loginUserId,userId);
        }];
        [expectation fulfill];
    });
    

    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {

        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    [self eventTest];
}

- (void)test2ClearUserIdTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"clearUserId: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] cleanLoginUserId];
        [GrowingDispatchManager trackApiSel:_cmd dispatchInMainThread:^{
            XCTAssertEqual([GrowingSession currentSession].loginUserId,nil);
        }];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    [self eventTest];
}

- (void)test3SetConversionVariablesTest {
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setConversionVariables: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] setConversionVariables:@{@"EvarAutoTest":@"evarAuto"}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    [self eventTest];
}



- (void)test4SetEvarAndStringTest {
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setEvarWithKey:andStringValue: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] setConversionVariables:@{@"EvarKeyAutoTest":@"evarKeyAutoString"}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    [self eventTest];
}

- (void)test5SetEvarAndNumberTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setEvarWithKey:andNumberValue: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] setConversionVariables:@{@"EvarNumberAutoTest" :@22}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
    
}

- (void)test6SetPeopleTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setPeopleVariable: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"PeopleAutoTest":@"peopleAuto"}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
    
}

- (void)test7SetPeopleAndStringTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setPeopleVariableWithKey:andStringValue: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"PeopleKeyAutoTest" :@"PeopleKeyAutoString"}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
    
}

- (void)test8SetPeopleAndNumberTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setPeopleVariableWithKey:andNumberValue: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] setLoginUserAttributes:@{@"PeopleNumberAutoTest" :@22}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
}

- (void)test9TrackTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"track: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"TrackAutoTest"];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
    
}

- (void)test10TrackAndNumberTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"track:withNumber: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"TrackAutoTest"];
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"TrackAutoTest"];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
    
}

- (void)test11TrackAndNumberAndVariableTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"track:withNumber:andVariable: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] trackCustomEvent:@"TrackAutoTest" withAttributes:@{@"TrackAutoTest":@"trackAutoTest"}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
    
}

- (void)test11TrackAndVariableTest {
    
      isGrowingThread = @"1";
      XCTestExpectation *expectation = [self expectationWithDescription:@"track:withVariable: fail"];
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
          [[GrowingAutotracker sharedInstance] trackCustomEvent:@"TrackAutoTest" withAttributes:@{@"TrackAutoTest":@"trackAutoTest"}];
          [expectation fulfill];
      });
      
      [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
      //  操作15秒超时，支持不通过
          if (error) {
              NSLog(@"Test failed——%@",expectation.description);
              XCTAssertEqual(@"1", @"0");
          }
      }];
      
    [self eventTest];

}

- (void)test12SetVisitorTest {
    
    isGrowingThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setVisitor: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingAutotracker sharedInstance] setVisitorAttributes:@{@"VisitorAutoTest":@"visitorAutoTest"}];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
    //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
   [self eventTest];

}

#pragma mark - GrowingAutoTracker API Test
- (void)test13PageVariableToViewControllerTest {
    isGrowingThread = @"1";
    UIViewController *vc = [UIViewController new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"setPageVariable:toViewController: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        vc.growingPageAttributes = @{@"PageVariable": @"pageVariable"};
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        //  操作15秒超时，支持不通过
        if (error) {
            NSLog(@"Test failed——%@",expectation.description);
            XCTAssertEqual(@"1", @"0");
        }
    }];
    
    [self eventTest];
}

#pragma mark - private methods
- (void)eventTest {
    sleep(1);
    //  不允许出现子线程调用API
    XCTAssertEqual(isGrowingThread, @"1");
}




@end
