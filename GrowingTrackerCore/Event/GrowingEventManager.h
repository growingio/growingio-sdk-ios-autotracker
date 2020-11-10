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
#import "GrowingEvent.h"
#import "GrowingEventDataBase.h"
#import "GrowingVisitEvent.h"
#import "GrowingNodeProtocol.h"

@class GrowingPageEvent;

@protocol GrowingEventManagerObserver <NSObject>

@optional

- (BOOL)growingEventManagerShouldAddEvent:(GrowingEvent* _Nullable)event
                                 thisNode:(id<GrowingNode> _Nullable)thisNode
                              triggerNode:(id<GrowingNode> _Nullable)triggerNode
                              withContext:(id<GrowingAddEventContext> _Nullable)context;

- (void)growingEventManagerWillAddEvent:(GrowingEvent* _Nullable)event
                               thisNode:(id<GrowingNode> _Nullable)thisNode
                            triggerNode:(id<GrowingNode> _Nullable)triggerNode
                            withContext:(id<GrowingAddEventContext> _Nullable)context;
@end

@interface GrowingEventManager : NSObject

@property (nonatomic, strong) GrowingPageEvent * _Nullable lastPageEvent;
@property (nonatomic, strong) GrowingVisitEvent * _Nullable visitEvent;
@property (nonatomic, assign) BOOL shouldCacheEvent;

+ (_Nonnull instancetype)shareInstance;
+ (BOOL)hasSharedInstance;

- (void)sendAllChannelEvents;

- (void)clearAllEvents;

- (void)addObserver:(NSObject<GrowingEventManagerObserver>* _Nonnull)observer;
- (void)removeObserver:(NSObject<GrowingEventManagerObserver> *_Nonnull)observer;

// 必须在主线程调用
- (void)addEvent:(GrowingEvent* _Nullable)event
        thisNode:(id<GrowingNode> _Nullable)thisNode
     triggerNode:(id<GrowingNode> _Nullable)triggerNode
     withContext:(id<GrowingAddEventContext> _Nullable)context;

- (void)cleanExpiredData;

@end
