//
// GrowingEventGenerator.h
// GrowingAnalytics
//
//  Created by sheng on 2020/11/12.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingEventGenerator : NSObject

+ (void)generateVisitEvent;

+ (void)generateCustomEvent:(NSString *)name attributes:(NSDictionary<NSString *, id> *_Nullable)attributes;

+ (void)generateLoginUserAttributesEvent:(NSDictionary<NSString *, id> *)attributes;

+ (void)generateAppCloseEvent;

@end

NS_ASSUME_NONNULL_END
