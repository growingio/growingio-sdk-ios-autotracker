//
//  GrowingConst.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/5/18.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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
#import <Foundation/Foundation.h>

#pragma mark - common 所有事件携带的信息

/// 设备ID(访问用户ID)
UIKIT_EXTERN NSString *const kGrowingEventKey_deviceId;
/// 登录用户ID（可选字段）
UIKIT_EXTERN NSString *const kGrowingEventKey_userId;
/// 访问会话ID
UIKIT_EXTERN NSString *const kGrowingEventKey_sessionId;
/** 事件类型
 VISIT
 CUSTOM
 VISITOR_ATTRIBUTES
 LOGIN_USER_ATTRIBUTES
 CONVERSION_VARIABLES
 APP_CLOSED
 PAGE
 PAGE_ATTRIBUTES
 VIEW_CLICK
 VIEW_CHANGE
 FORM_SUBMIT
 */
UIKIT_EXTERN NSString *const kGrowingEventKey_eventType;
/// 时间戳
UIKIT_EXTERN NSString *const kGrowingEventKey_timestamp;
///APP包名或者H5页面的域名
UIKIT_EXTERN NSString *const kGrowingEventKey_domain;
/// 链接协议
UIKIT_EXTERN NSString *const kGrowingEventKey_urlScheme;
/**
 APP状态

 FOREGROUND 前台运行

 BACKGROUND 后台运行
 */
UIKIT_EXTERN NSString *const kGrowingEventKey_appState;
/// 全局请求编号
UIKIT_EXTERN NSString *const kGrowingEventKey_globalSequenceId;
/// 事件请求编号
UIKIT_EXTERN NSString *const kGrowingEventKey_eventSequenceId;


#pragma mark - 访问事件(VISIT)
/**
 网络类型：
 2G
 3G
 4G
 5G
 WIFI
 UNKNOW
 */
UIKIT_EXTERN NSString *const kGrowingEventKey_networkState;
/// APP渠道来源（可选字段）
UIKIT_EXTERN NSString *const kGrowingEventKey_appChannel;
/// 屏幕高度
UIKIT_EXTERN NSString *const kGrowingEventKey_screenHeight;
/// 屏幕宽度
UIKIT_EXTERN NSString *const kGrowingEventKey_screenWidth;
/// 设备品牌
UIKIT_EXTERN NSString *const kGrowingEventKey_deviceBrand;
/// 设备型号
UIKIT_EXTERN NSString *const kGrowingEventKey_deviceModel;
/**
 设备类型：
 PHONE
 PAD
 */
UIKIT_EXTERN NSString *const kGrowingEventKey_deviceType;
/**
 操作系统
 Android
 iOS
 */
UIKIT_EXTERN NSString *const kGrowingEventKey_operatingSystem;
///APP名称
UIKIT_EXTERN NSString *const kGrowingEventKey_appName;
///APP版本
UIKIT_EXTERN NSString *const kGrowingEventKey_appVersion;
/**
 语言, ISO 639标准
 Android：ISO 639 alpha-2 or alpha-3
 iOS：ISO 639-1 code if available, or the ISO 639-2 code if not
 */
UIKIT_EXTERN NSString *const kGrowingEventKey_language;
/// 维度
UIKIT_EXTERN NSString *const kGrowingEventKey_latitude;
/// 经度
UIKIT_EXTERN NSString *const kGrowingEventKey_longitude;
/// iOS广告标识符（iOS 特有）（可选字段）
UIKIT_EXTERN NSString *const kGrowingEventKey_idfa;
/// iOS应用开发商标识符（iOS 特有）（可选字段）
UIKIT_EXTERN NSString *const kGrowingEventKey_idfv;
/// SDK 版本号
UIKIT_EXTERN NSString *const kGrowingEventKey_sdkVersion;
/// 额外的SDK（可选字段）
UIKIT_EXTERN NSString *const kGrowingEventKey_extraSdk;

#pragma mark - 自定义事件(CUSTOM)
/// 自定义事件的名称
UIKIT_EXTERN NSString *const kGrowingEventKey_eventName;
/// 自定义事件关联的page（可选字段）
UIKIT_EXTERN NSString *const kGrowingEventKey_pageName;
