//
//  GrowingAPMModule.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/26.
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

#import <Foundation/Foundation.h>
#import "GrowingModuleProtocol.h"
#import "GrowingTrackConfiguration.h"

#if __has_include(<GrowingAPM/GrowingAPM+Private.h>)
#import <GrowingAPM/GrowingAPM+Private.h>
#else
#import "GrowingAPM+Private.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface GrowingAPMModule : NSObject <GrowingModuleProtocol>

@end

@interface GrowingTrackConfiguration (GrowingAPM)

@property (nonatomic, copy) GrowingAPMConfig *APMConfig;

@end

NS_ASSUME_NONNULL_END
