//
//  NSString+GrowingHelper.m
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


#import "NSString+GrowingHelper.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "GrowingDeviceInfo.h"
#import "GrowingCocoaLumberjack.h"

static NSString *const kGrowingSpecialCharactersString = @"_!@#$%^&*()-=+|\[]{},.<>/?";

@implementation NSString (GrowingHelper)

- (NSString*)growingHelper_safeSubStringWithLength:(NSInteger)length {
    if (self.length <= length) {
        return self;
    }
    
    NSRange range;
    for(int i = 0 ; i < self.length ; i += range.length) {
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.location + range.length > length) {
            return [self substringToIndex:range.location];
        }
    }
    return self;
}

- (NSData*)growingHelper_uft8Data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)growingHelper_jsonObject {
    return [[self growingHelper_uft8Data] growingHelper_jsonObject];
}

- (NSDictionary *)growingHelper_dictionaryObject {
    id dict = [self growingHelper_jsonObject];
    if ([dict isKindOfClass:[NSDictionary class]]){
        return dict;
    } else {
        return nil;
    }
}

- (NSString *)growingHelper_sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

- (BOOL)growingHelper_isLegal {
    if (self.length != 1) { return NO; }
    
    unichar character = [self characterAtIndex:0];
    
    BOOL isNum = isdigit(character);
    BOOL isLetter = (character >= 'a' && character <= 'z') || (character >= 'A' && character <= 'Z');
    BOOL isSpecialCharacter = ([kGrowingSpecialCharactersString rangeOfString:self].location != NSNotFound);
    if (isNum || isLetter || isSpecialCharacter) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)growingHelper_isValidU {
    if (!self.length) { return NO; }
    
    NSArray *stringArray = [self componentsSeparatedByString:@"-"];
    
    for (NSString *string in stringArray) {
        NSString *zero = [NSString stringWithFormat:@"0{%lu}", (unsigned long)string.length];
        NSPredicate *zeroPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",zero];
        if (![zeroPre evaluateWithObject:string]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)growingHelper_encryptString {
    if ([GrowingDeviceInfo currentDeviceInfo].encryptStringBlock) {
        return [GrowingDeviceInfo currentDeviceInfo].encryptStringBlock(self);
    } else {
        return self;
    }
}


- (instancetype)initWithJsonObject_growingHelper:(id)obj {
    if (!obj || ![NSJSONSerialization isValidJSONObject:obj]) {
        return nil;
    }
    
    NSData *data = nil;
    @autoreleasepool {
        data = [obj growingHelper_jsonData];
    }

    self = [self initWithData:data encoding:NSUTF8StringEncoding];
    return self;
}

//添加Log
- (BOOL)isValidKey {
    BOOL valid = [self isValidIdentifier];
    
    if (!valid) {
        GIOLogError(parameterKeyErrorLog);
    }
    return valid;
}

/**
 判断标志符是否有效
 文档：https://docs.google.com/document/d/1lpx1wzCktp0JJFbLUl4o357kvALYGKDQHbzFXgRhYT0/edit#
 
 @return 有效返回 YES，否则为NO
 */
- (BOOL)isValidIdentifier {
    //标识符不允许空字符串，不允许nil
    //标识符的长度限制在50个英文字符之内
    if (self.length == 0 || self.length > 50) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)growingHelper_isBlankString:(NSString *)string {
    if (string == nil) {
        return YES;
    }

    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }

    return [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0;

}

- (NSDictionary *)growingHelper_queryObject {
    if (self.length == 0) { return nil; }
    
    NSArray *stringArray = [self componentsSeparatedByString:@"&"];
    if (stringArray.count == 0) { return nil; }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *string in stringArray) {
        NSArray *keyValueArray = [string componentsSeparatedByString:@"="];
        if (keyValueArray.count != 2) {
            return nil;
        }
        [dict setValue:keyValueArray[1] forKey:keyValueArray[0]];
    }
    return dict;
}

- (NSString *)absoluteURLStringWithPath:(NSString *)path andQuery:(NSDictionary *)query {
    
    NSString *baseUrl = self;
    
    BOOL baseHasSuffix = [baseUrl hasSuffix:@"/"];
    BOOL pathHasPrefix = [path hasPrefix:@"/"];
    
    if (baseHasSuffix && pathHasPrefix) {
        baseUrl = [baseUrl substringWithRange:NSMakeRange(0, [baseUrl length] - 1)];
    } else if (!baseHasSuffix && !pathHasPrefix) {
        baseUrl = [baseUrl stringByAppendingString:@"/"];
    }
    
    NSString *absoluteURLString = [baseUrl stringByAppendingString:path.length ? path : @""];
    if (query.count > 0) {
        NSString *queryString = query.growingHelper_queryString;
        queryString = [@"?" stringByAppendingString:queryString];
        absoluteURLString = [absoluteURLString stringByAppendingString:queryString];
    }
    
    return absoluteURLString;;
}

- (NSDictionary *)convertToDictFromPasteboard {
    if (self.length > 2000 * 16) {
        return nil;
    }
    
    NSString *binaryList = @"";
    
    for (int i = 0; i < self.length; i++) {
        char a = [self characterAtIndex:i];
        NSString *charString = @"";
        if (a == (char)020014) {
            charString = @"0";
        } else {
            charString = @"1";
        }
        binaryList = [binaryList stringByAppendingString:charString];
    }
    
    NSInteger binaryListLength = binaryList.length;
    
    NSInteger SINGLE_CHAR_LENGTH = 16;
    
    if (binaryListLength % SINGLE_CHAR_LENGTH != 0) {
        return nil;
    }
    
    NSMutableArray *bs = [NSMutableArray array];
    
    int i = 0;
    while (i < binaryListLength) {
        [bs addObject:[binaryList substringWithRange:NSMakeRange(i, SINGLE_CHAR_LENGTH)]];
        i += SINGLE_CHAR_LENGTH;
    }
    
    NSString *listString = @"";
    
    for (int i = 0; i < bs.count; i++) {
        NSString *partString = bs[i];
        long long part = [partString longLongValue];
        int partInt = [self convertBinaryToDecimal:part];
        listString = [listString stringByAppendingString:[NSString stringWithFormat:@"%C", (unichar)partInt]];
    }
    NSDictionary *dict = listString.growingHelper_jsonObject;
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}

- (int)convertBinaryToDecimal:(long long)n {
    int decimalNumber = 0, i = 0, remainder;
    while (n != 0) {
        remainder = n%10;
        n /= 10;
        decimalNumber += remainder*pow(2,i);
        ++i;
    }
    return decimalNumber;
}

@end
