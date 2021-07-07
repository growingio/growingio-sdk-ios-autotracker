//
// GrowingEventFilter.h
// Pods
//
//  Created by rq on 2021/7/6.
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


#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, GrowingFilterEvent) {
    
    GrowingFilterEventVisit                     = (1 << 0),
    GrowingFilterEventCustom                    = (1 << 1),
    GrowingFilterEventVisitorAttributes         = (1 << 2),
    GrowingFilterEventLoginUserAttributes       = (1 << 3),
    GrowingFilterEventConversionVariables       = (1 << 4),
    GrowingFilterEventAppClosed                 = (1 << 5),
    GrowingFilterEventPage                      = (1 << 6),
    GrowingFilterEventPageAttributes            = (1 << 7),
    GrowingFilterEventViewClick                 = (1 << 8),
    GrowingFilterEventViewChange                = (1 << 9),
    GrowingFilterEventFormSubmit                = (1 << 10),
    GrowingFilterEventReengage                  = (1 << 11),
};


@interface GrowingEventFilter : NSObject

extern NSUInteger const GrowingFilterClickChangeSubmit;

// 通过类型名称获取其对应的掩码值
+ (NSUInteger)getFilterMask:(NSString *)typeName;

+ (BOOL)isFilterEvent:(NSUInteger)filterEventMask
             eventType:(NSString *)eventType;


@end

