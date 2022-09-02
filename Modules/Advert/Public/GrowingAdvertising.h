//
//  GrowingAdvertising.h
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

#import <Foundation/Foundation.h>
#import "GrowingTrackConfiguration.h"
#import "GrowingModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , GrowingAdvertisingError) {
    GrowingAdvertisingNoQueryError = 500, /// 无自定义参数
    GrowingAdvertisingIllegalURLError,    /// 非法 URL
    GrowingAdvertisingRequestFailedError, /// 短链请求失败
};

extern NSString *const GrowingAdvertisingErrorDomain;

typedef void(^_Nullable GrowingAdDeepLinkCallback)(NSDictionary * _Nullable params,
                                                   NSTimeInterval processTime,
                                                   NSError * _Nullable error);

@interface GrowingAdvertising : NSObject <GrowingModuleProtocol>

/// 单例获取
+ (instancetype)sharedInstance;

/// 打开或关闭剪贴板读取
/// @param enabled 打开或者关闭
- (void)setReadClipBoardEnabled:(BOOL)enabled;

/// 根据传入的 url，手动触发 GrowingIO 的 deeplink 处理逻辑
/// @param url 对应需要处理的 GrowingIO deeplink 或 applink url
/// @param callback 处理结果的回调, 如果 callback 为 null, 回调会使用初始化时传入的默认 deepLinkCallback
/// @return url 是否是 GrowingIO 的 deeplink 链接格式
- (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(GrowingAdDeepLinkCallback)callback;

/// 手动触发激活事件
/// 注意: 需要在初始化配置中设置 configuration.autoInstall = NO，以切换成手动触发
- (void)trackAppInstall;

/// 手动触发激活事件
/// @param attributes 事件发生时所伴随的维度信息
/// 注意: 需要在初始化配置中设置 configuration.autoInstall = NO，以切换成手动触发
- (void)trackAppInstallWithAttributes:(NSDictionary <NSString *, NSString *> *_Nullable)attributes;

@end

@interface GrowingTrackConfiguration (Advert)

@property (nonatomic, copy) GrowingAdDeepLinkCallback deepLinkCallback;
@property (nonatomic, assign) BOOL readClipBoardEnabled;
@property (nonatomic, assign) BOOL ASAEnabled;
@property (nonatomic, assign) BOOL autoInstall;

@end

NS_ASSUME_NONNULL_END
