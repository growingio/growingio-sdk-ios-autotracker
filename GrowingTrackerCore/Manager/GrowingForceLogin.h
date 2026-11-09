//
//  GrowingForceLogin.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingForceLogin : NSObject

+ (void)setup;
+ (BOOL)identify:(NSString *)deviceId;
/// 未开启 forceLogin 时恒为 YES；开启时需本次启动 identify 成功、且暂存事件已入库后才为 YES。
/// 为 NO 时新事件只暂存在内存中，数据库中的事件也不上传。
+ (BOOL)canSend;
/// identify 成功后，暂存事件替换 deviceId 并入库完毕时调用（仅在 Growing 线程调用）
+ (void)markEventsReleased;
+ (NSString *)deviceIdWithGeneratedDeviceId:(NSString *)generatedDeviceId;
+ (nullable NSString *)identifiedDeviceId;

@end

NS_ASSUME_NONNULL_END
