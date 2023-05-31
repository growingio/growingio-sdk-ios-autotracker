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
#import "GrowingModuleProtocol.h"
#import "GrowingTrackConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GrowingAdvertisingError) {
    GrowingAdvertisingNoQueryError = 500,  /// 无自定义参数
    GrowingAdvertisingIllegalURLError,     /// 非法 URL
    GrowingAdvertisingRequestFailedError,  /// 短链请求失败
};

FOUNDATION_EXPORT NSString *const GrowingAdDefaultDeepLinkHost;

extern NSString *const GrowingAdvertisingErrorDomain;

typedef void (^_Nullable GrowingAdDeepLinkCallback)(NSDictionary *_Nullable params,
                                                    NSTimeInterval processTime,
                                                    NSError *_Nullable error);

@interface GrowingAdvertising : NSObject <GrowingModuleProtocol>

/// 单例获取
+ (instancetype)sharedInstance;

/// 打开或关闭剪贴板读取
/// @param enabled 打开或者关闭
- (void)setReadClipboardEnabled:(BOOL)enabled;

/// 根据传入的 url，手动触发 GrowingIO 的 deeplink 处理逻辑
/// @param url 对应需要处理的 GrowingIO deeplink 或 applink url
/// @param callback 处理结果的回调, 如果 callback 为 null, 回调会使用初始化时传入的默认 deepLinkCallback
/// @return url 是否是 GrowingIO 的 deeplink 链接格式
- (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(GrowingAdDeepLinkCallback)callback;

@end

@interface GrowingTrackConfiguration (Advert)

@property (nonatomic, assign) BOOL ASAEnabled;
@property (nonatomic, copy) NSString *deepLinkHost;
@property (nonatomic, copy) GrowingAdDeepLinkCallback deepLinkCallback;
@property (nonatomic, assign) BOOL readClipboardEnabled;

@end

NS_ASSUME_NONNULL_END
