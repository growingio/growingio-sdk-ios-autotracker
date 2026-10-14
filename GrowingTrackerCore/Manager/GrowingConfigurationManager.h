//
//  GrowingConfigurationManager.h
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
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
#import "GrowingTrackConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingConfigurationManager : NSObject

@property (nonatomic, strong) GrowingTrackConfiguration *trackConfiguration;

+ (instancetype)sharedInstance;

// Accessed on the event thread after initialization.
@property (nonatomic, assign) NSUInteger routingSequence;
@property (atomic, copy, nullable) NSDictionary *committedContext;
+ (NSString *_Nullable)normalizedServerHost:(NSString *)host;
+ (NSDictionary<NSString *, NSString *> *_Nullable)validatedMapping:(GrowingTrackConfiguration *)configuration
                                                              error:(NSError *_Nullable *_Nullable)error;
- (NSDictionary *)eventContext;
- (NSString *_Nullable)serverHostForDataSourceId:(NSString *)dataSourceId;

@end

NS_ASSUME_NONNULL_END
