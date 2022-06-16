//
//  GrowingGA3Adapter+Internal.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/6/1.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingGA3Adapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingGA3Adapter (Internal)

+ (instancetype)sharedInstance;

- (void)trackerInit:(id/* <GAITracker>*/)tracker name:(NSString *)name trackingId:(NSString *)trackingId;

- (void)tracker:(id/* <GAITracker>*/)tracker set:(NSString *)parameterName value:(NSString *)value;

- (void)tracker:(id/* <GAITracker>*/)tracker send:(NSDictionary *)parameters;

- (void)removeTrackerByName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END