//
// GrowingEventGenerator.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/12.
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

#import "GrowingEventGenerator.h"

#import "GrowingAppCloseEvent.h"
#import "GrowingConversionVariableEvent.h"
#import "GrowingDispatchManager.h"
#import "GrowingEventManager.h"
#import "GrowingLoginUserAttributesEvent.h"
#import "GrowingVisitEvent.h"
#import "GrowingVisitorAttributesEvent.h"

#import "GrowingLogMacros.h"
#import "GrowingLogger.h"
@implementation GrowingEventGenerator

+ (void)generateVisitEvent {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingBaseBuilder *builder = GrowingVisitEvent.builder;
        [[GrowingEventManager sharedInstance] postEventBuidler:builder];
    }];
}

+ (void)generateCustomEvent:(NSString *_Nonnull)name
                 attributes:(NSDictionary<NSString *, NSObject *> *_Nullable)attributes {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingBaseBuilder *builder = GrowingCustomEvent.builder.setEventName(name).setAttributes(attributes);
        [[GrowingEventManager sharedInstance] postEventBuidler:builder];
    }];
}

+ (void)generateConversionAttributesEvent:(NSDictionary<NSString *, NSObject *> *_Nonnull)variables {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingBaseBuilder *builder = GrowingConversionVariableEvent.builder.setAttributes(variables);
        [[GrowingEventManager sharedInstance] postEventBuidler:builder];
    }];
}

+ (void)generateLoginUserAttributesEvent:(NSDictionary<NSString *, NSObject *> *_Nonnull)attributes {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingBaseBuilder *builder = GrowingLoginUserAttributesEvent.builder.setAttributes(attributes);
        [[GrowingEventManager sharedInstance] postEventBuidler:builder];
    }];
}

+ (void)generateVisitorAttributesEvent:(NSDictionary<NSString *, NSObject *> *_Nonnull)attributes {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingBaseBuilder *builder = GrowingVisitorAttributesEvent.builder.setAttributes(attributes);
        [[GrowingEventManager sharedInstance] postEventBuidler:builder];
    }];
}

+ (void)generateAppCloseEvent {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        GrowingBaseBuilder *builder = GrowingAppCloseEvent.builder;
        [[GrowingEventManager sharedInstance] postEventBuidler:builder];
    }];
}

@end
