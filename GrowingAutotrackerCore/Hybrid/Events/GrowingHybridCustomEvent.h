//
// GrowingHybridCustomEvent.h
// GrowingAnalytics-Autotracker-AutotrackerCore-Tracker-TrackerCore
//
//  Created by sheng on 2020/11/17.
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


#import "GrowingPageCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN
@class GrowingHybridCustomBuilder;
@interface GrowingHybridCustomEvent : GrowingPageCustomEvent

@property (nonatomic, strong, readonly) NSString *query;

+ (GrowingHybridCustomBuilder*)builder;

@end

@interface GrowingHybridCustomBuilder : GrowingPageCustomBuilder

@property (nonatomic, strong, readonly) NSString *query;

- (GrowingHybridCustomBuilder *(^)(NSString *value))setQuery;

//override
- (GrowingHybridCustomBuilder *(^)(NSString *value))setPageName;
- (GrowingHybridCustomBuilder *(^)(long long value))setPageShowTimestamp;
- (GrowingHybridCustomBuilder *(^)(NSString *value))setEventName;
- (GrowingHybridCustomBuilder *(^)(NSDictionary <NSString *, NSObject *>*value))setAttributes;

@end

NS_ASSUME_NONNULL_END
