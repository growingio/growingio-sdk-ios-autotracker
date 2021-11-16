//
//  NSDictionary+GrowingHelper.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/9/4.
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


#import "NSDictionary+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "GrowingLogger.h"


@implementation NSDictionary (GrowingHelper)

- (NSData *)growingHelper_jsonData {
    return [self growingHelper_jsonDataWithOptions:0];
}

- (NSString *)growingHelper_beautifulJsonString {
    NSData *jsonData = [self growingHelper_jsonDataWithOptions:NSJSONWritingPrettyPrinted];
    NSString *jsonString;

    if (!jsonData) {
        return nil;
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSString *beautifulJsonString = @"╔═══════════════════════════════════════════════════════════════════════════════════════\n";
    NSArray *lines = [jsonString componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        beautifulJsonString = [NSString stringWithFormat:@"%@║ %@\n", beautifulJsonString, line];
    }
    beautifulJsonString = [beautifulJsonString stringByAppendingString:@"╚═══════════════════════════════════════════════════════════════════════════════════════"];
    return beautifulJsonString;
}

- (NSData *)growingHelper_jsonDataWithOptions:(NSJSONWritingOptions)options {
    NSData *jsonData = nil;
    @try {
        NSError *error = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:self options:options error:&error];
        if (error != nil) {
            jsonData = nil;
        }
    } @catch (NSException *exception) {
        jsonData = nil;
    }
    
    return jsonData;
}

- (NSString *)growingHelper_jsonString {
    return [[self growingHelper_jsonData] growingHelper_utf8String];
}

- (BOOL)isValidDictVariable {
    for (NSString *k in self) {
        NSString *key = k;
        if (![self[key] isKindOfClass:[NSString class]] && ![self[key] isKindOfClass:[NSNumber class]]) {
            GIOLogError(@"%@ value is not NSString class", key);
            return NO;
        }
    }
    return YES;
}

- (NSString *)growingHelper_queryString {
    NSString *query = @"";

    if (self.count < 1) {
        return query;
    }

    for (NSString *key in self) {
        if (query.length == 0) {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, self[key]]];
        } else {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, self[key]]];
        }
    }

    return query;
}

- (int)intForKey:(NSString *)key fallback:(int)value {
    id obj = [self valueForKey:key];
    if (obj && ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]])) {
        NSNumber *number = obj;
        return number.intValue;
    }
    return value;
}

- (long long)longlongForKey:(NSString *)key fallback:(long long)value {
    id obj = [self valueForKey:key];
    if (obj && ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]])) {
        NSNumber *number = obj;
        return number.longLongValue;
    }
    return value;
}

@end
