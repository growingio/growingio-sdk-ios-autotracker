//
//  NSData+GrowingHelper.h
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

@interface NSData (GrowingHelper)

- (NSString *)growingHelper_base64String;
- (NSString *)growingHelper_utf8String;
- (NSString *)growingHelper_md5String;
- (void)growingHelper_md5value:(unsigned char*)valueArray;
- (NSData *)growingHelper_LZ4String;
- (id)growingHelper_jsonObject;
- (NSArray *)growingHelper_arrayObject;
- (NSDictionary *)growingHelper_dictionaryObject;
- (NSData *)growingHelper_xorEncryptWithHint:(unsigned char)hint;

@end
