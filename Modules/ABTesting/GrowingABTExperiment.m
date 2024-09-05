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
@property (nonatomic, copy, nullable, readwrite) NSString *layerName;
@property (nonatomic, copy, nullable, readwrite) NSString *experimentId;
@property (nonatomic, copy, nullable, readwrite) NSString *experimentName;
@property (nonatomic, copy, nullable, readwrite) NSString *strategyId;
@property (nonatomic, copy, nullable, readwrite) NSString *strategyName;
@property (nonatomic, copy, nullable, readwrite) NSDictionary *variables;
@property (nonatomic, assign) long long fetchTime;

@end

@implementation GrowingABTExperiment

- (instancetype)initWithLayerId:(NSString *)layerId
                      layerName:(NSString *_Nullable)layerName
                   experimentId:(NSString *_Nullable)experimentId
                 experimentName:(NSString *_Nullable)experimentName
                     strategyId:(NSString *_Nullable)strategyId
                   strategyName:(NSString *_Nullable)strategyName
                      variables:(NSDictionary *_Nullable)variables
                      fetchTime:(long long)fetchTime {
    if (self = [super init]) {
        _layerId = layerId.copy;
        _layerName = layerName.copy;
        _experimentId = experimentId.copy;
        _experimentName = experimentName.copy;
        _strategyId = strategyId.copy;
        _strategyName = strategyName.copy;
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
    if (![self.layerId isEqualToString:experiment.layerId]) {
        return NO;
    }
    
    if (experiment.layerName != nil && ![self.layerName isEqualToString:experiment.layerName]) {
        return NO;
    }

    if (experiment.layerName == nil && self.layerName != nil) {
        return NO;
    }

    if (experiment.experimentId != nil && ![self.experimentId isEqualToString:experiment.experimentId]) {
        return NO;
    }

    if (experiment.experimentId == nil && self.experimentId != nil) {
        return NO;
    }
    
    if (experiment.experimentName != nil && ![self.experimentName isEqualToString:experiment.experimentName]) {
        return NO;
    }

    if (experiment.experimentName == nil && self.experimentName != nil) {
        return NO;
    }

    if (experiment.strategyId != nil && ![self.strategyId isEqualToString:experiment.strategyId]) {
        return NO;
    }

    if (experiment.strategyId == nil && self.strategyId != nil) {
        return NO;
    }
    
    if (experiment.strategyName != nil && ![self.strategyName isEqualToString:experiment.strategyName]) {
        return NO;
    }

    if (experiment.strategyName == nil && self.strategyName != nil) {
        return NO;
    }

    if (experiment.variables != nil && ![self.variables isEqualToDictionary:experiment.variables]) {
        return NO;
    }

    if (experiment.variables == nil && self.variables != nil) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash {
    return self.layerId.hash ^ self.layerName.hash ^ self.experimentId.hash ^ self.experimentName.hash ^ self.strategyId.hash ^ self.strategyName.hash ^ self.variables.hash;
}

- (id)toJSONObject {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"layerId"] = self.layerId.copy;
    dic[@"fetchTime"] = @(self.fetchTime);
    if (self.layerName) {
        dic[@"layerName"] = self.layerName.copy;
    }
    if (self.experimentId) {
        dic[@"experimentId"] = self.experimentId.copy;
    }
    if (self.experimentName) {
        dic[@"experimentName"] = self.experimentName.copy;
    }
    if (self.strategyId) {
        dic[@"strategyId"] = self.strategyId.copy;
    }
    if (self.strategyName) {
        dic[@"strategyName"] = self.strategyName.copy;
    }
    if (self.variables) {
        dic[@"variables"] = self.variables.copy;
    }
    return dic;
}

@end
