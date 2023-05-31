//
//  NSArray+GrowingHelper.m
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

#import "GrowingTrackerCore/Helpers/Foundation/NSArray+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/Foundation/NSData+GrowingHelper.h"

@implementation NSArray (GrowingHelper)

- (NSData *)growingHelper_jsonData {
    return [self growingHelper_jsonDataWithOptions:0];
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

@end
