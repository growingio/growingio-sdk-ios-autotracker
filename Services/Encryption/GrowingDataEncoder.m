//
// GrowingDataEncoder.m
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

#import "Services/Encryption/GrowingDataEncoder.h"

GrowingService(GrowingEncryptionService, GrowingDataEncoder)

@implementation GrowingDataEncoder

- (NSData *_Nonnull)encryptEventData:(NSData *_Nonnull)data factor:(unsigned char)hint {
    NSMutableData *result = [[NSMutableData alloc] initWithLength:data.length];
    const unsigned char *p = data.bytes;
    unsigned char *q = result.mutableBytes;

    for (NSUInteger i = 0; i < data.length; i++, p++, q++) {
        *q = (*p ^ hint);
    }
    return result;
}

@end
