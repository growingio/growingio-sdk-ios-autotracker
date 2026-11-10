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

/// 强制登录：开启后每次启动需 identify 才上传事件。
/// identify 前的事件照常入库，deviceId 为自动生成的设备 ID，并带待替换标志（数据库 forceLoginPending 列）；
/// 上传时只把带标志事件的副本替换为当前有效设备 ID，数据库原文不变。
/// 状态切换（setup、identify）需在 Growing 线程调用，与事件构建、入库串行。
@interface GrowingForceLogin : NSObject

+ (void)setup;
/// 与 Web SDK 校验规则一致：非空即有效，不去除首尾空白，超过 1000 字符截断；每次启动仅首次有效调用生效
+ (BOOL)identify:(NSString *)deviceId;
/// 未开启 forceLogin，或本次启动已 identify 时为 YES
+ (BOOL)canSend;
/// 当前构建的事件是否需要在上传时替换 deviceId（即 !canSend）
+ (BOOL)isPending;
/// 当前有效设备 ID：已持久化的访问用户 ID，否则为自动生成的设备 ID
+ (NSString *)deviceIdWithGeneratedDeviceId:(NSString *)generatedDeviceId;
/// 构建事件使用的设备 ID：待替换时为自动生成的设备 ID（与老版本 SDK 一致，降级后按设备 ID 上报），否则为当前有效设备 ID
+ (NSString *)eventDeviceIdWithGeneratedDeviceId:(NSString *)generatedDeviceId;

@end

NS_ASSUME_NONNULL_END
