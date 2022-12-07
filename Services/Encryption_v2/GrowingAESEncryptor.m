//
//  GrowingAESEncryptor.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/12/7.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "Services/Encryption_v2/GrowingAESEncryptor.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation GrowingAESEncryptor

+ (nullable NSData *)encryptData:(NSData *)data key:(NSString *)keyString iv:(NSString *)ivString {
    if (data.length == 0) {
        return nil;
    }
    NSUInteger keyLength = keyString.length;
    if (keyLength != kCCKeySizeAES128
        && keyLength != kCCKeySizeAES192
        && keyLength != kCCKeySizeAES256) {
        return nil;
    }
    NSData *key = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *iv = [ivString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key.bytes,
                                          keyLength,
                                          iv.bytes,
                                          data.bytes,
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        NSData *result = [NSData dataWithBytes:buffer length:encryptedSize];
        free(buffer);
        return result;
    }
    free(buffer);
    return nil;
}

@end
