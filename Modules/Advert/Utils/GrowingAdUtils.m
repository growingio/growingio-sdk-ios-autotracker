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
#import "Modules/Advert/Public/GrowingAdvertising.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"
#import "GrowingTrackerCore/FileStorage/GrowingFileStorage.h"

#import <pthread.h>

static NSString *const kGrowingAdertisingFileKey = @"GrowingAdertisingFileKey";
static NSString *const kGrowingAdIsActivateDeferKey = @"GrowingAdvertisingActivateDefer";
static NSString *const kGrowingAdIsActivateWroteKey = @"GrowingAdvertisingActivateWrote";
static NSString *const kGrowingAdIsActivateSentKey = @"GrowingAdvertisingActivateSent";

@interface GrowingAdUtils ()

@property (nonatomic, strong) GrowingFileStorage *storage;
@property (nonatomic, strong) NSMutableDictionary *storeDic;

@end

@implementation GrowingAdUtils

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _storage = [[GrowingFileStorage alloc] initWithName:@"config"];
        _storeDic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [_storage dictionaryForKey:kGrowingAdertisingFileKey];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            [_storeDic addEntriesFromDictionary:dic];
        }
    }
    return self;
}

static pthread_mutex_t _mutex;
+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingAdUtils alloc] init];
        pthread_mutex_init(&_mutex, NULL);
    });
    return instance;
}

#pragma mark - Public Method

+ (BOOL)isGrowingIOUrl:(NSURL *)url {
    return ([self isUniversalLink:url] || [self isURLScheme:url]);
}

+ (BOOL)isUniversalLink:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    return ([url.host isEqualToString:trackConfiguration.deepLinkHost] || [url.host hasSuffix:trackConfiguration.deepLinkHost]);
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
    pthread_mutex_lock(&_mutex);
    [GrowingAdUtils.sharedInstance.storeDic setObject:@(activateDefer) forKey:kGrowingAdIsActivateDeferKey];
    [GrowingAdUtils.sharedInstance.storage setDictionary:GrowingAdUtils.sharedInstance.storeDic forKey:kGrowingAdertisingFileKey];
    pthread_mutex_unlock(&_mutex);
}

+ (BOOL)isActivateDefer {
    NSNumber *number = [GrowingAdUtils.sharedInstance.storeDic objectForKey:kGrowingAdIsActivateDeferKey];
    return number && number.boolValue;
}

+ (void)setActivateWrote:(BOOL)activateWrote {
    pthread_mutex_lock(&_mutex);
    [GrowingAdUtils.sharedInstance.storeDic setObject:@(activateWrote) forKey:kGrowingAdIsActivateWroteKey];
    [GrowingAdUtils.sharedInstance.storage setDictionary:GrowingAdUtils.sharedInstance.storeDic forKey:kGrowingAdertisingFileKey];
    pthread_mutex_unlock(&_mutex);
}

+ (BOOL)isActivateWrote {
    NSNumber *number = [GrowingAdUtils.sharedInstance.storeDic objectForKey:kGrowingAdIsActivateWroteKey];
    if (number) {
        return number.boolValue;
    }

    // 兼容 3.4.5 及以下旧版本存储
    number = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowingAdIsActivateWroteKey];
    BOOL isActivateWrote = number && number.boolValue;
    [self setActivateWrote:isActivateWrote];
    return isActivateWrote;
}

+ (void)setActivateSent:(BOOL)activateSent {
    pthread_mutex_lock(&_mutex);
    [GrowingAdUtils.sharedInstance.storeDic setObject:@(activateSent) forKey:kGrowingAdIsActivateSentKey];
    [GrowingAdUtils.sharedInstance.storage setDictionary:GrowingAdUtils.sharedInstance.storeDic forKey:kGrowingAdertisingFileKey];
    pthread_mutex_unlock(&_mutex);
}

+ (BOOL)isActivateSent {
    NSNumber *number = [GrowingAdUtils.sharedInstance.storeDic objectForKey:kGrowingAdIsActivateSentKey];
    if (number) {
        return number.boolValue;
    }

    // 兼容 3.4.5 及以下旧版本存储
    number = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowingAdIsActivateSentKey];
    BOOL isActivateSent = number && number.boolValue;
    [self setActivateSent:isActivateSent];
    return isActivateSent;
}

@end
