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

@end
