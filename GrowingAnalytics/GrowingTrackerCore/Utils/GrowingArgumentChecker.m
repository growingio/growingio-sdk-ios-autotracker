//
//  GrowingArgumentChecker.m
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/13.
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

#import "GrowingArgumentChecker.h"
#import "NSString+GrowingHelper.h"
#import "GrowingLogMacros.h"
#import "GrowingLogger.h"

@implementation GrowingArgumentChecker
+ (BOOL)isIllegalEventName:(NSString *)eventName {
    if (![eventName isKindOfClass:[NSString class]]) {
        GIOLogError(@"event name is not kind of NSString class");
        return YES;
    }
    
    if ([NSString growingHelper_isBlankString:eventName]) {
        GIOLogError(@"event name is NULL");
        return YES;
    }

    return NO;
}

+ (BOOL)isIllegalAttributes:(NSDictionary *)attributes {
    if (attributes == nil) {
        GIOLogError(@"attributes is NULL");
        return YES;
    }

    if (![attributes isKindOfClass:NSDictionary.class]) {
        GIOLogError(@"attributes is not kind of NSDictionary class");
        return YES;
    }

    for (NSString *key in attributes) {
        if (![key isKindOfClass:NSString.class]) {
            GIOLogError(@"Key %@ is not kind of NSString class", key);
            return YES;
        }

        NSString *stringValue = attributes[key];

        if (![stringValue isKindOfClass:NSString.class]) {
            GIOLogError(@"value for key %@ is not kind of NSString class", stringValue);
            return YES;
        }
    }

    return NO;
}

@end
