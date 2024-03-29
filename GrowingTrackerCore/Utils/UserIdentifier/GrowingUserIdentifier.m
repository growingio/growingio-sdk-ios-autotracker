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
#import "GrowingTargetConditionals.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

@implementation GrowingUserIdentifier

+ (NSString *)getUserIdentifier {
    NSString *uuid = nil;
#if Growing_OS_OSX || Growing_OS_MACCATALYST
    uuid = [self platformUUID];
#elif Growing_USE_UIKIT || Growing_USE_WATCHKIT
    uuid = [self idfa];
    if (!uuid.growingHelper_isValidU) {
        uuid = [self idfv];
    }
#endif

    // 失败了随机生成 UUID
    if (!uuid.growingHelper_isValidU) {
        uuid = [[NSUUID UUID] UUIDString];
    }
    return uuid;
}

+ (nullable NSString *)idfv {
#if Growing_USE_UIKIT
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
#elif Growing_USE_WATCHKIT
    return [[WKInterfaceDevice currentDevice].identifierForVendor UUIDString];
#else
    return @"";
#endif
}

+ (NSString *)idfa {
    NSString *idfa = @"";
#if Growing_OS_PURE_IOS
#ifndef GROWING_ANALYSIS_DISABLE_IDFA
    Class class = NSClassFromString([@"ASIden" stringByAppendingString:@"tifierManager"]);
    if (!class) {
        return idfa;
    }
    SEL selector = NSSelectorFromString(@"sharedManager");
    id sharedManager = ((id(*)(id, SEL))[class methodForSelector:selector])(class, selector);
    SEL advertisingIdentifierSelector =
        NSSelectorFromString([[@"adve" stringByAppendingString:@"rtisingId"] stringByAppendingString:@"entifier"]);
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

+ (nullable NSString *)platformUUID {
#if Growing_OS_OSX || Growing_OS_MACCATALYST
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
#endif
    return nil;
}

@end
