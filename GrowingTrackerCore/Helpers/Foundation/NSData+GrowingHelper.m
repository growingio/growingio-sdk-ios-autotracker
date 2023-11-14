//
//  NSData+GrowingHelper.m
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

#import "GrowingTrackerCore/Helpers/Foundation/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/Foundation/NSString+GrowingHelper.h"
#import "GrowingTrackerCore/Public/GrowingCompressService.h"
#import "GrowingTrackerCore/Public/GrowingEncryptionService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (GrowingHelper)

- (NSString *)growingHelper_utf8String {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSData *)growingHelper_LZ4String {
    id<GrowingCompressService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingCompressService)];
    if (service) {
        return [service compressedEventData:self];
    }
    GIOLogDebug(@"NSData -growingHelper_LZ4String compressed error : no compress service support");
    return self;
}

- (NSString *)growingHelper_base64String {
    // ensure wrapWidth is a multiple of 4

    NSUInteger wrapWidth = 0;

    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    long long inputLength = (long long)[self length];
    const unsigned char *inputBytes = [self bytes];

    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth ? (maxOutputLength / wrapWidth) * 2 : 0;
    unsigned char *outputBytes = (unsigned char *)malloc((unsigned long)maxOutputLength);

    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3) {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];

        // add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0) {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }

    // handle left-over data
    if (i == inputLength - 2) {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] = '=';

    } else if (i == inputLength - 1) {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }

    // truncate data to match actual output length
    outputBytes = realloc(outputBytes, (unsigned long)outputLength);
    NSString *result = [[NSString alloc] initWithBytesNoCopy:outputBytes
                                                      length:(NSUInteger)outputLength
                                                    encoding:NSASCIIStringEncoding
                                                freeWhenDone:YES];

    return (outputLength >= 4) ? result : nil;
}

- (id)growingHelper_jsonObject {
    id jsonObj = [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
    return jsonObj;
}

- (NSDictionary *)growingHelper_dictionaryObject {
    NSDictionary *dict = [self growingHelper_jsonObject];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    } else {
        return nil;
    }
}

- (NSArray *)growingHelper_arrayObject {
    NSArray *arr = [self growingHelper_jsonObject];
    if (arr && [arr isKindOfClass:[NSArray class]]) {
        return arr;
    } else {
        return nil;
    }
}

- (NSData *)growingHelper_xorEncryptWithHint:(unsigned char)hint {
    id<GrowingEncryptionService> service =
        [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEncryptionService)];
    if (service) {
        return [service encryptEventData:self factor:hint];
    }
    GIOLogDebug(@"NSData -growingHelper_xorEncryptWithHint Encrypt error : no encrypt service support");
    return self;
}

@end
