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

@implementation GrowingEventFilter

//过滤 VIEW_CLICK、VIEW_CHANGE、FORM_SUBMIT 事件的掩码值
NSUInteger const GrowingFilterClickChangeSubmit = (GrowingFilterEventViewClick | GrowingFilterEventViewChange | GrowingFilterEventFormSubmit);

+ (NSUInteger)getFilterMask:(NSString *)typeName {
    
    NSArray *items = @[@"VISIT", @"CUSTOM", @"VISITOR_ATTRIBUTES", @"LOGIN_USER_ATTRIBUTES",
                       @"CONVERSION_VARIABLES", @"APP_CLOSED", @"PAGE", @"PAGE_ATTRIBUTES",
                       @"VIEW_CLICK", @"VIEW_CHANGE", @"FORM_SUBMIT", @"REENGAGE"];

    NSUInteger item = [items indexOfObject : typeName];

    switch (item) {
        case 0:
            return  GrowingFilterEventVisit;
        case 1:
            return  GrowingFilterEventCustom;
        case 2:
            return  GrowingFilterEventVisitorAttributes;
        case 3:
            return  GrowingFilterEventLoginUserAttributes;
        case 4:
            return  GrowingFilterEventConversionVariables;
        case 5:
            return  GrowingFilterEventAppClosed;
        case 6:
            return  GrowingFilterEventPage;
        case 7:
            return  GrowingFilterEventPageAttributes;
        case 8:
            return  GrowingFilterEventViewClick;
        case 9:
            return  GrowingFilterEventViewChange;
        case 10:
            return  GrowingFilterEventFormSubmit;
        case 11:
            return  GrowingFilterEventReengage;
        default :
            return 0;
        
    }
    return 0;
}

+ (BOOL)isFilterEvent:(NSUInteger)filterEventMask
            eventType:(NSString *)eventType {
    
    NSUInteger typeMask = [GrowingEventFilter getFilterMask:eventType];
    if(filterEventMask && (filterEventMask & typeMask) > 0 ) {
        return true;
    }
    return false;
}


@end
