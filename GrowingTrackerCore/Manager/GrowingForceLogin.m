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

// 与 Web SDK identify 一致：超出部分截断而非拒绝
static const NSUInteger kGrowingIdentifyDeviceIdMaxLength = 1000;

GROWING_LOCK_DECLARE_STATIC(growingForceLoginLock);
// 已持久化的访问用户 ID（跨启动保留）
static NSString *growingForceLoginDeviceId = nil;
// 本次启动是否已 identify 成功（不跨启动保留）
static BOOL growingForceLoginIdentified = NO;

@implementation GrowingForceLogin

+ (void)setup {
    NSString *savedDeviceId = [GrowingPersistenceDataProvider sharedInstance].identifyDeviceId;
    GROWING_LOCK(growingForceLoginLock);
    growingForceLoginDeviceId = [savedDeviceId copy];
    growingForceLoginIdentified = NO;
    GROWING_UNLOCK(growingForceLoginLock);
}

+ (BOOL)identify:(NSString *)deviceId {
    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!configuration.forceLogin) {
        GIOLogInfo(@"Failed to identify, forceLogin is not enabled");
        return NO;
    }
    if (![deviceId isKindOfClass:NSString.class] || deviceId.length == 0) {
        GIOLogInfo(@"Failed to identify, deviceId is empty");
        return NO;
    }

    NSString *identifiedDeviceId = deviceId;
    if (identifiedDeviceId.length > kGrowingIdentifyDeviceIdMaxLength) {
        // 按字符边界截断，避免拆开代理对导致 JSON 序列化失败
        NSRange range = [identifiedDeviceId rangeOfComposedCharacterSequenceAtIndex:kGrowingIdentifyDeviceIdMaxLength];
        identifiedDeviceId = [identifiedDeviceId substringToIndex:range.location];
    }

    GROWING_LOCK(growingForceLoginLock);
    if (growingForceLoginIdentified) {
        GROWING_UNLOCK(growingForceLoginLock);
        GIOLogInfo(@"Failed to identify, deviceId has already been set in this launch");
        return NO;
    }
    growingForceLoginDeviceId = [identifiedDeviceId copy];
    growingForceLoginIdentified = YES;
    GROWING_UNLOCK(growingForceLoginLock);
    [[GrowingPersistenceDataProvider sharedInstance] setIdentifyDeviceId:identifiedDeviceId];
    GIOLogInfo(@"Identify deviceId for forced login");
    return YES;
}

+ (BOOL)canSend {
    if (!GrowingConfigurationManager.sharedInstance.trackConfiguration.forceLogin) {
        return YES;
    }
    GROWING_LOCK(growingForceLoginLock);
    BOOL identified = growingForceLoginIdentified;
    GROWING_UNLOCK(growingForceLoginLock);
    return identified;
}

+ (BOOL)isPending {
    return ![self canSend];
}

+ (NSString *)deviceIdWithGeneratedDeviceId:(NSString *)generatedDeviceId {
    GROWING_LOCK(growingForceLoginLock);
    NSString *deviceId = growingForceLoginDeviceId.length > 0 ? growingForceLoginDeviceId : generatedDeviceId;
    GROWING_UNLOCK(growingForceLoginLock);
    return deviceId;
}

+ (NSString *)eventDeviceIdWithGeneratedDeviceId:(NSString *)generatedDeviceId {
    if ([self isPending]) {
        return generatedDeviceId;
    }
    return [self deviceIdWithGeneratedDeviceId:generatedDeviceId];
}

@end
