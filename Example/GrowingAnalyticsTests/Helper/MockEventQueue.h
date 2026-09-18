//
//  TestHelper.h
//  GIOAutoTests
//
//  Created by GrowingIO on 28/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TestLog(fmt, ...) NSLog((@"%@ " fmt), NSStringFromSelector(_cmd), ##__VA_ARGS__);
#define TestSuccess(fmt, ...) TestLog(@",test passed! " fmt, ##__VA_ARGS__)
#define TestFailed(fmt, ...) TestLog(@",test failed: " fmt, ##__VA_ARGS__)

@class GrowingBaseEvent;

@interface MockEventQueue : NSObject

+ (instancetype)sharedQueue;

- (NSUInteger)eventCount;
- (NSUInteger)eventCountFor:(NSString *)eventType;
- (void)cleanQueue;
- (NSArray<NSDictionary *> *)rawEventsFor:(NSString *)eventType;
- (NSArray<GrowingBaseEvent *> *)eventsFor:(NSString *)eventType;
- (NSArray *)allEvent;
- (GrowingBaseEvent *)lastEventFor:(NSString *)eventType;
- (GrowingBaseEvent *)eventAt:(NSUInteger)index;
- (GrowingBaseEvent *)eventAt:(NSUInteger)index forType:(NSString *)eventType;

/// 等待指定类型的事件累积到 count 个，事件入队时唤醒，满足即返回 YES，超时返回 NO。
/// 用于替代 dispatch_after 固定时长等待：事件到达即继续，慢环境下也会等满 timeout 而非提前断言失败。
/// 须在主线程调用。
- (BOOL)waitForEventsFor:(NSString *)eventType count:(NSUInteger)count timeout:(NSTimeInterval)timeout;

@end
