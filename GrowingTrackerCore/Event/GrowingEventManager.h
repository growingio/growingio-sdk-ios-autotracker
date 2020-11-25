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
#import "GrowingEventDataBase.h"
#import "GrowingVisitEvent.h"
#import "GrowingNodeProtocol.h"
#import "GrowingBaseEvent.h"
@class GrowingPageEvent;
//拦截者做额外处理
@protocol GrowingEventInterceptor <NSObject>
@required
//在未完成构造event前，返回builder
- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder* _Nullable)builder;
//在完成构造event之后，返回event
- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent* _Nullable)event;
@end

@interface GrowingEventManager : NSObject

//@property (nonatomic, weak) id <GrowingEventManagerDelegate> delegate;

+ (_Nonnull instancetype)shareInstance;

- (void)sendAllChannelEvents;

- (void)clearAllEvents;

- (void)addInterceptor:(NSObject<GrowingEventInterceptor>* _Nonnull)interceptor;
- (void)removeInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor;

// 必须在主线程调用
- (void)postEventBuidler:(GrowingBaseBuilder* _Nullable)builder;

@end
