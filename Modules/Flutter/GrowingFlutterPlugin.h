//
// GrowingFlutterPlugin.h
// GrowingAnalytics
//
//  Created by sheng on 2021/8/13.
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

#import <Foundation/Foundation.h>
#import "GrowingModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingFlutterPlugin : NSObject <GrowingModuleProtocol>

+ (instancetype)sharedInstance;

@property (nonatomic, copy) void (^onWebCircleStart)(void);
@property (nonatomic, copy) void (^onWebCircleStop)(void);
@property (nonatomic, copy) void (^_Nullable onFlutterCircleDataChange)(NSDictionary *data);

- (void)trackPageEvent:(NSDictionary *)arguments attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes;
- (void)trackViewElementEvent:(NSDictionary *)arguments
                   attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes;

@end

NS_ASSUME_NONNULL_END
