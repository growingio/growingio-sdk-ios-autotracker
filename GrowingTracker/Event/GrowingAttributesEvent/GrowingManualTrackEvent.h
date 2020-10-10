//
//  GrowingManualTrackEvent.h
//  GrowingTracker
//
//  Created by GrowingIO on 2018/4/28.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
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
#import "GrowingAttributesEvent.h"

// 埋点相关

@interface GrowingEvarEvent : GrowingAttributesEvent

+ (void)sendEvarEvent:(NSDictionary<NSString *, NSObject *> * _Nonnull)evar;

+ (instancetype _Nonnull)hybridEvarEventWithDataDict:(NSDictionary *_Nonnull)dataDict;

@end

@interface GrowingCustomTrackEvent : GrowingAttributesEvent

@property (nonatomic, copy, readonly) NSString * _Nonnull eventName;
@property (nonatomic, copy, readonly) NSString * _Nullable pageName;
@property (nonatomic, strong, readonly) NSNumber * _Nullable pageTimestamp;

- (instancetype _Nullable )initWithEventName:(NSString *_Nullable)eventName
                                withVariable:(NSDictionary<NSString *, NSObject *> *_Nullable)variable;

+ (void)sendEventWithName:(NSString *_Nonnull)eventName
              andVariable:(NSDictionary<NSString *, NSObject *> *_Nonnull)variable
                  handler:(void(^_Nullable)(GrowingCustomTrackEvent * _Nullable event))handler;

+ (void)sendEventWithName:(NSString * _Nonnull)eventName
              andVariable:(NSDictionary<NSString *, NSObject *> * _Nonnull)variable;

+ (void)sendCustomTrackEvent:(GrowingCustomTrackEvent *_Nonnull)customEvent;

+ (instancetype _Nonnull)hybridCustomEventWithDataDict:(NSDictionary *_Nonnull)dataDict;

@end

@interface GrowingPeopleVarEvent : GrowingAttributesEvent

+ (void)sendEventWithVariable:(NSDictionary<NSString *, NSObject *> * _Nonnull)variable;

+ (instancetype _Nonnull)hybridPeopleVarEventWithDataDict:(NSDictionary *_Nonnull)dataDict;


@end


//GrowingVisitorEvent
@interface GrowingVisitorEvent : GrowingAttributesEvent

- (instancetype _Nullable )initWithVisitorVariable:(NSDictionary<NSString *, NSObject *> *_Nullable)variable;

+ (void)sendVisitorEventWithVariable:(NSDictionary<NSString *, NSObject *> * _Nonnull)variable;

+ (void)sendVisitorEvent:(GrowingVisitorEvent *_Nonnull)event;

+ (instancetype _Nonnull)hybridVisitorEventWithDataDict:(NSDictionary *_Nonnull)dataDict;

@end




