//
//  TestHelper.h
//  GIOAutoTests
//
//  Created by GrowingIO on 28/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TestLog(fmt, ...) NSLog((@"%@ " fmt),NSStringFromSelector(_cmd),##__VA_ARGS__);
#define TestSuccess(fmt, ...) TestLog(@",test passed! " fmt,##__VA_ARGS__)
#define TestFailed(fmt, ...) TestLog(@",test failed: " fmt,##__VA_ARGS__)



#define TestRun(...) XCTestExpectation * expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ failed : timeout",NSStringFromSelector(_cmd)]];\
[GrowingDispatchManager dispatchInGrowingThread:^{\
    __VA_ARGS__;\
    [expectation fulfill];\
}];\
[self waitForExpectationsWithTimeout:10.0 handler:nil];\

@interface MockEventQueue : NSObject

+ (instancetype)sharedQueue;

- (NSUInteger)eventCount;
- (NSUInteger)eventCountFor:(NSString *)eventType;
- (void)cleanQueue;
- (NSArray *)eventsFor:(NSString *)eventType;
- (NSDictionary *)firstEventFor:(NSString *)eventType;
- (NSDictionary *)eventAt:(NSUInteger)index;
- (NSDictionary *)eventAt:(NSUInteger)index forType:(NSString *)eventType;

@end
