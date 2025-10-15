//
// GrowingUserIdentifier.m
// GrowingAnalytics
//
//  Created by sheng on 2021/4/21.
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

#import "GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

@implementation GrowingUserIdentifier

+ (NSString *)getUserIdentifier {
    NSString *uuid = nil;
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    NSString *idfaString = [self idfa];
    if (!idfaString.growingHelper_isValidU) {
        idfaString = [self idfv];
    }
    uuid = idfaString;
#else
    uuid = [self platformUUID];
#endif
    // 失败了随机生成 UUID
    if (!uuid.length || !uuid.growingHelper_isValidU) {
        uuid = [[NSUUID UUID] UUIDString];
    }
    return uuid;
}

+ (nullable NSString *)idfv {
#if TARGET_OS_IOS
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
#endif
    return @"";
}

+ (NSString *)idfa {
    NSString *idfa = @"";
#if TARGET_OS_IOS
#ifndef GROWING_ANALYSIS_DISABLE_IDFA
    Class class = NSClassFromString(@"ASIdentifierManager");
    if (!class) {
        return idfa;
    }
    SEL selector = NSSelectorFromString(@"sharedManager");
    id sharedManager = ((id (*)(id, SEL))[class methodForSelector:selector])(class, selector);
    SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
    NSUUID *uuid = ((NSUUID * (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(
        sharedManager,
        advertisingIdentifierSelector);
    idfa = [uuid UUIDString];
    // In iOS 10.0 and later, the value of advertisingIdentifier is all zeroes
    // when the user has limited ad tracking; So return @"";
    if ([idfa hasPrefix:@"00000000"]) {
        idfa = @"";
    }
#endif
#endif
    return idfa;
}

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
+ (nullable NSString *)platformUUID {
    io_service_t service =
        IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    if (service) {
        CFStringRef ref = IORegistryEntryCreateCFProperty(service, CFSTR(kIOPlatformUUIDKey), kCFAllocatorDefault, 0);
        IOObjectRelease(service);
        if (ref) {
            NSString *string = [NSString stringWithString:(__bridge NSString *)ref];
            CFRelease(ref);
            return string;
        }
    }
    return nil;
}
#endif

@end
