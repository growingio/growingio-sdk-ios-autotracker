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
#import "GrowingConfigurationManager.h"

NSUInteger const GrowingFilterClickChangeSubmit = (GrowingFilterEventViewClick | GrowingFilterEventViewChange | GrowingFilterEventFormSubmit);

@implementation GrowingEventFilter

+ (NSArray *)filterEventItems {
    static NSArray *_filterEventItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _filterEventItems = @[@"VISIT", @"CUSTOM", @"VISITOR_ATTRIBUTES", @"LOGIN_USER_ATTRIBUTES",
                              @"CONVERSION_VARIABLES", @"APP_CLOSED", @"PAGE", @"PAGE_ATTRIBUTES",
                              @"VIEW_CLICK", @"VIEW_CHANGE", @"FORM_SUBMIT", @"REENGAGE"];
    });
    return _filterEventItems;
}

+ (NSUInteger)getFilterMask:(NSString *)typeName {
    NSUInteger index = [[[self class] filterEventItems] indexOfObject : typeName];
    return index == NSNotFound ? 0 : 1 << index;
}

+ (BOOL)isFilterEvent:(NSString *)eventType {
    NSUInteger filterEventMask = GrowingConfigurationManager.sharedInstance.trackConfiguration.filterEventMask;
    NSUInteger typeMask = [GrowingEventFilter getFilterMask:eventType];
    if(filterEventMask && (filterEventMask & typeMask) > 0 ) {
        return true;
    }
    return false;
}

+ (NSString*) getFilterEventLog {
    NSUInteger filterEventMask = [GrowingConfigurationManager sharedInstance].trackConfiguration.filterEventMask;
    NSString* logStr = @"";
    NSInteger index = 0;
    
    while(filterEventMask > 0){
        if(filterEventMask % 2 > 0) {
            logStr = [logStr stringByAppendingFormat:@"%@",[[[self class] filterEventItems] objectAtIndex:index]];
            logStr = [logStr stringByAppendingFormat:@"%@",@","];
        }
        filterEventMask = filterEventMask / 2;
        index++;
    }
    
    if([logStr length] > 0){
        logStr = [logStr substringToIndex:([logStr length]-1)];
        logStr = [logStr stringByAppendingFormat:@"%@", @" not tracking ..."];
    }
    return logStr;
}

@end
