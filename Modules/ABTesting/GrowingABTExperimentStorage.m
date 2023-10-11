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
#import "Modules/ABTesting/GrowingABTExperiment+Private.h"
#import "GrowingTrackerCore/FileStorage/GrowingFileStorage.h"

static NSString *const kGrowingABTestingExperimentKey = @"GrowingABTestingExperimentKey";

@interface GrowingABTExperimentStorage ()

@property (nonatomic, strong) GrowingFileStorage *storage;
@property (nonatomic, strong) NSMutableArray<GrowingABTExperiment *> *experiments;

@end

@implementation GrowingABTExperimentStorage

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _storage = [[GrowingFileStorage alloc] initWithName:@"config"];
        _experiments = [NSMutableArray array];
        NSArray *array = [_storage arrayForKey:kGrowingABTestingExperimentKey];
        if ([array isKindOfClass:[NSArray class]]) {
            [_experiments addObjectsFromArray:array];
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

+ (void)addExperiment:(GrowingABTExperiment *)experiment {
    GrowingABTExperimentStorage *storage = GrowingABTExperimentStorage.sharedInstance;
    [storage.experiments addObject:experiment];
    [storage.storage setArray:storage.experiments forKey:kGrowingABTestingExperimentKey];
}

+ (void)removeExperiment:(GrowingABTExperiment *)experiment {
    GrowingABTExperimentStorage *storage = GrowingABTExperimentStorage.sharedInstance;
    [storage.experiments removeObject:experiment];
    [storage.storage setArray:storage.experiments forKey:kGrowingABTestingExperimentKey];
}

+ (NSArray<GrowingABTExperiment *> *)allExperiments {
    return GrowingABTExperimentStorage.sharedInstance.experiments.copy;
}

@end
