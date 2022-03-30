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

#import <UIKit/UIKit.h>
#import "GrowingTrackerCore/Utils/UserIdentifier/GrowingUserIdentifier.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"

@implementation GrowingUserIdentifier

+ (NSString *)getUserIdentifier {
    NSString *uuid = nil;
    // 尝试取block
    NSString *idfaString = [self idfa];
    if (!idfaString.growingHelper_isValidU) {
        idfaString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    if ([idfaString isKindOfClass:[NSString class]] && idfaString.length > 0 && idfaString.length <= 64) {
        uuid = idfaString;
    }
    // 失败了随机生成 UUID
    if (!uuid.length || !uuid.growingHelper_isValidU) {
        uuid = [[NSUUID UUID] UUIDString];
    }
    return uuid;
}

+ (nullable NSString *)idfv {
    NSString *vendorId = nil;
    if (NSClassFromString(@"UIDevice")) {
        vendorId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return vendorId;
}

+ (NSString *)idfa {
    NSString *idfa = @"";
#ifndef GROWING_ANALYSIS_DISABLE_IDFA
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (!ASIdentifierManagerClass) {
        return idfa;
    }

    SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
    id sharedManager = ((id(*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(
        ASIdentifierManagerClass, sharedManagerSelector);
    //    SEL trackingEnabledSelector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
    //    BOOL trackingEnabled = ((BOOL(*)(id, SEL))[sharedManager methodForSelector:trackingEnabledSelector])(
    //        sharedManager, trackingEnabledSelector);
    SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");

    NSUUID *uuid = ((NSUUID * (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(
        sharedManager, advertisingIdentifierSelector);
    idfa = [uuid UUIDString];
    // In iOS 10.0 and later, the value of advertisingIdentifier is all zeroes
    // when the user has limited ad tracking; So return @"";
    if ([idfa hasPrefix:@"00000000"]) {
        idfa = @"";
    }
#endif
    return idfa;
}

@end
