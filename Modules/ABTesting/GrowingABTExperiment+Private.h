//
//  GrowingABTExperiment+Private.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/10.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingABTExperiment.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingABTExperiment (Private)

@property (nonatomic, assign) long long fetchTime;

- (instancetype)initWithLayerId:(NSString *)layerId
                   experimentId:(NSString * _Nullable)experimentId
                     strategyId:(NSString * _Nullable)strategyId
                      variables:(NSDictionary * _Nullable)variables
                      fetchTime:(long long)fetchTime;
- (void)saveToDisk;
- (void)removeFromDisk;
+ (NSDictionary<NSString *, GrowingABTExperiment *> *)allExperiments;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
