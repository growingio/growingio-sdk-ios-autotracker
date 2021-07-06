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

+ (NSUInteger)getFilterMask:(NSString *)typeName {
    
    NSArray *items = @[@"VISIT", @"CUSTOM", @"VISITOR_ATTRIBUTES", @"LOGIN_USER_ATTRIBUTES",
                       @"CONVERSION_VARIABLES", @"APP_CLOSED", @"PAGE", @"PAGE_ATTRIBUTES",
                       @"VIEW_CLICK", @"VIEW_CHANGE", @"FORM_SUBMIT", @"REENGAGE"];

    NSUInteger item = [items indexOfObject : typeName];

    switch (item) {
        case 0:
            return  VISIT;
        case 1:
            return  CUSTOM;
        case 2:
            return  VISITOR_ATTRIBUTES;
        case 3:
            return  LOGIN_USER_ATTRIBUTES;
        case 4:
            return  CONVERSION_VARIABLES;
        case 5:
            return  APP_CLOSED;
        case 6:
            return  PAGE;
        case 7:
            return  PAGE_ATTRIBUTES;
        case 8:
            return  VIEW_CLICK;
        case 9:
            return  VIEW_CHANGE;
        case 10:
            return  FORM_SUBMIT;
        case 11:
            return  REENGAGE;
        default :
            return 0;
        
    }
    return 0;
    
}

+ (NSUInteger)getFilterClickChangeSubmit {
    NSUInteger const filterClickChangeSubmit = (VIEW_CLICK | VIEW_CHANGE | FORM_SUBMIT);
    return filterClickChangeSubmit;
}

@end
