//
//  GrowingEventCounter.m
//  GrowingTracker
//
//  Created by GrowingIO on 2017/1/14.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "GrowingEventCounter.h"
#import "GrowingFileStorage.h"
#import "GrowingEvent.h"

static NSString * _Nonnull const kGrowingEventSequenceName = @"eventsequenceid";

static NSString * _Nonnull const kGrowingGlobalEventIdKey = @"global_seq";
static NSString * _Nonnull const kGrowingEventsSequenceIdKey = @"events_seq_id";

static NSInteger const kEventCounterStep = 1;

@interface GrowingEventCounter()

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *> *eventSequenceIdMap;

@property (nonatomic, strong) GrowingFileStorage *eventCounterStorage;

@end

@implementation GrowingEventCounter

- (instancetype)init {
    if (self = [super init]) {
        self.eventCounterStorage = [[GrowingFileStorage alloc] initWithName:kGrowingEventSequenceName];
    }
    return self;
}

- (void)calculateSequenceIdForEvent:(GrowingEvent *)event {
    
    if ([event respondsToSelector:@selector(nextEventSequenceWithBase:andStep:)]) {
        NSString *key = event.eventTypeKey;
        NSNumber *eventNum = (NSNumber *)self.eventSequenceIdMap[key];
        eventNum = eventNum ? eventNum : @0;
        NSInteger result = [event nextEventSequenceWithBase:eventNum.integerValue andStep:kEventCounterStep];
        NSNumber *resultNum = [NSNumber numberWithInteger:result];
        
        self.eventSequenceIdMap[key] = resultNum;
        [self.eventCounterStorage setDictionary:self.eventSequenceIdMap forKey:kGrowingEventsSequenceIdKey];
    }
    
    if ([event respondsToSelector:@selector(nextGlobalSequenceWithBase:andStep:)]) {
        NSNumber *eventNum = (NSNumber *)self.eventSequenceIdMap[kGrowingGlobalEventIdKey];
        eventNum = eventNum ? eventNum : @0;
        NSInteger result = [event nextGlobalSequenceWithBase:eventNum.integerValue andStep:kEventCounterStep];
        NSNumber *resultNum = [NSNumber numberWithInteger:result];

        self.eventSequenceIdMap[kGrowingGlobalEventIdKey] = resultNum;
        [self.eventCounterStorage setDictionary:self.eventSequenceIdMap forKey:kGrowingEventsSequenceIdKey];
    }
}

- (NSMutableDictionary <NSString *,NSNumber *> *)eventSequenceIdMap {
    if (!_eventSequenceIdMap) {
        NSDictionary *sequenceDict = [self.eventCounterStorage dictionaryForKey:kGrowingEventsSequenceIdKey];
        if (!sequenceDict) {
            sequenceDict = [NSDictionary dictionary];
        }
        _eventSequenceIdMap = [NSMutableDictionary dictionaryWithDictionary:sequenceDict];
    }
    return _eventSequenceIdMap;
}

@end
