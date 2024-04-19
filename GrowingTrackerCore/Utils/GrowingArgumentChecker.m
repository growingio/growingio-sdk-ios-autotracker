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

#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogMacros.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

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

    for (NSString *key in attributes.allKeys) {
        if (![key isKindOfClass:NSString.class]) {
            GIOLogError(@"Key %@ is not kind of NSString class", key);
            return YES;
        }
    }

    return NO;
}

+ (BOOL)isIllegalKeys:(NSArray *)keys {
    if (keys == nil) {
        GIOLogError(@"keys is NULL");
        return YES;
    }

    if (![keys isKindOfClass:NSArray.class]) {
        GIOLogError(@"keys is not kind of NSArray class");
        return YES;
    }

    for (NSString *key in keys) {
        if (![key isKindOfClass:NSString.class]) {
            GIOLogError(@"Key %@ is not kind of NSString class", key);
            return YES;
        }
    }

    return NO;
}

+ (NSDictionary<NSString *, NSString *> *)serializableAttributes:(NSDictionary *)properties {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in properties.allKeys) {
        id value = properties[key];
        if ([value isKindOfClass:[NSString class]]) {
            result[key] = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            result[key] = ((NSNumber *)value).stringValue;
        } else if ([value isKindOfClass:[NSDate class]]) {
            NSDateFormatter *dateFormatter = [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            result[key] = [dateFormatter stringFromDate:value];
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
            NSMutableArray *array = [NSMutableArray array];
            for (id subValue in value) {
                if ([subValue isKindOfClass:[NSString class]]) {
                    [array addObject:subValue];
                } else if ([subValue isKindOfClass:[NSNumber class]]) {
                    [array addObject:((NSNumber *)subValue).stringValue];
                } else if ([subValue isKindOfClass:[NSDate class]]) {
                    NSDateFormatter *dateFormatter = [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                    [array addObject:[dateFormatter stringFromDate:subValue]];
                } else {
                    // 只解一层，不考虑array嵌套array
                    [array addObject:((NSObject *)subValue).description];
                }
            }
            result[key] = [array componentsJoinedByString:@"||"];
        } else {
            result[key] = ((NSObject *)value).description;
        }
    }
    return [result copy];
}

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)dateFormat {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    });
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

@end
