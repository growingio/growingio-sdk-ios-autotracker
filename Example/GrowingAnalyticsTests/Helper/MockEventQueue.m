//
//  TestHelper.m
//  GIOAutoTests
//
//  Created by GrowingIO on 28/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "MockEventQueue.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"

@interface MockEventQueue () <GrowingEventInterceptor>

@property (nonatomic, strong) NSMutableArray<GrowingBaseEvent *> *eventQueue;

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
        [[GrowingEventManager sharedInstance] addInterceptor:self];
        self.eventQueue = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)cleanQueue {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.eventQueue removeAllObjects];
    }];
}

- (NSArray<NSDictionary *> *)rawEventsFor:(NSString *)eventType {
    NSMutableArray<NSDictionary *> *rawEvents = [NSMutableArray array];
    NSArray<GrowingBaseEvent *> *events = [self eventsFor:eventType];
    for (GrowingBaseEvent *event in events) {
        [rawEvents addObject:event.toDictionary];
    }
    return rawEvents.count > 0 ? rawEvents : nil;
}

- (NSArray<GrowingBaseEvent *> *)eventsFor:(NSString *)eventType {
    NSMutableArray<GrowingBaseEvent *> *events = [NSMutableArray array];

    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [self.eventQueue enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL *stop) {
                if ([event.eventType isEqualToString:eventType]) {
                    [events addObject:event];
                }
            }];
        }
                  waitUntilDone:YES];

    return events.count > 0 ? events : nil;
}

- (GrowingBaseEvent *)lastEventFor:(NSString *)eventType {
    __block GrowingBaseEvent *last;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            NSArray<GrowingBaseEvent *> *reverse = self.eventQueue.reverseObjectEnumerator.allObjects;
            [reverse enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL *stop) {
                if ([event.eventType isEqualToString:eventType]) {
                    last = event;
                    *stop = YES;
                }
            }];
        }
                  waitUntilDone:YES];
    return last;
}

- (NSUInteger)eventCount {
    __block int count = 0;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            count = (int)self.eventQueue.count;
        }
                  waitUntilDone:YES];
    return count;
}

- (NSMutableArray *)allEvent {
    __block NSMutableArray *allevent = nil;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            allevent = self.eventQueue;
        }
                  waitUntilDone:YES];
    return allevent;
}

- (NSUInteger)eventCountFor:(NSString *)eventType {
    __block NSUInteger eventCount = 0;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [self.eventQueue enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL *stop) {
                if ([event.eventType isEqualToString:eventType]) {
                    eventCount++;
                }
            }];
        }
                  waitUntilDone:YES];
    return eventCount;
}

- (GrowingBaseEvent *)eventAt:(NSUInteger)index {
    __block GrowingBaseEvent *event = nil;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            event = [self.eventQueue objectAtIndex:index];
        }
                  waitUntilDone:YES];
    return event;
}

- (GrowingBaseEvent *)eventAt:(NSUInteger)index forType:(NSString *)eventType {
    __block GrowingBaseEvent *eventForType = nil;
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            [self.eventQueue enumerateObjectsUsingBlock:^(GrowingBaseEvent *event, NSUInteger idx, BOOL *stop) {
                if ([event.eventType isEqualToString:eventType]) {
                    eventForType = event;
                    *stop = YES;
                }
            }];
        }
                  waitUntilDone:YES];
    return eventForType;
}

#pragma mark GrowingEventManagerObserver

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *_Nullable)event {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.eventQueue addObject:event];
    }];
}

@end
