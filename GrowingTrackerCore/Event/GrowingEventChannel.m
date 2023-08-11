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
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"

@implementation GrowingEventChannel

- (instancetype)initWithName:(NSString *)name
                  eventTypes:(NSArray<NSString *> *_Nullable)eventTypes
             persistenceType:(GrowingEventPersistenceType)persistenceType
             isRealtimeEvent:(BOOL)isRealtimeEvent {
    if (self = [super init]) {
        _name = name;
        _eventTypes = eventTypes;
        _persistenceType = persistenceType;
        _isRealtimeEvent = isRealtimeEvent;
        _isUploading = NO;
    }
    return self;
}

+ (instancetype)eventChannelWithName:(NSString *)name
                          eventTypes:(NSArray<NSString *> *_Nullable)eventTypes
                     isRealtimeEvent:(BOOL)isRealtimeEvent {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    GrowingEventPersistenceType type =
        trackConfiguration.useProtobuf ? GrowingEventPersistenceTypeProtobuf : GrowingEventPersistenceTypeJSON;
    return [[GrowingEventChannel alloc] initWithName:name
                                          eventTypes:eventTypes
                                     persistenceType:type
                                     isRealtimeEvent:isRealtimeEvent];
}

+ (instancetype)eventChannelWithName:(NSString *)name
                          eventTypes:(NSArray<NSString *> *_Nullable)eventTypes
                     persistenceType:(GrowingEventPersistenceType)persistenceType
                     isRealtimeEvent:(BOOL)isRealtimeEvent {
    return [[GrowingEventChannel alloc] initWithName:name
                                          eventTypes:eventTypes
                                     persistenceType:persistenceType
                                     isRealtimeEvent:isRealtimeEvent];
}

static NSMutableArray *eventChannels = nil;
+ (NSMutableArray<GrowingEventChannel *> *)eventChannels {
    if (!eventChannels) {
        eventChannels = [NSMutableArray array];
        NSArray *autotrackEventTypes = @[
            GrowingEventTypeVisit,
            GrowingEventTypePage,
            GrowingEventTypeViewClick,
            GrowingEventTypeViewChange,
            GrowingEventTypeAppClosed,
            @"FORM_SUBMIT", /* GrowingEventTypeFormSubmit */
            @"ACTIVATE"     /* GrowingEventTypeActivate */
        ];
        NSArray *trackEventTypes = @[GrowingEventTypeCustom, GrowingEventTypeLoginUserAttributes];
        [eventChannels addObject:[GrowingEventChannel eventChannelWithName:@"Autotrack"
                                                                eventTypes:autotrackEventTypes
                                                           persistenceType:GrowingEventPersistenceTypeJSON
                                                           isRealtimeEvent:NO]];
        [eventChannels addObject:[GrowingEventChannel eventChannelWithName:@"Track"
                                                                eventTypes:trackEventTypes
                                                           persistenceType:GrowingEventPersistenceTypeJSON
                                                           isRealtimeEvent:YES]];
        [eventChannels addObject:[GrowingEventChannel eventChannelWithName:@"Autotrack-Protobuf"
                                                                eventTypes:autotrackEventTypes
                                                           persistenceType:GrowingEventPersistenceTypeProtobuf
                                                           isRealtimeEvent:NO]];
        [eventChannels addObject:[GrowingEventChannel eventChannelWithName:@"Track-Protobuf"
                                                                eventTypes:trackEventTypes
                                                           persistenceType:GrowingEventPersistenceTypeProtobuf
                                                           isRealtimeEvent:YES]];
    }
    return eventChannels;
}

@end
