//
// GrowingUserIdentifier.m
// GrowingAnalytics
//
//  Created by YoloMao on 2022/3/28.
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

#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier.h"

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
    return @"";
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
