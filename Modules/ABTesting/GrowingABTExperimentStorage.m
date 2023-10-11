//
//  GrowingABTExperimentStorage.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/11.
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

#import "Modules/ABTesting/GrowingABTExperimentStorage.h"
#import "GrowingTrackerCore/FileStorage/GrowingFileStorage.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "Modules/ABTesting/GrowingABTExperiment+Private.h"

static NSString *const kGrowingABTestingExperimentKey = @"GrowingABTestingExperimentKey";

@interface GrowingABTExperimentStorage ()

@property (nonatomic, strong) GrowingFileStorage *storage;
@property (nonatomic, strong) NSMutableArray<GrowingABTExperiment *> *experiments;

@end

@implementation GrowingABTExperimentStorage {
    GROWING_LOCK_DECLARE(lock);
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        GROWING_LOCK_INIT(lock);
        _storage = [[GrowingFileStorage alloc] initWithName:@"config"];
        _experiments = [NSMutableArray array];
        NSArray *array = [_storage arrayForKey:kGrowingABTestingExperimentKey];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in array) {
                NSString *layerId = dic[@"layerId"];
                NSString *experimentId = dic[@"experimentId"];
                NSString *strategyId = dic[@"strategyId"];
                NSDictionary *variables = dic[@"variables"];
                long long fetchTime = ((NSNumber *)dic[@"fetchTime"]).longLongValue;
                GrowingABTExperiment *e = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                           experimentId:experimentId
                                                                             strategyId:strategyId
                                                                              variables:variables
                                                                              fetchTime:fetchTime];
                [_experiments addObject:e];
            }
        }
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Private Method

- (void)synchronize {
    NSMutableArray *array = [NSMutableArray array];
    for (GrowingABTExperiment *exp in self.experiments) {
        [array addObject:exp.toJSONObject];
    }
    [self.storage setArray:array forKey:kGrowingABTestingExperimentKey];
}

- (nullable GrowingABTExperiment *)findExperiment:(NSString *)layerId {
    for (GrowingABTExperiment *exp in self.experiments) {
        if ([exp.layerId isEqualToString:layerId]) {
            return exp;
        }
    }
    return nil;
}

- (void)addExperiment:(GrowingABTExperiment *)experiment {
    GROWING_LOCK(lock);
    for (GrowingABTExperiment *exp in self.experiments) {
        if ([exp.layerId isEqualToString:experiment.layerId]) {
            [self.experiments removeObject:exp];
            break;
        }
    }
    [self.experiments addObject:experiment];
    [self synchronize];
    GROWING_UNLOCK(lock);
}

- (void)removeExperiment:(GrowingABTExperiment *)experiment {
    GROWING_LOCK(lock);
    [self.experiments removeObject:experiment];
    [self synchronize];
    GROWING_UNLOCK(lock);
}

#pragma mark - Public Method

+ (nullable GrowingABTExperiment *)findExperiment:(NSString *)layerId {
    return [GrowingABTExperimentStorage.sharedInstance findExperiment:layerId];
}

+ (void)addExperiment:(GrowingABTExperiment *)experiment {
    return [GrowingABTExperimentStorage.sharedInstance addExperiment:experiment];
}

+ (void)removeExperiment:(GrowingABTExperiment *)experiment {
    return [GrowingABTExperimentStorage.sharedInstance removeExperiment:experiment];
}

@end
