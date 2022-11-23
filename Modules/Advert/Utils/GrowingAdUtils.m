//
//  GrowingAdUtils.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
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

#import "Modules/Advert/Utils/GrowingAdUtils.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"

@implementation GrowingAdUtils

+ (BOOL)isGrowingIOUrl:(NSURL *)url {
    return ([self isUniversalLink:url] || [self isURLScheme:url]);
}

+ (BOOL)isUniversalLink:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    return ([url.host isEqualToString:@"datayi.cn"] || [url.host hasSuffix:@".datayi.cn"]);
}

+ (BOOL)isURLScheme:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    return [url.scheme hasPrefix:@"growing."];
}

+ (NSString *)URLDecodedString:(NSString *)urlString {
    urlString = [urlString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [urlString stringByRemovingPercentEncoding];
}

+ (nullable NSDictionary *)dictFromPasteboard:(NSString *_Nullable)clipboardString {
    if (!clipboardString) {
        return nil;
    }
    if (clipboardString.length > 2000 * 16) {
        return nil;
    }
    NSString *binaryList = @"";
    for (int i = 0; i < clipboardString.length; i++) {
        char a = [clipboardString characterAtIndex:i];
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

+ (int)convertBinaryToDecimal:(long long)n {
    int decimalNumber = 0, i = 0, remainder;
    while (n != 0) {
        remainder = n % 10;
        n /= 10;
        decimalNumber += remainder * pow(2, i);
        ++i;
    }
    return decimalNumber;
}

+ (void)setActivateDefer:(BOOL)activateDefer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(activateDefer) forKey:@"GrowingAdvertisingActivateDefer"];
    [userDefaults synchronize];
}

+ (BOOL)isActivateDefer {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"GrowingAdvertisingActivateDefer"];
    return number && number.boolValue;
}

+ (void)setActivateWrote:(BOOL)activateWrote {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(activateWrote) forKey:@"GrowingAdvertisingActivateWrote"];
    [userDefaults synchronize];
}

+ (BOOL)isActivateWrote {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"GrowingAdvertisingActivateWrote"];
    return number && number.boolValue;
}

+ (void)setActivateSent:(BOOL)activateSent {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(activateSent) forKey:@"GrowingAdvertisingActivateSent"];
    [userDefaults synchronize];
}

+ (BOOL)isActivateSent {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"GrowingAdvertisingActivateSent"];
    return number && number.boolValue;
}

@end
