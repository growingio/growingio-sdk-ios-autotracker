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

static dispatch_queue_t GrowingABTStorageIOQueue(void) {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.growingio.abtesting.storage", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

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
                NSString *layerName = dic[@"layerName"];
                NSString *experimentId = dic[@"experimentId"];
                NSString *experimentName = dic[@"experimentName"];
                NSString *strategyId = dic[@"strategyId"];
                NSString *strategyName = dic[@"strategyName"];
                NSDictionary *variables = dic[@"variables"];
                long long fetchTime = ((NSNumber *)dic[@"fetchTime"]).longLongValue;
                GrowingABTExperiment *e = [[GrowingABTExperiment alloc] initWithLayerId:layerId
                                                                              layerName:layerName
                                                                           experimentId:experimentId
                                                                         experimentName:experimentName
                                                                             strategyId:strategyId
                                                                           strategyName:strategyName
                                                                              variables:variables
                                                                              fetchTime:fetchTime];
                if ([dic[@"identity"] isKindOfClass:[NSString class]]) {
                    e.identity = (NSString *)dic[@"identity"];
                }

                if (e.identity.length == 0 || e.isOutdated) {
                    continue;
                }
                [_experiments addObject:e];
            }
            if (_experiments.count != array.count) {
                [self submitSynchronizeTask:_experiments.copy];
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

// 提交写盘任务。必须持锁调用（或 init 中尚无并发时），保证串行队列的写入顺序与内存更新顺序一致
- (void)submitSynchronizeTask:(NSArray<GrowingABTExperiment *> *)snapshot {
    GrowingFileStorage *storage = self.storage;
    dispatch_async(GrowingABTStorageIOQueue(), ^{
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:snapshot.count];
        for (GrowingABTExperiment *exp in snapshot) {
            [array addObject:exp.toJSONObject];
        }
        [storage setArray:array forKey:kGrowingABTestingExperimentKey];
    });
}

// 等待已提交的写盘任务完成。必须在锁外调用，且不能在 GrowingABTStorageIOQueue 上调用
- (void)waitUntilSynchronized {
    dispatch_sync(GrowingABTStorageIOQueue(),
                  ^{
                  });
}

- (nullable GrowingABTExperiment *)findExperiment:(NSString *)layerId identity:(NSString *)identity {
    NSArray<GrowingABTExperiment *> *experiments;
    GROWING_LOCK(lock);
    experiments = self.experiments.copy;
    GROWING_UNLOCK(lock);

    for (GrowingABTExperiment *exp in experiments) {
        if ([exp.layerId isEqualToString:layerId] && [exp.identity isEqualToString:identity]) {
            return exp;
        }
    }
    return nil;
}

- (NSUInteger)indexOfExperimentWithLayerId:(NSString *)layerId identity:(NSString *)identity {
    for (NSUInteger i = 0; i < self.experiments.count; i++) {
        GrowingABTExperiment *exp = self.experiments[i];
        if ([exp.layerId isEqualToString:layerId] && [exp.identity isEqualToString:identity]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)addExperiment:(GrowingABTExperiment *)experiment {
    GROWING_LOCK(lock);
    NSUInteger index = [self indexOfExperimentWithLayerId:experiment.layerId identity:experiment.identity];
    if (index != NSNotFound) {
        [self.experiments removeObjectAtIndex:index];
    }
    [self.experiments addObject:experiment];
    // dispatch_async 非阻塞，可在持锁期间提交；等待放到锁外
    [self submitSynchronizeTask:self.experiments.copy];
    GROWING_UNLOCK(lock);

    [self waitUntilSynchronized];
}

- (void)removeExperiment:(GrowingABTExperiment *)experiment {
    BOOL submitted = NO;
    GROWING_LOCK(lock);
    NSUInteger index = [self indexOfExperimentWithLayerId:experiment.layerId identity:experiment.identity];
    if (index != NSNotFound) {
        [self.experiments removeObjectAtIndex:index];
        [self submitSynchronizeTask:self.experiments.copy];
        submitted = YES;
    }
    GROWING_UNLOCK(lock);

    if (submitted) {
        [self waitUntilSynchronized];
    }
}

#pragma mark - Public Method

+ (nullable GrowingABTExperiment *)findExperiment:(NSString *)layerId identity:(NSString *)identity {
    return [GrowingABTExperimentStorage.sharedInstance findExperiment:layerId identity:identity];
}

+ (void)addExperiment:(GrowingABTExperiment *)experiment {
    return [GrowingABTExperimentStorage.sharedInstance addExperiment:experiment];
}

+ (void)removeExperiment:(GrowingABTExperiment *)experiment {
    return [GrowingABTExperimentStorage.sharedInstance removeExperiment:experiment];
}

@end
