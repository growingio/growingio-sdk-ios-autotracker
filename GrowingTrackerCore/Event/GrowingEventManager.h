//
//  GrowingEventManager.h
//  GrowingTracker
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
#import "GrowingEventDatabase.h"
#import "GrowingVisitEvent.h"
#import "GrowingNodeProtocol.h"
#import "GrowingBaseEvent.h"
#import "GrowingRequestProtocol.h"
#import "GrowingEventChannel.h"

@class GrowingPageEvent;
//拦截者做额外处理
@protocol GrowingEventInterceptor <NSObject>
@optional
- (void)growingEventManagerChannels:(NSMutableArray<GrowingEventChannel *> * _Nullable)channels;
//事件被触发
- (void)growingEventManagerEventTriggered:(NSString * _Nullable)eventType;
//在未完成构造event前，返回builder
- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder* _Nullable)builder;
//在完成构造event之后，返回event
- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent* _Nullable)event;
//频段事件的网络请求request对象
- (id<GrowingRequestProtocol>_Nullable)growingEventManagerRequestWithChannel:(GrowingEventChannel* _Nullable)channel;
@end

@interface GrowingEventManager : NSObject


+ (_Nonnull instancetype)sharedInstance;

- (void)sendAllChannelEvents;

- (void)clearAllEvents;
/// 开启定时器发送事件
- (void)startTimerSend;

/// 添加拦截者 - 执行顺序不保证有序
/// @param interceptor 拦截者
- (void)addInterceptor:(NSObject<GrowingEventInterceptor>* _Nonnull)interceptor;

/// 删除拦截者
/// @param interceptor 拦截者
- (void)removeInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor;

// 必须在主线程调用
- (void)postEventBuidler:(GrowingBaseBuilder* _Nullable)builder;

- (void)writeToDatabaseWithEvent:(GrowingBaseEvent * _Nullable)event;

@end
