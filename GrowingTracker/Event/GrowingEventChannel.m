//
//  GrowingEventChannel.m
//  GrowingTracker
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


#import "GrowingEventChannel.h"
#import "GrowingNetworkConfig.h"
#import "GrowingEvent.h"

@implementation GrowingEventChannel

- (instancetype)initWithTypes:(NSArray<NSString *> *)eventTypes
                  urlTemplate:(NSString *)urlTemplate
                isCustomEvent:(BOOL)isCustomEvent
                  isUploading:(BOOL)isUploading {
    if (self = [super init]) {
        _eventTypes = eventTypes;
        _urlTemplate = urlTemplate;
        _isCustomEvent = isCustomEvent;
        _isUploading = isUploading;
    }
    return self;
}

+ (instancetype)eventChannelWithEventTypes:(NSArray<NSString *> *)eventTypes
                               urlTemplate:(NSString *)urlTemplate
                             isCustomEvent:(BOOL)isCustomEvent {
    return [[GrowingEventChannel alloc] initWithTypes:eventTypes
                                          urlTemplate:urlTemplate
                                        isCustomEvent:isCustomEvent
                                          isUploading:NO];
}

+ (NSArray<GrowingEventChannel *> *)buildAllEventChannels {
    
    return @[
        [GrowingEventChannel eventChannelWithEventTypes:@[kEventTypeKeyVisit, kEventTypeKeyPage, kEventTypeKeyClose]
                                            urlTemplate:kGrowingEventApiTemplate_PV
                                          isCustomEvent:NO],
        [GrowingEventChannel eventChannelWithEventTypes:@[kEventTypeKeyCustom, kEventTypeKeyPageVariable, kEventTypeKeyConversionVariable, kEventTypeKeyPeopleVariable, kEventTypeKeyVisitor]
                                            urlTemplate:kGrowingEventApiTemplate_Custom
                                          isCustomEvent:YES],
        [GrowingEventChannel eventChannelWithEventTypes:nil
                                            urlTemplate:kGrowingEventApiTemplate_Other
                                          isCustomEvent:NO],
    ];
}

+ (NSDictionary *)eventChannelMapFromAllChannels:(NSArray <GrowingEventChannel *> *)channels {
    
    NSArray *allEventChannels = channels;
    if (!allEventChannels.count) {
        allEventChannels = [self buildAllEventChannels];
    }
    
    return @{
        kEventTypeKeyVisit: allEventChannels[0],
        kEventTypeKeyPage: allEventChannels[0],
        kEventTypeKeyClose: allEventChannels[0],
        kEventTypeKeyCustom: allEventChannels[1],
        kEventTypeKeyPageVariable: allEventChannels[1],
        kEventTypeKeyConversionVariable: allEventChannels[1],
        kEventTypeKeyPeopleVariable: allEventChannels[1],
        kEventTypeKeyVisitor: allEventChannels[1],
    };
}

+ (GrowingEventChannel *)otherEventChannelFromAllChannels:(NSArray <GrowingEventChannel *> *)allEventChannels {
    if (!allEventChannels.count) {
        return [self buildAllEventChannels].lastObject;
    }
    
    return allEventChannels.lastObject;
}

@end
