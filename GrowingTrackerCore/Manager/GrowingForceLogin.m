//
//  GrowingForceLogin.m
//  GrowingAnalytics
//
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Manager/GrowingForceLogin.h"
#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

GROWING_LOCK_DECLARE_STATIC(growingForceLoginLock);
static NSString *growingForceLoginDeviceId = nil;
static BOOL growingForceLoginUnlocked = NO;

@implementation GrowingForceLogin

+ (void)setup {
    NSString *savedDeviceId = [GrowingPersistenceDataProvider sharedInstance].identifyDeviceId;
    GROWING_LOCK(growingForceLoginLock);
    growingForceLoginDeviceId = [savedDeviceId copy];
    growingForceLoginUnlocked = NO;
    GROWING_UNLOCK(growingForceLoginLock);
}

+ (BOOL)identify:(NSString *)deviceId {
    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!configuration.forceLogin) {
        GIOLogInfo(@"Failed to identify, forceLogin is not enabled");
        return NO;
    }
    if (![deviceId isKindOfClass:NSString.class]) {
        GIOLogInfo(@"Failed to identify, deviceId is empty");
        return NO;
    }

    NSString *trimmedDeviceId =
        [deviceId stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmedDeviceId.length == 0 || trimmedDeviceId.length > 1000) {
        GIOLogInfo(@"Failed to identify, deviceId must contain 1 to 1000 non-whitespace characters");
        return NO;
    }

    GROWING_LOCK(growingForceLoginLock);
    if (growingForceLoginUnlocked) {
        GROWING_UNLOCK(growingForceLoginLock);
        GIOLogInfo(@"Failed to identify, deviceId has already been set in this launch");
        return NO;
    }
    growingForceLoginDeviceId = [trimmedDeviceId copy];
    growingForceLoginUnlocked = YES;
    [[GrowingPersistenceDataProvider sharedInstance] setIdentifyDeviceId:trimmedDeviceId];
    GROWING_UNLOCK(growingForceLoginLock);
    GIOLogInfo(@"Identify deviceId for forced login");
    return YES;
}

+ (BOOL)canSend {
    if (!GrowingConfigurationManager.sharedInstance.trackConfiguration.forceLogin) {
        return YES;
    }
    GROWING_LOCK(growingForceLoginLock);
    BOOL canSend = growingForceLoginUnlocked;
    GROWING_UNLOCK(growingForceLoginLock);
    return canSend;
}

+ (NSString *)deviceIdWithGeneratedDeviceId:(NSString *)generatedDeviceId {
    GROWING_LOCK(growingForceLoginLock);
    NSString *deviceId = growingForceLoginDeviceId.length > 0 ? growingForceLoginDeviceId : generatedDeviceId;
    GROWING_UNLOCK(growingForceLoginLock);
    return deviceId;
}

+ (nullable NSString *)identifiedDeviceId {
    GROWING_LOCK(growingForceLoginLock);
    NSString *deviceId = [growingForceLoginDeviceId copy];
    GROWING_UNLOCK(growingForceLoginLock);
    return deviceId;
}

@end
