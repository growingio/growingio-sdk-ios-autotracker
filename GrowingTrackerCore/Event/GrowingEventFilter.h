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

typedef NS_OPTIONS(NSUInteger, GrowingFilterEventType) {
    /**
     *  0...000000000001 visit
     */
    GROWING_VISIT                     = (1 << 0),
    /**
     *  0...000000000010 custom
     */
    GROWING_CUSTOM                    = (1 << 1),
    /**
     *  0...000000000100 visitor attributes
     */
    GROWING_VISITOR_ATTRIBUTES        = (1 << 2),
    /**
     *  0...000000001000 login user attributes
     */
    GROWING_LOGIN_USER_ATTRIBUTES     = (1 << 3),
    /**
     *  0...000000010000 conversion variables
     */
    GROWING_CONVERSION_VARIABLES      = (1 << 4),
    /**
     *  0...000000100000 app closed
     */
    GROWING_APP_CLOSED                = (1 << 5),
    /**
     *  0...000001000000 page
     */
    GROWING_PAGE                      = (1 << 6),
    /**
     *  0...000010000000 page attributes
     */
    GROWING_PAGE_ATTRIBUTES           = (1 << 7),
    /**
     *  0...000100000000 view click
     */
    GROWING_VIEW_CLICK                = (1 << 8),
    /**
     *  0...001000000000 view change
     */
    GROWING_VIEW_CHANGE               = (1 << 9),
    /**
     *  0...010000000000 form submit
     */
    GROWING_FORM_SUBMIT               = (1 << 10),
    /**
     *  0...100000000000 reengage
     */
    GROWING_REENGAGE                  = (1 << 11),
};


@interface GrowingEventFilter : NSObject

extern NSUInteger const GrowingFilterClickChangeSubmit;

// 通过类型名称获取其对应的掩码值
+ (NSUInteger)getFilterMask:(NSString *)typeName;

@end

