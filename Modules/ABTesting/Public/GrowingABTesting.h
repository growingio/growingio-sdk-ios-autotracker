//
//  GrowingABTesting.h
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

#import <Foundation/Foundation.h>
#import "GrowingABTExperiment.h"
#import "GrowingModuleProtocol.h"
#import "GrowingTrackConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ABTesting)
@interface GrowingABTesting : NSObject <GrowingModuleProtocol>

/// 根据传入的 layerId，获取实验变量
/// @param layerId 层 id
/// @param completedBlock 根据返回的 experiment 判断，若 experiment 为 nil，则为请求失败，请按需重试；
/// 若 experiment.experimentId 或 experiment.strategyId 为 nil，则未命中实验
+ (void)fetchExperiment:(NSString *)layerId completedBlock:(void (^)(GrowingABTExperiment *_Nullable))completedBlock;

@end

@interface GrowingTrackConfiguration (ABTesting)

@property (nonatomic, copy) NSString *abTestingServerHost;
@property (nonatomic, assign) NSUInteger experimentTTL;

@end

@interface GrowingNetworkConfig (ABTesting)

@property (nonatomic, assign) NSTimeInterval abTestingRequestTimeout;

@end

NS_ASSUME_NONNULL_END
