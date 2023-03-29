//
//  NSString+GrowingHelper.m
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

#import "GrowingTrackerCore/Helpers/Foundation/NSString+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/Foundation/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/Foundation/NSDictionary+GrowingHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

static NSString *const kGrowingSpecialCharactersString = @"_!@#$%^&*()-=+|\\[]{},.<>/?";

@implementation NSString (GrowingHelper)

- (NSString *)growingHelper_safeSubStringWithLength:(NSInteger)length {
    if (self.length <= length) {
        return self;
    }

    NSRange range;
    for (int i = 0; i < self.length; i += range.length) {
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.location + range.length > length) {
            return [self substringToIndex:range.location];
        }
    }
    return self;
}

- (NSData *)growingHelper_uft8Data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)growingHelper_jsonObject {
    return [[self growingHelper_uft8Data] growingHelper_jsonObject];
}

- (NSDictionary *)growingHelper_dictionaryObject {
    id dict = [self growingHelper_jsonObject];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    } else {
        return nil;
    }
}

- (NSString *)growingHelper_sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG) data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

- (BOOL)growingHelper_isLegal {
    if (self.length != 1) {return NO;}

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
    if (!self.length) {return NO;}

    NSArray *stringArray = [self componentsSeparatedByString:@"-"];

    for (NSString *string in stringArray) {
        NSString *zero = [NSString stringWithFormat:@"0{%lu}", (unsigned long) string.length];
        NSPredicate *zeroPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zero];
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
    if (self.length == 0) {return nil;}

    NSArray *stringArray = [self componentsSeparatedByString:@"&"];
    if (stringArray.count == 0) {return nil;}

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

- (NSString *)growingHelper_absoluteURLStringWithPath:(NSString *)path andQuery:(NSDictionary *)query {

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

    return absoluteURLString;
}

+ (BOOL)growingHelper_isEqualStringA:(NSString *)strA andStringB:(NSString *)strB {
    if ([self growingHelper_isBlankString:strA]) {
        return [self growingHelper_isBlankString:strB];
    } else {
        return [strA isEqualToString:strB];
    }
}

@end
