//
// GrowingPageCustomEvent.h
// GrowingAnalytics-Autotracker-AutotrackerCore-Tracker-TrackerCore
//
//  Created by sheng on 2020/11/16.
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


#import "GrowingCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingPageCustomBuilder;
@interface GrowingPageCustomEvent : GrowingCustomEvent
@property (nonatomic, copy, readonly) NSString * _Nonnull path;
@property (nonatomic, assign, readonly) long long pageShowTimestamp;

+ (GrowingPageCustomBuilder *)builder;

@end

@interface GrowingPageCustomBuilder : GrowingCustomBuilder

@property (nonatomic, copy, readonly) NSString * _Nonnull pageName;
@property (nonatomic, assign, readonly) long long pageShowTimestamp;

- (GrowingPageCustomBuilder *(^)(NSString *value))setPath;
- (GrowingPageCustomBuilder *(^)(long long value))setPageShowTimestamp;

//override
- (GrowingPageCustomBuilder *(^)(NSString *value))setEventName;
- (GrowingPageCustomBuilder *(^)(NSDictionary <NSString *, NSObject *>*value))setAttributes;

@end

NS_ASSUME_NONNULL_END
