//
//  NSDictionary+GrowingHelper.h
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


#import <Foundation/Foundation.h>

@interface NSDictionary (GrowingHelper)

- (NSData *)growingHelper_jsonData;

- (NSString *)growingHelper_beautifulJsonString;

- (NSData *)growingHelper_jsonDataWithOptions:(NSJSONWritingOptions)options;

- (NSString *)growingHelper_jsonString;

- (NSString *)growingHelper_queryString;

- (int)growingHelper_intForKey:(NSString *)key fallback:(int)value;

- (long long)growingHelper_longlongForKey:(NSString *)key fallback:(long long)value;

@end
