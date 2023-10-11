//
//  GrowingABTExperiment.m
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

#import "Modules/ABTesting/GrowingABTExperiment+Private.h"
#import "Modules/ABTesting/GrowingABTExperimentStorage.h"

@interface GrowingABTExperiment ()

@property (nonatomic, copy, readwrite) NSString *layerId;
@property (nonatomic, copy, nullable, readwrite) NSString *experimentId;
@property (nonatomic, copy, nullable, readwrite) NSString *strategyId;
@property (nonatomic, copy, nullable, readwrite) NSDictionary *variables;
@property (nonatomic, assign) long long fetchTime;

@end

@implementation GrowingABTExperiment

- (instancetype)initWithLayerId:(NSString *)layerId
                   experimentId:(NSString *_Nullable)experimentId
                     strategyId:(NSString *_Nullable)strategyId
                      variables:(NSDictionary *_Nullable)variables
                      fetchTime:(long long)fetchTime {
    if (self = [super init]) {
        _layerId = layerId.copy;
        _experimentId = experimentId.copy;
        _strategyId = strategyId.copy;
        _variables = variables.copy;
        _fetchTime = fetchTime;
    }
    return self;
}

- (void)saveToDisk {
    [GrowingABTExperimentStorage addExperiment:self];
}

- (void)removeFromDisk {
    [GrowingABTExperimentStorage removeExperiment:self];
}

+ (nullable GrowingABTExperiment *)findExperiment:(NSString *)layerId {
    return [GrowingABTExperimentStorage findExperiment:layerId];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (!object || ![object isKindOfClass:[GrowingABTExperiment class]]) {
        return NO;
    }

    return [self isEqualExperiment:(GrowingABTExperiment *)object];
}

- (BOOL)isEqualExperiment:(GrowingABTExperiment *)experiment {
    return [self.layerId isEqualToString:experiment.layerId] &&
           [self.experimentId isEqualToString:experiment.experimentId] &&
           [self.strategyId isEqualToString:experiment.strategyId] &&
           [self.variables isEqualToDictionary:experiment.variables];
}

- (NSUInteger)hash {
    return self.layerId.hash ^ self.experimentId.hash ^ self.strategyId.hash ^ self.variables.hash;
}

- (id)toJSONObject {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"layerId"] = self.layerId.copy;
    dic[@"fetchTime"] = @(self.fetchTime);
    if (self.experimentId) {
        dic[@"experimentId"] = self.experimentId.copy;
    }
    if (self.strategyId) {
        dic[@"strategyId"] = self.strategyId.copy;
    }
    if (self.variables) {
        dic[@"variables"] = self.variables.copy;
    }
    return dic;
}

@end
