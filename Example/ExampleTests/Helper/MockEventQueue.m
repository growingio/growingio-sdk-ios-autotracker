//
//  TestHelper.m
//  GIOAutoTests
//
//  Created by GrowingIO on 28/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "MockEventQueue.h"
#import "GrowingEventManager.h"

@interface MockEventQueue () <GrowingEventInterceptor>

@property (nonatomic, strong) NSMutableArray <GrowingBaseEvent *> *eventQueue;

@end

@implementation MockEventQueue

static MockEventQueue *queue = nil;
    
+ (instancetype)sharedQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[MockEventQueue alloc] init];
    });
    
    return queue;
}

- (instancetype)init {
    if (self = [super init]) {
        [[GrowingEventManager shareInstance] addInterceptor:self];
        self.eventQueue = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)cleanQueue {
    [self.eventQueue removeAllObjects];
}

- (NSArray <NSDictionary *> *)eventsFor:(NSString *)eventType {
    __block NSMutableArray <NSDictionary *> *events = [[NSMutableArray alloc] init];
    [self.eventQueue enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL *stop) {
        
        if ([event.eventType isEqualToString:eventType]) {
            [events addObject:event.toDictionary];
        }
    }];
    
    if ([events count] > 0) {
        return events;
    } else {
        return nil;
    }
}

- (NSDictionary *)firstEventFor:(NSString *)eventType {
    __block NSDictionary *dataDict;
    [self.eventQueue enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL *stop) {
        if ([event.eventType isEqualToString:eventType]) {
            dataDict = event.toDictionary;
            *stop = YES;
        }
    }];
    
    return dataDict;
}

- (NSUInteger)eventCount {
    return self.eventQueue.count;
}

- (NSUInteger)eventCountFor:(NSString *)eventType {
    __block NSUInteger eventCount = 0;
    [self.eventQueue enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL *stop) {
        
        if ([event.eventType isEqualToString:eventType]) {
            eventCount++;
        }
    }];
    return eventCount;
}

- (NSDictionary *)eventAt:(NSUInteger)index {
    return [self.eventQueue objectAtIndex:index].toDictionary;
}

- (NSDictionary *)eventAt:(NSUInteger)index forType:(NSString *)eventType {
    NSArray *eventDatas = [self eventsFor:eventType];
    if (eventDatas) {
        return [eventDatas objectAtIndex:index];
    }
    return nil;
}

#pragma mark GrowingEventManagerObserver

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent* _Nullable)event; {
    [self.eventQueue addObject:event];
}

@end
