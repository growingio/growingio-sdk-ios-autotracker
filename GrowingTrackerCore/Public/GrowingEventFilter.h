//
// GrowingEventFilter.h
// GrowingAnalytics
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

// 过滤 VIEW_CLICK、VIEW_CHANGE 事件的掩码值
extern NSUInteger const GrowingFilterClickChange;

typedef NS_OPTIONS(NSUInteger, GrowingFilterEvent) {
    GrowingFilterEventVisit = (1 << 0),
    GrowingFilterEventCustom = (1 << 1),
    GrowingFilterEventLoginUserAttributes = (1 << 2),
    GrowingFilterEventAppClosed = (1 << 3),
    GrowingFilterEventPage = (1 << 4),
    GrowingFilterEventViewClick = (1 << 5),
    GrowingFilterEventViewChange = (1 << 6),
    GrowingFilterEventFormSubmit = (1 << 7),
    GrowingFilterEventActivate = (1 << 8)
};

@interface GrowingEventFilter : NSObject

+ (NSArray *)filterEventItems;

// 通过类型名称获取其对应的掩码值
+ (NSUInteger)getFilterMask:(NSString *)typeName;

+ (BOOL)isFilterEvent:(NSString *)eventType;

+ (NSString *)getFilterEventLog;

@end
