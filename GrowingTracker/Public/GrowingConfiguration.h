//
//  GrowingConfiguration.h
//  GrowingTracker
//
//  Created by GrowingIO on 2020/6/8.
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


NS_ASSUME_NONNULL_BEGIN

@protocol GrowingSettingProtocol <NSObject>

/// 是否采集数据
@property(nonatomic, assign) BOOL dataTrackEnabled;
/// 是否不上报数据, 但是数据正常采集
@property(nonatomic, assign) BOOL dataUploadEnabled;

@end

@interface GrowingConfiguration : NSObject <GrowingSettingProtocol>

/// 是否开启日志
@property(nonatomic, assign) BOOL logEnabled;
/// 采样率，只收集固定比例用户的数据
@property(nonatomic, assign) CGFloat samplingRate;
/// url scheme
@property (nonatomic, copy) NSString *urlScheme;
/// 数据上传间隔
@property(nonatomic, assign) NSTimeInterval dataUploadInterval;
/// 一个采集会话间隔
@property(nonatomic, assign) NSTimeInterval sessionInterval;
/// 设置每天使用数据网络（2G、3G、4G）上传的数据量的上限（单位是 MB）
@property(nonatomic, assign) NSUInteger cellularDataLimit;
/// 是否开启 SDK 的异常监控，默认是开启的
@property (nonatomic, assign) BOOL uploadExceptionEnable;

/// 项目 id
@property (nonatomic, copy, readonly) NSString * projectId;
/// App 启动的 launchOptions
@property (nonatomic, copy, readonly) NSDictionary *launchOptions;

/// 设置数据收集 host
/// @param host host 示例：https://api.growingio.com
- (void)setDataTrackHost:(NSString *)host;

/// 设置web 圈选相关 host
/// @param host host 示例：https://api.growingio.com
- (void)setWebCircleHost:(NSString *)host;

/// 设置websocket相关 host
/// @param host host 示例：https://api.growingio.com
- (void)setWebSocketHost:(NSString *)host;

/// 指定的初始化方法
/// @param projectId GrowingIO 申请的项目id
/// @param launchOptions App 启动参数
- (instancetype)initWithProjectId:(nonnull NSString *)projectId
                    launchOptions:(nullable NSDictionary *)launchOptions NS_DESIGNATED_INITIALIZER;

/// 禁用 init 初始化
- (instancetype)init NS_UNAVAILABLE;

/// 禁用 new 初始化
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
