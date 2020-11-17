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

@interface GrowingEventManager (GrowingAutoTest)

@end


@implementation GrowingEventManager (GrowingAutoTest)

static NSString *isMainThread = @"1";
static NSMutableArray *originalEventArray = nil;
static NSMutableArray *dbEventArray = nil;
static GrowingBaseEvent *originalEvent = nil;

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = NSClassFromString(@"GrowingEventManager");
        
        NSDictionary *swizzleDic = @{@"handleEvent:":@"mainThreadHandleEvent:", @"writeToDatabaseWithEvent:":@"writeToDBWithEventTest:"};
        
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

- (void)mainThreadHandleEvent:(GrowingBaseEvent *)event {
    
    originalEvent = event;
    
    [self mainThreadHandleEvent:event];
    
    if (!originalEventArray) {
        originalEventArray = [NSMutableArray array];
    }
    [originalEventArray addObject:event];
  
    //  判断是否在主线程
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) != 0) {
        //  非主线程
        isMainThread = @"0";
    }
}


//  判断入库事件带上 gesid 和 esid
- (void)writeToDBWithEventTest:(GrowingBaseEvent *)event {
    
    [self writeToDBWithEventTest:event];
    
    if (!dbEventArray) {
        dbEventArray = [NSMutableArray array];
    }
    [dbEventArray addObject:event];
    
}

- (NSArray <NSString *> *)getEventTypes {
//    GrowingBaseEventManager *eventManager = [GrowingBaseEventManager shareInstance];
//    GrowingBaseEventCounter * eventCounter = [eventManager valueForKey:@"eventCounter"];
//    NSDictionary *eventTypeIdMap = [eventCounter valueForKey:@"eventSequenceIdMap"];
//    return eventTypeIdMap.allKeys;
    return  nil;
}

@end


@interface A1TrackAPIMainThreadTest : KIFTestCase

@end

@implementation A1TrackAPIMainThreadTest

