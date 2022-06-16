//
//  GrowingGA3Event.h
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/5/31.
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

#import "GrowingBaseEvent.h"
#import "Modules/GA3Adapter/GrowingGA3TrackerInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingGA3Builder;

@interface GrowingGA3Event : GrowingBaseEvent

@property (nonatomic, strong, readonly) GrowingBaseEvent *baseEvent;
@property (nonatomic, weak, readonly) GrowingGA3TrackerInfo *info;

+ (GrowingGA3Builder *)builder;

@end

@interface GrowingGA3Builder : GrowingBaseBuilder

@property (nonatomic, strong, readonly) GrowingBaseEvent *baseEvent;
@property (nonatomic, weak, readonly) GrowingGA3TrackerInfo *info;

- (GrowingGA3Builder *(^)(GrowingBaseEvent *baseEvent))setBaseEvent;
- (GrowingGA3Builder *(^)(GrowingGA3TrackerInfo *info))setTrackerInfo;

@end

NS_ASSUME_NONNULL_END
