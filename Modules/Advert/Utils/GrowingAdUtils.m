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
