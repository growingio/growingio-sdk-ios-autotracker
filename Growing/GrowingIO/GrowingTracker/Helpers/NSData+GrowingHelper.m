//
//  NSData+GrowingHelper.m
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


#import "NSData+GrowingHelper.h"
#import "lz4.h"
#import "NSString+GrowingHelper.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (GrowingHelper)

- (NSString*)growingHelper_utf8String
{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSData*)growingHelper_LZ4String
{
    void *out_buff = malloc(LZ4_compressBound((int)self.length));
    int out_size = GROW_LZ4_compress(self.bytes, out_buff, (int)self.length);
    if (out_size < 0) {
        free(out_buff);
        return nil;
    }
    
    return [[NSData alloc] initWithBytesNoCopy:out_buff length:out_size freeWhenDone:YES];
}

- (NSString*)growingHelper_base64String
{
    //ensure wrapWidth is a multiple of 4
    
    NSUInteger wrapWidth = 0;
    
    const char lookup[] ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    long long inputLength = (long long)[self length];
    const unsigned char *inputBytes = [self bytes];
    
    long long maxOutputLength = (inputLength /3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) *2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc((unsigned long)maxOutputLength);
    
    long long i;
    long long outputLength =0;
    for (i = 0; i < inputLength -2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] &0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] &0x03) << 4) | ((inputBytes[i +1] & 0xF0) >>4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i +1] & 0x0F) <<2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i +2] & 0x3F];
        
        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] ='\r';
            outputBytes[outputLength++] ='\n';
        }
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] &0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] &0x03) << 4) | ((inputBytes[i +1] & 0xF0) >>4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i +1] & 0x0F) <<2];
        outputBytes[outputLength++] =  '=';
    }
    else if (i == inputLength -1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] &0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] &0x03) << 4];
        outputBytes[outputLength++] ='=';
        outputBytes[outputLength++] ='=';
    }
    
    //truncate data to match actual output length
    outputBytes = realloc(outputBytes, (unsigned long)outputLength);
    NSString *result = [[NSString alloc] initWithBytesNoCopy:outputBytes
                                                      length:(NSUInteger)outputLength
                                                    encoding:NSASCIIStringEncoding
                                                freeWhenDone:YES];
    
    
    return (outputLength >= 4)? result: nil;
}

- (id)growingHelper_jsonObject
{
    id jsonObj = [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
    return jsonObj;
}

- (NSDictionary*)growingHelper_dictionaryObject
{
    NSDictionary *dict = [self growingHelper_jsonObject];
    if (dict && [dict isKindOfClass:[NSDictionary class]])
    {
        return dict;
    }
    else
    {
        return nil;
    }
}

- (NSArray*)growingHelper_arrayObject
{
    NSArray *arr = [self growingHelper_jsonObject];
    if (arr && [arr isKindOfClass:[NSArray class]])
    {
        return arr;
    }
    else
    {
        return nil;
    }
}

- (void)growingHelper_md5value:(unsigned char *)valueArray
{
    CC_MD5(self.bytes, (CC_LONG)[self length], valueArray);
}

- (NSString*)growingHelper_md5String
{
    unsigned char result[16];
    [self growingHelper_md5value:result];
    NSString *retVal =
    [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return retVal;
}

- (NSData *)growingHelper_xorEncryptWithHint:(unsigned char)hint
{
    NSMutableData * data = [[NSMutableData alloc] initWithLength:self.length];
    const unsigned char * p = self.bytes;
    unsigned char * q = data.mutableBytes;
    for (NSUInteger i = 0; i < self.length; i++, p++, q++)
    {
        *q = (*p ^ hint);
    }
    return data;
}

@end
