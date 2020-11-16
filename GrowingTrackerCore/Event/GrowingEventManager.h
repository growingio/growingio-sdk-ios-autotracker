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

@protocol GrowingEventInterceptor <NSObject>

@optional
//观察者不应该能够影响实际的结果，返回值不要设置为BOOL
//在未完成构造event前，返回builder
- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder* _Nullable)builder;
//在完成构造event之后，返回event
- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent* _Nullable)event;

@end

@interface GrowingEventManager : NSObject

@property (nonatomic, strong) GrowingPageEvent * _Nullable lastPageEvent;
@property (nonatomic, strong) GrowingVisitEvent * _Nullable visitEvent;
@property (nonatomic, assign) BOOL shouldCacheEvent;

+ (_Nonnull instancetype)shareInstance;
+ (BOOL)hasSharedInstance;

- (void)sendAllChannelEvents;

- (void)clearAllEvents;

- (void)addInterceptor:(NSObject<GrowingEventInterceptor>* _Nonnull)interceptor;
- (void)removeInterceptor:(NSObject<GrowingEventInterceptor> *_Nonnull)interceptor;

// 必须在主线程调用
- (void)postEventBuidler:(GrowingBaseBuilder* _Nullable)builder;

- (void)cleanExpiredData;

@end
