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
    return @"";
}

@end
