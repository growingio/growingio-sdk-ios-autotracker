//
// GrowingCustomEvent.h
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
#import "GrowingBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingCustomBuilder;

@interface GrowingCustomEvent : GrowingBaseEvent

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *path;

+ (GrowingCustomBuilder *)builder;

@end

@interface GrowingCustomBuilder : GrowingBaseBuilder

@property (nonatomic, copy, readonly) NSString *eventName;
@property (nonatomic, copy, readonly) NSString *path;

- (GrowingCustomBuilder * (^)(NSString *value))setEventName;
- (GrowingCustomBuilder * (^)(NSString *value))setPath;
- (GrowingCustomBuilder * (^)(NSDictionary<NSString *, NSObject *> *value))setAttributes;

@end

NS_ASSUME_NONNULL_END
