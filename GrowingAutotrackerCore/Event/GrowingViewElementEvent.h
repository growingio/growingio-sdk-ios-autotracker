//
// GrowingViewElementEvent.h
// GrowingAnalytics-Autotracker-AutotrackerCore-Tracker-TrackerCore
//
//  Created by sheng on 2020/11/16.
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


#import "GrowingBaseEvent.h"
#import "GrowingAutotrackEventType.h"
//泛型类型，可以生成多个类型event，故可以设置eventType

NS_ASSUME_NONNULL_BEGIN
@class GrowingViewElementBuilder;
@interface GrowingViewElementEvent : GrowingBaseEvent

@property (nonatomic, copy, readonly) NSString * _Nonnull pageName;
@property (nonatomic, assign, readonly) long long pageShowTimestamp;
@property (nonatomic, copy, readonly) NSString * _Nonnull textValue;
@property (nonatomic, copy, readonly) NSString * _Nonnull xpath;
@property (nonatomic, assign, readonly) int index;

+ (GrowingViewElementBuilder *)builder;

@end

@interface GrowingViewElementBuilder : GrowingBaseBuilder

@property (nonatomic, copy, readonly) NSString * _Nonnull pageName;
@property (nonatomic, assign, readonly) long long pageShowTimestamp;
@property (nonatomic, copy, readonly) NSString * _Nonnull textValue;
@property (nonatomic, copy, readonly) NSString * _Nonnull xpath;
@property (nonatomic, assign, readonly) int index;

- (GrowingViewElementBuilder *(^)(NSString *value))setPageName;
- (GrowingViewElementBuilder *(^)(long long value))setPageShowTimestamp;
- (GrowingViewElementBuilder *(^)(NSString *value))setTextValue;
- (GrowingViewElementBuilder *(^)(NSString *value))setXpath;
- (GrowingViewElementBuilder *(^)(int value))setIndex;

//extra add
//覆盖返回值类型为GrowingViewElementBuilder
- (GrowingViewElementBuilder *(^)(NSString *value))setEventType;

@end

NS_ASSUME_NONNULL_END
