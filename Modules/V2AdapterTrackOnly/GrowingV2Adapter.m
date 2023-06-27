//
//  GrowingV2Adapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/6/26.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/V2AdapterTrackOnly/Public/GrowingV2Adapter.h"
#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Utils/GrowingKeyChainWrapper.h"

static NSString *kGrowingUserdefault_2xto3x = @"growingio.userdefault.2xto3x";
static NSString *const kGrowingKeychainUserIdKey = @"kGrowingIOKeychainUserIdKey";

@implementation GrowingV2Adapter

+ (void)upgrade {
    NSString *isUpgraded = [[GrowingPersistenceDataProvider sharedInstance] getStringforKey:kGrowingUserdefault_2xto3x];
    if (isUpgraded) {
        // 不考虑升级了之后又降级的场景，比如用户从AppStore更新又从其他渠道下载了老版本
        // 这种情况下isUpgraded=YES，下次再更新不再从本地获取userId/deviceId
        return;
    }

    // userId
    NSString *dirPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[dirPath stringByAppendingPathComponent:@"libGrowing"]]) {
        dirPath = [dirPath stringByAppendingPathComponent:@"libGrowing-CDP"];
    } else {
        dirPath = [dirPath stringByAppendingPathComponent:@"libGrowing"];
    }
    NSString *filePath = [dirPath stringByAppendingPathComponent:@"D00C531B-CC47-48D4-A84A-FEAB505FDFD5.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        NSMutableDictionary *persistentData = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        if (persistentData) {
            NSString *cs1 = [persistentData valueForKey:@"CS1"];
            if (cs1 && cs1.length > 0) {
                [[GrowingPersistenceDataProvider sharedInstance] setLoginUserId:cs1];
            }
        }
    }

    // deviceId
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    NSString *deviceId = [GrowingKeyChainWrapper keyChainObjectForKey:@"GROWINGIO_CUSTOM_U_KEY"];
    if ([deviceId growingHelper_isValidU]) {
        [GrowingKeyChainWrapper setKeychainObject:deviceId forKey:kGrowingKeychainUserIdKey];
    } else {
        deviceId = [GrowingKeyChainWrapper keyChainObjectForKey:@"GROWINGIO_KEYCHAIN_KEY"];
        if ([deviceId growingHelper_isValidU]) {
            [GrowingKeyChainWrapper setKeychainObject:deviceId forKey:kGrowingKeychainUserIdKey];
        }
    }
#endif

    [[GrowingPersistenceDataProvider sharedInstance] setString:@"1" forKey:kGrowingUserdefault_2xto3x];
}

+ (NSDictionary *)fit3xDictionary:(NSDictionary *)variable {
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:variable];
    for (NSString *key in variable.allKeys) {
        id obj = variable[key];
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSString *value = ((NSNumber *)obj).stringValue;
            [mutDic setValue:value forKey:key];
        }
    }
    return mutDic;
}

@end
