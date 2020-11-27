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
#import "GrowingTrackEventType.h"
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
    // TODO:这里删除了page,pageAttributes
    return @[
        [GrowingEventChannel eventChannelWithEventTypes:@[GrowingEventTypeVisit, GrowingEventTypeAppClosed]
                                            urlTemplate:kGrowingEventApiTemplate_PV
                                          isCustomEvent:NO],
        [GrowingEventChannel eventChannelWithEventTypes:@[GrowingEventTypeCustom, GrowingEventTypeConversionVariables, GrowingEventTypeLoginUserAttributes, GrowingEventTypeVisitorAttributes]
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
    // TODO: 添加page以及pageAttributes类型
    return @{
        GrowingEventTypeVisit: allEventChannels[0],
//        kEventTypeKeyPage: allEventChannels[0],
        GrowingEventTypeAppClosed: allEventChannels[0],
        GrowingEventTypeCustom: allEventChannels[1],
//        kEventTypeKeyPageAttributes: allEventChannels[1],
        GrowingEventTypeConversionVariables: allEventChannels[1],
        GrowingEventTypeLoginUserAttributes: allEventChannels[1],
        GrowingEventTypeVisitorAttributes: allEventChannels[1],
    };
}

+ (GrowingEventChannel *)otherEventChannelFromAllChannels:(NSArray <GrowingEventChannel *> *)allEventChannels {
    if (!allEventChannels.count) {
        return [self buildAllEventChannels].lastObject;
    }
    
    return allEventChannels.lastObject;
}

@end
