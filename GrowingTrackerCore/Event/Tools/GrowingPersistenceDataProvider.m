//
// GrowingPersistenceDataProvider.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/13.
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

#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"
#import "GrowingTargetConditionals.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

static NSString *kGrowingUserdefault_file = @"growingio.userdefault";
static NSString *kGrowingUserdefault_loginUserId = @"growingio.userdefault.loginUserId";
static NSString *kGrowingUserdefault_loginUserKey = @"growingio.userdefault.loginUserKey";
static NSString *kGrowingUserdefault_sequenceId = @"growingio.userdefault.sequenceId";
static NSString *kGrowingUserdefault_prefix = @"growingio.userdefault";

@interface GrowingPersistenceDataProvider ()

@property (nonatomic, strong) NSUserDefaults *growingUserdefault;

@end

@implementation GrowingPersistenceDataProvider

static GrowingPersistenceDataProvider *persistence = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistence = [[GrowingPersistenceDataProvider alloc] init];
    });
    return persistence;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *suiteName = kGrowingUserdefault_file;
#if Growing_OS_OSX
        // 兼容非沙盒MacApp
        NSString *bundleId = [GrowingDeviceInfo currentDeviceInfo].bundleID;
        suiteName = [suiteName stringByAppendingFormat:@".%@", bundleId];
#endif
        _growingUserdefault = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
    }
    return self;
}

- (void)setLoginUserId:(NSString *_Nullable)loginUserId {
    // 空值
    if (!loginUserId || loginUserId.length == 0) {
        loginUserId = @"";
    }
    [_growingUserdefault setValue:loginUserId forKey:kGrowingUserdefault_loginUserId];
    // write now!
    [_growingUserdefault synchronize];
}

- (nullable NSString *)loginUserId {
    return [_growingUserdefault valueForKey:kGrowingUserdefault_loginUserId];
}

- (void)setLoginUserKey:(NSString *_Nullable)loginUserKey {
    // 空值
    if (!loginUserKey || loginUserKey.length == 0) {
        loginUserKey = @"";
    }
    [_growingUserdefault setValue:loginUserKey forKey:kGrowingUserdefault_loginUserKey];
    // write now!
    [_growingUserdefault synchronize];
}

- (nullable NSString *)loginUserKey {
    return [_growingUserdefault valueForKey:kGrowingUserdefault_loginUserKey];
}

/// 设置NSString,NSNumber
- (void)setString:(NSString *)value forKey:(NSString *)key {
    [_growingUserdefault setValue:value forKey:key];
}

- (NSString *)getStringForKey:(NSString *)key;
{ return [_growingUserdefault valueForKey:key]; }

- (long long)sequenceIdForEventType:(NSString *)eventType {
    if ([eventType isEqualToString:@"VISIT"] || [eventType isEqualToString:@"PAGE"] ||
        [eventType isEqualToString:@"VIEW_CLICK"] || [eventType isEqualToString:@"VIEW_CHANGE"] ||
        [eventType isEqualToString:@"CUSTOM"]) {
        return [self increaseFor:kGrowingUserdefault_sequenceId spanValue:1];
    }
    return 0;
}

- (long long)increaseFor:(NSString *)key spanValue:(int)span {
    NSNumber *value = [_growingUserdefault valueForKey:key];
    if (value == nil) {
        value = [NSNumber numberWithLongLong:0];
    }

    long long result = value.longLongValue + span;
    value = @(result);
    [_growingUserdefault setValue:value forKey:key];
    [_growingUserdefault synchronize];
    return result;
}

@end
