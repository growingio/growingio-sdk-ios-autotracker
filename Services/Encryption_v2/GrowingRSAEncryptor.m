//
//  @author: ideawu
//  @link: https://github.com/ideawu/Objective-C-RSA
//
//  GrowingRSAEncryptor.m
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

#import "Services/Encryption_v2/GrowingRSAEncryptor.h"
#import <Security/Security.h>

@implementation GrowingRSAEncryptor

+ (NSString *)encryptString:(NSString *)string publicKey:(NSString *)pubKey {
    NSData *encode = [GrowingRSAEncryptor encryptData:[string dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    return [encode base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
}

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey {
    if (!data || !pubKey) {
        return nil;
    }
    SecKeyRef keyRef = [GrowingRSAEncryptor addPublicKey:pubKey];
    if (!keyRef) {
        return nil;
    }
    return [GrowingRSAEncryptor encryptData:data withKeyRef:keyRef isSign:NO];
}

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef isSign:(BOOL)isSign {
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;

    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }

        size_t outlen = block_size;
        OSStatus status = noErr;

        if (isSign) {
            status = SecKeyRawSign(keyRef, kSecPaddingPKCS1, srcbuf + idx, data_len, outbuf, &outlen);
        } else {
            status = SecKeyEncrypt(keyRef, kSecPaddingPKCS1, srcbuf + idx, data_len, outbuf, &outlen);
        }
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        } else {
            [ret appendBytes:outbuf length:outlen];
        }
    }

    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key {
    // Skip ASN.1 public key header
    if (d_key == nil) {
        return (nil);
    }

    unsigned long len = [d_key length];
    if (!len) {
        return (nil);
    }

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 0;

    if (c_key[idx++] != 0x30) {
        return (nil);
    }

    if (c_key[idx] > 0x80) {
        idx += c_key[idx] - 0x80 + 1;
    } else {
        idx++;
    }

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
        {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00};
    if (memcmp(&c_key[idx], seqiod, 15)) {
        return (nil);
    }

    idx += 15;

    if (c_key[idx++] != 0x03) {
        return (nil);
    }

    if (c_key[idx] > 0x80) {
        idx += c_key[idx] - 0x80 + 1;
    } else {
        idx++;
    }

    if (c_key[idx++] != '\0') {
        return (nil);
    }

    // Now make a new NSData from this buffer
    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (SecKeyRef)addPublicKey:(NSString *)key {
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e - s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];

    // This will be base64 encoded, decode it.
    NSData *data = [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [GrowingRSAEncryptor stripPublicKeyHeader:data];
    if (!data) {
        return nil;
    }

    // a tag to read/write keychain storage
    NSString *tag = @"Growing_RSA_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);

    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];

    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }

    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if (status != noErr) {
        return nil;
    }
    return keyRef;
}

@end
