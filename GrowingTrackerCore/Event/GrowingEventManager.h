//
//  GrowingEventManager.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/11/19.
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

#import <Foundation/Foundation.h>
#import "GrowingBaseEvent.h"
#import "GrowingRequestProtocol.h"
#import "GrowingTrackerCore/Database/GrowingEventDatabase.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "GrowingTrackerCore/Event/GrowingNodeProtocol.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"

//拦截者做额外处理
@protocol GrowingEventInterceptor <NSObject>

@optional

/// 可配置事件发送通道
/// @param channels 默认的事件发送通道
- (void)growingEventManagerChannels:(NSMutableArray<GrowingEventChannel *> *_Nullable)channels;

/// 事件被触发
/// @param eventType 当前事件类型
- (void)growingEventManagerEventTriggered:(NSString *_Nullable)eventType;

/// 即将构造事件
/// @param builder 事件构造器
- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder *_Nullable)builder;

/// 事件构造完毕
/// @param event 当前事件
- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *_Nullable)event;

/// 自定义event发送请求
/// @param channel 事件发送通道
- (id<GrowingRequestProtocol> _Nullable)growingEventManagerRequestWithChannel:(GrowingEventChannel *_Nullable)channel;

@end

@interface GrowingEventManager : NSObject

+ (_Nonnull instancetype)sharedInstance;

/// 配置事件管理者
- (void)configManager;

/// 开启事件发送定时器
- (void)startTimerSend;

/// 事件入库
- (void)flushDB;

/// 发送event，必须在主线程调用
/// @param builder event构造器
- (void)postEventBuidler:(GrowingBaseBuilder *_Nullable)builder;

/// 添加拦截者 - 执行顺序不保证有序
/// @param interceptor 拦截者
- (void)addInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor;

/// 删除拦截者
/// @param interceptor 拦截者
- (void)removeInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor;

@end
