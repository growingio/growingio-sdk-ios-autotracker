//
//  GrowingEventTimer.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/5.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Timer/GrowingEventTimer.h"
#import <objc/runtime.h>
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingULTimeUtil.h"

static NSString *const kGrowingEventDuration = @"event_duration";

@interface GrowingEventTimer ()

@property (class, nonatomic, strong) NSMutableDictionary *timers;

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) double duration;

@end

@implementation GrowingEventTimer

#pragma mark - Public Method

+ (nullable NSString *)trackTimerStart:(NSString *)eventName {
    BOOL dataCollectionEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled;
    if (!dataCollectionEnabled) {
        return nil;
    }

    double currentTime = [GrowingULTimeUtil currentSystemTimeMillis];

    GrowingEventTimer *timer = [[GrowingEventTimer alloc] init];
    timer.eventName = eventName;
    timer.startTime = currentTime;
    timer.duration = 0;

    NSString *timerId = [NSString stringWithFormat:@"%@_%@", eventName, NSUUID.UUID.UUIDString];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        BOOL dataCollectionEnabled =
            GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionEnabled;
        if (!dataCollectionEnabled) {
            return;
        }

        [GrowingEventTimer.timers setObject:timer forKey:timerId];
    }];
    return timerId;
}

+ (void)trackTimerPause:(NSString *)timerId {
    double currentTime = [GrowingULTimeUtil currentSystemTimeMillis];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingEventTimer *timer = [GrowingEventTimer.timers objectForKey:timerId];
        if (!timer) {
            return;
        }
        if (timer.isPaused) {
            return;
        }
        timer.duration += [self durationFrom:timer.startTime to:currentTime];
        timer.startTime = 0;
    }];
}

+ (void)trackTimerResume:(NSString *)timerId {
    double currentTime = [GrowingULTimeUtil currentSystemTimeMillis];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingEventTimer *timer = [GrowingEventTimer.timers objectForKey:timerId];
        if (!timer) {
            return;
        }
        if (!timer.isPaused) {
            return;
        }
        timer.startTime = currentTime;
    }];
}

+ (void)trackTimerEnd:(NSString *)timerId withAttributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes {
    double currentTime = [GrowingULTimeUtil currentSystemTimeMillis];

    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingEventTimer *timer = [GrowingEventTimer.timers objectForKey:timerId];
        if (!timer) {
            return;
        }

        double duration = [self durationFrom:timer.startTime to:currentTime];
        duration += timer.duration;
        NSString *eventName = timer.eventName.copy;
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        if (attributes) {
            [attr addEntriesFromDictionary:attributes];
        }
        [attr setObject:[NSString stringWithFormat:@"%.3f", duration / 1000.0] forKey:kGrowingEventDuration];
        [GrowingEventGenerator generateCustomEvent:eventName attributes:attr];

        [GrowingEventTimer.timers removeObjectForKey:timerId];
    }];
}

+ (void)removeTimer:(NSString *)timerId {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [GrowingEventTimer.timers removeObjectForKey:timerId];
    }];
}

+ (void)clearAllTimers {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [GrowingEventTimer.timers removeAllObjects];
    }];
}

+ (void)handleAllTimersPause {
    double currentTime = [GrowingULTimeUtil currentSystemTimeMillis];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        for (GrowingEventTimer *timer in GrowingEventTimer.timers.allValues) {
            if (timer.isPaused) {
                continue;
            }
            timer.duration += [self durationFrom:timer.startTime to:currentTime];
            timer.startTime = currentTime;
        }
    }];
}

+ (void)handleAllTimersResume {
    double currentTime = [GrowingULTimeUtil currentSystemTimeMillis];
    [GrowingDispatchManager dispatchInGrowingThread:^{
        for (GrowingEventTimer *timer in GrowingEventTimer.timers.allValues) {
            if (timer.isPaused) {
                continue;
            }
            timer.startTime = currentTime;
        }
    }];
}

#pragma mark - Private Method

- (BOOL)isPaused {
    return self.startTime == 0;
}

+ (double)durationFrom:(double)startTime to:(double)endTime {
    if (startTime <= 0) {
        return 0;
    }
    double duration = endTime - startTime;
    return (duration > 0 && duration < 24 * 60 * 60 * 1000LL) ? duration : 0;
}

#pragma mark - Getter & Setter

+ (NSMutableDictionary *)timers {
    NSMutableDictionary *_timers = objc_getAssociatedObject(self, _cmd);
    if (!_timers) {
        _timers = [NSMutableDictionary dictionary];
        [self setTimers:_timers];
    }
    return _timers;
}

+ (void)setTimers:(NSMutableDictionary *)timers {
    objc_setAssociatedObject(self, @selector(timers), timers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
