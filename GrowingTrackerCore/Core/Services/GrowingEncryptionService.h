//
// GrowingEncryptionService.h
// GrowingAnalytics
//
//  Created by sheng on 2021/6/17.
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


#import "GrowingBaseService.h"

@protocol GrowingEncryptionService <GrowingBaseService>

@optional

/// event相关数据在上传之前的加密处理
/// @param data 将要加密的NSData对象
/// @param hint 盐值
- (NSData *_Nonnull)encryptEventData:(NSData *_Nonnull)data factor:(unsigned char)hint;

/// 本地数据存储加密（如当天已使用数据网络上传的数据量等）
/// @param data 将要加密的NSData对象
- (NSData *_Nonnull)encryptLocalData:(NSData *_Nonnull)data;

/// 本地数据存储解密（如当天已使用数据网络上传的数据量等）
/// @param data 将要解密的NSData对象
- (NSData *_Nonnull)decryptLocalData:(NSData *_Nonnull)data;

@end
