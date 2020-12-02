//
// GrowingHybirdViewElementEvent.h
// GrowingAnalytics-Autotracker-AutotrackerCore-Tracker-TrackerCore
//
//  Created by sheng on 2020/11/17.
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


#import "GrowingViewElementEvent.h"

NS_ASSUME_NONNULL_BEGIN
@class GrowingHybirdViewElementBuilder;
@interface GrowingHybirdViewElementEvent : GrowingViewElementEvent
@property (nonatomic, copy, readonly) NSString *hyperlink;
@property (nonatomic, copy, readonly) NSString *query;

+ (GrowingHybirdViewElementBuilder*)builder;
@end

@interface GrowingHybirdViewElementBuilder : GrowingViewElementBuilder

@property (nonatomic, copy, readonly) NSString *hyperlink;
@property (nonatomic, copy, readonly) NSString *query;


- (GrowingHybirdViewElementBuilder *(^)(NSString *value))setQuery;
- (GrowingHybirdViewElementBuilder *(^)(NSString *value))setHyperlink;

//重写
- (GrowingHybirdViewElementBuilder *(^)(NSString *value))setPath;
- (GrowingHybirdViewElementBuilder *(^)(long long value))setPageShowTimestamp;
- (GrowingHybirdViewElementBuilder *(^)(NSString *value))setTextValue;
- (GrowingHybirdViewElementBuilder *(^)(NSString *value))setXpath;
- (GrowingHybirdViewElementBuilder *(^)(int value))setIndex;

//extra add
- (GrowingHybirdViewElementBuilder *(^)(NSString *value))setEventType;

@end

NS_ASSUME_NONNULL_END