+ (void)setUp {
    [super setUp];
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

#pragma mark -GrowingCoreKit API Test
- (void)test1SetUserIdTest {
    isMainThread = @"1";
    //  hook 入库方法，在 handleEvent:   GrowingBaseEventManager
    //  设置一个变量进行判断
    [[GrowingTracker sharedInstance] cleanLoginUserId];
    XCTestExpectation *expectation = [self expectationWithDescription:@"setUserId: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingTracker sharedInstance] setLoginUserId:@"9"];
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

- (void)test2ClearUserIdTest {
    
    isMainThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"clearUserId: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingTracker sharedInstance] cleanLoginUserId];
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

- (void)test3SetEvarTest {
    
       isMainThread = @"1";
       XCTestExpectation *expectation = [self expectationWithDescription:@"setEvar: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [[GrowingTracker sharedInstance] setConversionVariables:@{@"EvarAutoTest":@"evarAuto"}];
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

- (void)test4SetEvarAndStringTest {
    
       isMainThread = @"1";
       XCTestExpectation *expectation = [self expectationWithDescription:@"setEvarWithKey:andStringValue: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [[GrowingTracker sharedInstance] setConversionVariables:@{@"EvarKeyAutoTest":@"evarKeyAutoString"}];
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

- (void)test5SetEvarAndNumberTest {
    
      isMainThread = @"1";
      XCTestExpectation *expectation = [self expectationWithDescription:@"setEvarWithKey:andNumberValue: fail"];
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
          [[GrowingTracker sharedInstance] setConversionVariables:@{@"EvarNumberAutoTest" :@22}];
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
    
       isMainThread = @"1";
       XCTestExpectation *expectation = [self expectationWithDescription:@"setPeopleVariable: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [[GrowingTracker sharedInstance] setLoginUserAttributes:@{@"PeopleAutoTest":@"peopleAuto"}];
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
    
       isMainThread = @"1";
       XCTestExpectation *expectation = [self expectationWithDescription:@"setPeopleVariableWithKey:andStringValue: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [[GrowingTracker sharedInstance] setLoginUserAttributes:@{@"PeopleKeyAutoTest" :@"PeopleKeyAutoString"}];
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
    
      isMainThread = @"1";
      XCTestExpectation *expectation = [self expectationWithDescription:@"setPeopleVariableWithKey:andNumberValue: fail"];
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
          [[GrowingTracker sharedInstance] setLoginUserAttributes:@{@"PeopleNumberAutoTest" :@22}];
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
    
        isMainThread = @"1";
       XCTestExpectation *expectation = [self expectationWithDescription:@"track: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [[GrowingTracker sharedInstance] trackCustomEvent:@"TrackAutoTest"];
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
    
        isMainThread = @"1";
       XCTestExpectation *expectation = [self expectationWithDescription:@"track:withNumber: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [[GrowingTracker sharedInstance] trackCustomEvent:@"TrackAutoTest"];
           [[GrowingTracker sharedInstance] trackCustomEvent:@"TrackAutoTest"];
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
    
        isMainThread = @"1";
          XCTestExpectation *expectation = [self expectationWithDescription:@"track:withNumber:andVariable: fail"];
          dispatch_async(dispatch_get_global_queue(0, 0), ^{
              [[GrowingTracker sharedInstance] trackCustomEvent:@"TrackAutoTest" withAttributes:@{@"TrackAutoTest":@"trackAutoTest"}];
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
    
      isMainThread = @"1";
      XCTestExpectation *expectation = [self expectationWithDescription:@"track:withVariable: fail"];
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
          [[GrowingTracker sharedInstance] trackCustomEvent:@"TrackAutoTest" withAttributes:@{@"TrackAutoTest":@"trackAutoTest"}];
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
    
    isMainThread = @"1";
    XCTestExpectation *expectation = [self expectationWithDescription:@"setVisitor: fail"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[GrowingTracker sharedInstance] setVisitorAttributes:@{@"VisitorAutoTest":@"visitorAutoTest"}];
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
    
       isMainThread = @"1";
       UIViewController *vc = [UIViewController new];
       XCTestExpectation *expectation = [self expectationWithDescription:@"setPageVariable:toViewController: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
  //         [[GrowingTracker sharedInstance] setPageVariable:@{@"PageVariable": @"pageVariable"} toViewController:vc];
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

- (void)test14SetPageVariableWithKeyAndStringValueToViewControllerTest {
    
       isMainThread = @"1";
       UIViewController *vc = [UIViewController new];
       XCTestExpectation *expectation = [self expectationWithDescription:@"setPageVariableWithKey:andStringValue:toViewController: fail"];
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
  //         [[GrowingTracker sharedInstance] setPageVariableWithKey:@"PageVariableKey" andStringValue:@"pageVariableKeyString" toViewController:vc];
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

- (void)test15SetPageVariableWithKeyAndNumberValueToViewControllerTest {
    
      isMainThread = @"1";
      UIViewController *vc = [UIViewController new];
      XCTestExpectation *expectation = [self expectationWithDescription:@"setPageVariableWithKey:andNumberValue:toViewController: fail"];
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //      [[GrowingTracker sharedInstance] setPageVariableWithKey:@"PageVariableKey" andNumberValue:[NSNumber numberWithInt:55] toViewController:vc];
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
    
//    //  不允许出现子线程调用API
//    XCTAssertEqual(isMainThread, @"1");
//    XCTAssertNotNil(originalEvent);
//    XCTAssertTrue(originalEvent.eventType.length > 0);
//    [originalEventArray enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL * _Nonnull stop) {
//
//    }];
//
//    [dbEventArray enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self eventCounterTestEvent:event];
//    }];

}

- (void)eventCounterTestEvent:(GrowingBaseEvent *)event {
    
//    NSArray *eventTypes = [[GrowingEventManager shareInstance] getEventTypes];
//    if ([eventTypes containsObject:event.eventTypeKey]) {
//
//        XCTAssertNotNil(event.globalSequenceId);
//        XCTAssertNotNil(event.eventSequenceId);
//
//    } else {
//
//        XCTAssertNil(event.globalSequenceId);
//        XCTAssertNil(event.eventSequenceId);
//    }
}


@end
