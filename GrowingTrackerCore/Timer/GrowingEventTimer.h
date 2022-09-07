//
//  GrowingEventTimer.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/9/5.
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

NS_ASSUME_NONNULL_BEGIN

@interface GrowingEventTimer : NSObject

+ (nullable NSString *)trackTimerStart:(NSString *)eventName;

+ (void)trackTimerPause:(NSString *)timerId;

+ (void)trackTimerResume:(NSString *)timerId;

+ (void)trackTimerEnd:(NSString *)timerId withAttributes:(NSDictionary <NSString *, NSString *> *_Nullable)attributes;

+ (void)removeTimer:(NSString *)timerId;

+ (void)clearAllTimers;

+ (void)handleAllTimersPause;

+ (void)handleAllTimersResume;

@end

NS_ASSUME_NONNULL_END
