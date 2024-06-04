//
//  GrowingPropertyPluginManager.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/6/4.
//  Copyright (C) 2024 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Event/GrowingPropertyPluginManager.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Public/GrowingPropertyPlugin.h"
#import "GrowingTrackerCore/Public/GrowingBaseEvent.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"

@interface GrowingPropertyPluginEventFilterImpl : NSObject <GrowingPropertyPluginEventFilter>

@property (nonatomic, assign, readonly) BOOL isFromHybrid;
@property (nonatomic, assign, readonly) long long time;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *type;

- (instancetype)initWithEvent:(GrowingBaseBuilder *)event;

@end

@interface GrowingPropertyPluginManager ()

@property (nonatomic, strong) NSMutableArray *plugins;

@end

@implementation GrowingPropertyPluginManager

+ (instancetype)sharedInstance {
    static GrowingPropertyPluginManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setPropertyPlugins:(id <GrowingPropertyPlugin>)plugin {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        [self.plugins addObject:plugin];
        [self.plugins sortUsingComparator:^NSComparisonResult(id<GrowingPropertyPlugin> _Nonnull obj1, id<GrowingPropertyPlugin> _Nonnull obj2) {
            if ([obj1 priority] > [obj2 priority]) {
                return NSOrderedDescending;
            } else if ([obj1 priority] < [obj2 priority]) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    }];
}

- (NSDictionary<NSString *, id> *)execute:(GrowingBaseBuilder *)event {
    if (self.plugins.count == 0) {
        return event.attributes;
    }
    GrowingPropertyPluginEventFilterImpl *filter = [[GrowingPropertyPluginEventFilterImpl alloc] initWithEvent:event];
    NSDictionary<NSString *, id> *attributes = event.attributes.copy;
    for (int i = 0; i < self.plugins.count; i++) {
        id <GrowingPropertyPlugin> plugin = self.plugins[i];
        if (![plugin isMatchedWithFilter:filter]) {
            continue;
        }
        attributes = [plugin attributes:attributes];
    }
    return attributes.copy;
}

#pragma mark - Setter && Getter

- (NSMutableArray *)plugins {
    if (!_plugins) {
        _plugins = [NSMutableArray array];
    }
    return _plugins;
}

@end

@implementation GrowingPropertyPluginEventFilterImpl


- (instancetype)initWithEvent:(GrowingBaseBuilder *)event {
    if (self = [super init]) {
        _isFromHybrid = event.scene == GrowingEventSceneHybrid;
        if ([event isKindOfClass:[GrowingCustomEvent class]]) {
            _name = ((GrowingCustomEvent *)event).eventName;
        } else {
            _name = @"";
        }
        _time = event.timestamp;
        _type = event.eventType;
    }
    return self;
}

@end
