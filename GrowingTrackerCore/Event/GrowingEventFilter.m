//
// GrowingEventFilter.m
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


#import "GrowingEventFilter.h"

NSUInteger const GrowingFilterClickChangeSubmit = (GrowingFilterEventViewClick | GrowingFilterEventViewChange | GrowingFilterEventFormSubmit);

@implementation GrowingEventFilter

+ (NSUInteger)getFilterMask:(NSString *)typeName {
    NSArray *items = @[@"VISIT", @"CUSTOM", @"VISITOR_ATTRIBUTES", @"LOGIN_USER_ATTRIBUTES",
                       @"CONVERSION_VARIABLES", @"APP_CLOSED", @"PAGE", @"PAGE_ATTRIBUTES",
                       @"VIEW_CLICK", @"VIEW_CHANGE", @"FORM_SUBMIT", @"REENGAGE"];

    NSUInteger index = [items indexOfObject:typeName];
    return index == NSNotFound ? 0 : 1 << index;
}

+ (BOOL)isFilterEvent:(NSUInteger)filterEventMask
            eventType:(NSString *)eventType {
    NSUInteger typeMask = [GrowingEventFilter getFilterMask:eventType];
    return filterEventMask && (filterEventMask & typeMask) > 0;
}

@end
