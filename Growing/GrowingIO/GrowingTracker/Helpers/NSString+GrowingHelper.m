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

static NSString *const growingSpecialCharactersString = @"_!@#$%^&*()-=+|\[]{},.<>/?";

@implementation NSString (GrowingHelper)

// 这个函数千万不要删掉  这里留作移除sdk备用的拦截原型
+ (void)load
{
}

- (NSString*)growingHelper_safeSubStringWithLength:(NSInteger)length
{
    if (self.length <= length)
    {
        return self;
    }
    
    NSRange range;
    for(int i = 0 ; i < self.length ; i += range.length)
    {
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.location + range.length > length)
        {
            return [self substringToIndex:range.location];
        }
    }
    return self;
}

- (NSData*)growingHelper_uft8Data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)growingHelper_jsonObject
{
    return [[self growingHelper_uft8Data] growingHelper_jsonObject];
}

- (NSDictionary *)growingHelper_dictionaryObject
{
    id dict = [self growingHelper_jsonObject];
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        return dict;
    }
    else
    {
        return nil;
    }
}


-(NSString *)growingHelper_stringWithXmlConformed
{
    NSMutableString * xml = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < self.length; i++)
    {
        unichar c = [self characterAtIndex:i];
        switch (c)
        {
            case (unichar)'&':
            {
                [xml appendString:@"&amp;"];
            }
                break;
            case (unichar)'<':
            {
                [xml appendString:@"&lt;"];
            }
                break;
            case (unichar)'>':
            {
                [xml appendString:@"&gt;"];
            }
                break;
            case (unichar)'\"':
            {
                [xml appendString:@"&quot;"];
            }
                break;
            case (unichar)'\'':
            {
                [xml appendString:@"&apos;"];
            }
                break;
            default:
            {
                [xml appendString:[NSString stringWithCharacters:&c length:1]];
            }
                break;
        }
    }
    return xml;
}

- (NSString*)growingHelper_stringWithUrlDecode
{
    NSString * s = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [s stringByRemovingPercentEncoding];
}

- (NSString*)growingHelper_stringByRemovingSpace
{
    NSArray * array = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [array componentsJoinedByString:@""];
}

- (NSString *)growingHelper_sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

- (BOOL)growingHelper_matchWildly:(NSString *)wildPattern
{
    BOOL hasWildStar = NO;
    BOOL hasMultipleWildStar = NO;
    NSRange firstStarRange = [wildPattern rangeOfString:@"*"];
    NSUInteger endPosOfFirstStarRange = firstStarRange.location + firstStarRange.length;

    hasWildStar = (firstStarRange.location != NSNotFound);
    if (hasWildStar)
    {
        if (wildPattern.length > endPosOfFirstStarRange)
        {
            NSRange range;
            range.location = endPosOfFirstStarRange;
            range.length = wildPattern.length - range.location;
            NSRange secondStarRange = [wildPattern rangeOfString:@"*" options:NSLiteralSearch range:range];
            hasMultipleWildStar = (secondStarRange.location != NSNotFound);
        }
        else if (wildPattern.length == 1) // just @"*"
        {
            return true;
        }
    }

    if (hasWildStar)
    {
        if (hasMultipleWildStar)
        {
            // Multiple "*"s, we can use NSPredict or NSRegularExpression,
            // see http://stackoverflow.com/questions/5097491/evaluate-compare-nsstring-with-wildcards
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"self LIKE %@", wildPattern];
            return [pred evaluateWithObject:self];
        }
        else
        {
            if (firstStarRange.location == 0)
            {
                return [self hasSuffix:[wildPattern substringFromIndex:endPosOfFirstStarRange]];
            }
            else if (endPosOfFirstStarRange == wildPattern.length)
            {
                return [self hasPrefix:[wildPattern substringToIndex:firstStarRange.location]];
            }
            else
            {
                return [self hasPrefix:[wildPattern substringToIndex:firstStarRange.location]]
                    && [self hasSuffix:[wildPattern substringFromIndex:endPosOfFirstStarRange]];
            }
        }
    }
    else
    {
        return [self isEqualToString:wildPattern];
    }
}

- (BOOL)growingHelper_isLegal
{
    if (self.length != 1) {
        return NO;
    }
    
    unichar character = [self characterAtIndex:0];
    
    BOOL isNum = isdigit(character);
    BOOL isLetter = (character >= 'a' && character <= 'z') || (character >= 'A' && character <= 'Z');
    BOOL isSpecialCharacter = ([growingSpecialCharactersString rangeOfString:self].location != NSNotFound);
    if (isNum || isLetter || isSpecialCharacter) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)growingHelper_isValidU
{
    if (!self.length) {
        return NO;
    }
    
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

- (NSString *)growingHelper_encryptString
{
    if ([GrowingDeviceInfo currentDeviceInfo].encryptStringBlock) {
        return [GrowingDeviceInfo currentDeviceInfo].encryptStringBlock(self);
    } else {
        return self;
    }
}


- (instancetype)initWithJsonObject_growingHelper:(id)obj
{
    if (!obj || ![NSJSONSerialization isValidJSONObject:obj])
    {
        return nil;
    }
    
    NSData *data = nil;
    @autoreleasepool {
        data = [obj growingHelper_jsonData];
    }

    self = [self initWithData:data encoding:NSUTF8StringEncoding];
    return self;
}

- (void)growingHelper_debugOutput
{
    // * NSLog truncates long text to 1023 characters on iOS 10.
    // * C function printf doesn't have any limits on text length, but it
    //   prints to XCode log window only and doesn't print to device log.
    // * So, for customer developer to gather logs, printf is sufficient.
    // * If we want to collect logs from customer's app, we can hook this
    //   method and print log with _os_log_internal.
    //   See: http://stackoverflow.com/questions/39584707/nslog-on-devices-in-ios-10-xcode-8-seems-to-truncate-why
    //   Check out Elist's answer on Oct. 27th. 2016.
    printf("%s\n", self.UTF8String);
}

//添加Log
- (BOOL)isValidKey{
    if (![self isValidIdentifier]) {
        GIOLogError(parameterKeyErrorLog);
    }
    return [self isValidIdentifier];
}

/**
 判断标志符是否有效
 文档：https://docs.google.com/document/d/1lpx1wzCktp0JJFbLUl4o357kvALYGKDQHbzFXgRhYT0/edit#
 
 @return 有效返回 YES，否则为NO
 */
- (BOOL)isValidIdentifier{
    //标识符不允许空字符串，不允许nil
    //标识符的长度限制在50个英文字符之内
    if (self.length == 0 || self.length > 50) {
        return NO;
    }
//    //标识符仅允许大小写英文、数字、下划线、以及英文冒号，并且不能以数字和冒号开头
//    static NSRegularExpression *idExp = nil;
//    if (!idExp) {
//        idExp = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z_][a-zA-Z0-9_:]*$" options:0 error:nil];
//    }
//    NSRange range = [idExp rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
//    if (range.location == 0 && range.length == self.length) {
//        return YES;
//    }
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

- (NSDictionary *)growingHelper_queryObject
{
    if (self.length == 0) {
        return nil;
    }
    
    NSArray *stringArray = [self componentsSeparatedByString:@"&"];
    if (stringArray.count == 0) {
        return nil;
    }
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

@end
