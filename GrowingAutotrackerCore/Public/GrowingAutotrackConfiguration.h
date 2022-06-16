//
//  GrowingAutotrackConfiguration.h
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

#import "GrowingTrackConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GrowingIgnorePolicy) {
    GrowingIgnoreNone = 0,
    GrowingIgnoreSelf = 1,     // 忽略自身
    GrowingIgnoreChildren = 2, // 忽略所有子页面和孙子页面
    GrowingIgnoreAll = 3,      // 忽略自身 + 忽略所有子页面和孙子页面
};

@interface GrowingAutotrackConfiguration : GrowingTrackConfiguration

@property (nonatomic, assign) float impressionScale;

@end

NS_ASSUME_NONNULL_END
