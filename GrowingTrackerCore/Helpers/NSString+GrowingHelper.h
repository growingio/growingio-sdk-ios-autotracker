//
//  NSString+GrowingHelper.h
//  GrowingTracker
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

@interface NSString (GrowingHelper)

- (NSData *)growingHelper_uft8Data;

- (id)growingHelper_jsonObject;

- (NSDictionary *)growingHelper_dictionaryObject;
- (NSDictionary *)growingHelper_queryObject;

- (NSString *)growingHelper_safeSubStringWithLength:(NSInteger)length;

- (NSString *)growingHelper_sha1;

- (BOOL)growingHelper_isLegal;

- (BOOL)growingHelper_isValidU;

// 若用户设置加密method 则返回加密后的string,否则返回原值
- (NSString *)growingHelper_encryptString;

- (instancetype)initWithJsonObject_growingHelper:(id)obj;

+ (BOOL)growingHelper_isBlankString:(NSString *)string;

- (NSString *)absoluteURLStringWithPath:(NSString *)path andQuery:(NSDictionary *)query;

- (NSDictionary *)convertToDictFromPasteboard;

@end
