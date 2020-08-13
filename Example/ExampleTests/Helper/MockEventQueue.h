//
//  TestHelper.h
//  GIOAutoTests
//
//  Created by GrowingIO on 28/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
