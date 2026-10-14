//
// GrowingUniAppPlugin.h
// GrowingAnalytics
//
//  Created by YoloMao on 2024/12/2.
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

#import <Foundation/Foundation.h>
#import "GrowingModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingUniAppPlugin : NSObject <GrowingModuleProtocol>

+ (instancetype)sharedInstance;
/// The plugin must apply source/session, emit its PAGE once, then use this context for new events.
@property (nonatomic, copy, nullable) void (^onDataSourceChanged)(NSDictionary *context);
@property (atomic, copy, readonly) NSDictionary *routingContext;
- (void)confirmRoutingContext:(NSDictionary *)context;

- (void)trackPageEvent:(NSString *)pageName attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes;
- (void)trackPageEvent:(NSString *)pageName
            attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes
        routingContext:(NSDictionary *)routingContext;

@end

NS_ASSUME_NONNULL_END
