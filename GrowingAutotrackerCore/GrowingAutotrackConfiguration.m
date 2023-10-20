//
//  GrowingAutotrackConfiguration.m
//  GrowingAnalytics
//
//  Created by sheng on 2021/5/8.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingAutotrackerCore/Public/GrowingAutotrackConfiguration.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"

@interface GrowingAutotrackConfiguration ()

@property (nonatomic, strong, readwrite) NSMutableSet *ignoreViewClasses;

@end

@implementation GrowingAutotrackConfiguration {
    GROWING_LOCK_DECLARE(lock);
}

- (instancetype)initWithAccountId:(NSString *)accountId {
    if (self = [super initWithAccountId:accountId]) {
        _autotrackEnabled = YES;
        _impressionScale = 0.0f;
        GROWING_LOCK_INIT(lock);
        _ignoreViewClasses = [NSMutableSet set];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingAutotrackConfiguration *configuration = (GrowingAutotrackConfiguration *)[super copyWithZone:zone];
    configuration->_autotrackEnabled = _autotrackEnabled;
    configuration->_impressionScale = _impressionScale;
    configuration->_ignoreViewClasses = _ignoreViewClasses;
    return configuration;
}

- (void)ignoreViewClass:(Class)clazz {
    GROWING_LOCK(lock);
    [self.ignoreViewClasses addObject:clazz];
    GROWING_UNLOCK(lock);
}

- (void)ignoreViewClasses:(NSArray<Class> *)classes {
    GROWING_LOCK(lock);
    [self.ignoreViewClasses addObjectsFromArray:classes];
    GROWING_UNLOCK(lock);
}

@end
