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
#import "GrowingVisitEvent.h"
#import "GrowingCustomEvent.h"

@interface GrowingEventGenerator : NSObject

+ (void)generateVisitEvent:(long long)ts latitude:(double)latitude longitude:(double)longitude;

+ (void)generateCustomEvent:(NSString * _Nonnull)name attributes:(NSDictionary <NSString *,NSObject *>*_Nonnull)attributes;

+ (void)generateConversionVariablesEvent:(NSDictionary <NSString *,NSObject *>*_Nonnull)variables;

+ (void)generateLoginUserAttributesEvent:(NSDictionary <NSString *,NSObject *>*_Nonnull)attributes;

+ (void)generateVisitorAttributesEvent:(NSDictionary <NSString *,NSObject *>*_Nonnull)attributes;

+ (void)generateAppCloseEvent;

@end

