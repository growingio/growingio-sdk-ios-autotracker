//
//  GrowingActivateEvent.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
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

#import "GrowingTrackerCore/Event/GrowingBaseAttributesEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingActivateBuilder;

@interface GrowingActivateEvent : GrowingBaseAttributesEvent

@property (nonatomic, copy, readonly) NSString *idfa;
@property (nonatomic, copy, readonly) NSString *idfv;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (GrowingActivateBuilder *)builder;

@end

@interface GrowingActivateBuilder : GrowingBaseAttributesBuilder

@property (nonatomic, copy, readonly) NSString *idfa;
@property (nonatomic, copy, readonly) NSString *idfv;

- (GrowingActivateBuilder *(^)(NSDictionary<NSString *, NSObject *> *value))setAttributes;

@end

NS_ASSUME_NONNULL_END
