//
//  GrowingGA3TrackerInfo.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/31.
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

#import "Modules/GA3Adapter/GrowingGA3TrackerInfo.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"

@interface GrowingGA3TrackerInfo () <GrowingEventInterceptor>

@property (nonatomic, copy) GrowingGA3TrackerTransformEventBlock block;

@end

@implementation GrowingGA3TrackerInfo

- (instancetype)initWithTracker:(id)tracker
                   dataSourceId:(NSString *)dataSourceId
                      sessionId:(NSString *)sessionId
            transformEventBlock:(GrowingGA3TrackerTransformEventBlock)transformEventBlock {
    if (self = [super init]) {
        _tracker = tracker;
        _dataSourceId = dataSourceId.copy;
        _sessionId = sessionId.copy;
        _block = transformEventBlock;
        _extraParams = @{}.mutableCopy;
    }
    
    return self;
}

- (void)addParameter:(NSString *)key value:(NSString *)value {
    if (!key || key.length == 0) {
        return;
    }
    
    if (!value || [value isKindOfClass:NSNull.class]) {
        [self.extraParams removeObjectForKey:key];
        return;
    }
    
    [self.extraParams setObject:value forKey:key];
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventDidBuild:(GrowingBaseEvent *)event {
    if (!self.block) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.block(event, weakSelf);
}

@end
