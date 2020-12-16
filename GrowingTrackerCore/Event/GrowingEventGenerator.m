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
@implementation GrowingEventGenerator

+ (void)generateVisitEvent:(long long)ts latitude:(double)latitude longitude:(double)longitude;
{
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       GrowingBaseBuilder *builder =
                           GrowingVisitEvent.builder.setTimestamp(ts).setLatitude(latitude).setLongitude(longitude);
                       [[GrowingEventManager shareInstance] postEventBuidler:builder];
                   }];
}

+ (void)generateCustomEvent:(NSString *_Nonnull)name
                 attributes:(NSDictionary<NSString *, NSObject *> *_Nullable)attributes {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       GrowingBaseBuilder *builder =
                           GrowingCustomEvent.builder.setEventName(name).setAttributes(attributes);
                       [[GrowingEventManager shareInstance] postEventBuidler:builder];
                   }];
}

+ (void)generateConversionAttributesEvent:(NSDictionary<NSString *, NSObject *> *_Nonnull)variables {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       GrowingBaseBuilder *builder = GrowingConversionVariableEvent.builder.setAttributes(variables);
                       [[GrowingEventManager shareInstance] postEventBuidler:builder];
                   }];
}

+ (void)generateLoginUserAttributesEvent:(NSDictionary<NSString *, NSObject *> *_Nonnull)attributes {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       GrowingBaseBuilder *builder = GrowingLoginUserAttributesEvent.builder.setAttributes(attributes);
                       [[GrowingEventManager shareInstance] postEventBuidler:builder];
                   }];
}

+ (void)generateVisitorAttributesEvent:(NSDictionary<NSString *, NSObject *> *_Nonnull)attributes {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       GrowingBaseBuilder *builder = GrowingVisitorAttributesEvent.builder.setAttributes(attributes);
                       [[GrowingEventManager shareInstance] postEventBuidler:builder];
                   }];
}

+ (void)generateAppCloseEvent {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       GrowingBaseBuilder *builder = GrowingAppCloseEvent.builder;
                       [[GrowingEventManager shareInstance] postEventBuidler:builder];
                   }];
}

@end
