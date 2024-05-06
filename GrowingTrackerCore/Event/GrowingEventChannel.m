//
//  GrowingEventChannel.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/4/14.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"

@implementation GrowingEventChannel

- (instancetype)initWithTypes:(NSArray<NSString *> *)eventTypes
                isCustomEvent:(BOOL)isCustomEvent
                  isUploading:(BOOL)isUploading {
    if (self = [super init]) {
        _eventTypes = eventTypes;
        _isCustomEvent = isCustomEvent;
        _isUploading = isUploading;
    }
    return self;
}

+ (instancetype)eventChannelWithEventTypes:(NSArray<NSString *> *)eventTypes isCustomEvent:(BOOL)isCustomEvent {
    return [[GrowingEventChannel alloc] initWithTypes:eventTypes isCustomEvent:isCustomEvent isUploading:NO];
}

static NSMutableArray *eventChannels = nil;

+ (NSMutableArray<GrowingEventChannel *> *)eventChannels {
    if (!eventChannels) {
        eventChannels = [NSMutableArray array];
        [eventChannels addObject:[GrowingEventChannel eventChannelWithEventTypes:@[
                           GrowingEventTypeVisit,
                           GrowingEventTypeAppClosed,
                           GrowingEventTypePage
                       ]
                                                                   isCustomEvent:NO]];
        [eventChannels addObject:[GrowingEventChannel eventChannelWithEventTypes:@[
                           GrowingEventTypeCustom,
                           GrowingEventTypeConversionVariables,
                           GrowingEventTypeLoginUserAttributes,
                           GrowingEventTypeVisitorAttributes
                       ]
                                                                   isCustomEvent:YES]];
    }
    return eventChannels;
}

+ (NSArray<GrowingEventChannel *> *)buildAllEventChannels {
    NSMutableArray *channels = [[self eventChannels] mutableCopy];
    eventChannels = nil;
    [channels addObject:[GrowingEventChannel eventChannelWithEventTypes:nil isCustomEvent:NO]];
    return channels;
}

+ (NSDictionary *)eventChannelMapFromAllChannels:(NSArray<GrowingEventChannel *> *)channels {
    NSArray *allEventChannels = channels;
    if (!allEventChannels.count) {
        allEventChannels = [self buildAllEventChannels];
    }
    // TODO: 添加page以及pageAttributes类型
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    for (GrowingEventChannel *obj in channels) {
        for (NSString *key in obj.eventTypes) {
            [dictM setObject:obj forKey:key];
        }
    }
    return dictM;
}

+ (GrowingEventChannel *)otherEventChannelFromAllChannels:(NSArray<GrowingEventChannel *> *)allEventChannels {
    if (!allEventChannels.count) {
        return [self buildAllEventChannels].lastObject;
    }

    return allEventChannels.lastObject;
}

@end
