//
// GrowingHybridViewElementEvent.h
// GrowingAnalytics
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

#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingHybridViewElementBuilder;

@interface GrowingHybridViewElementEvent : GrowingViewElementEvent

@property (nonatomic, copy, readonly) NSString *xcontent;
@property (nonatomic, copy, readonly) NSString *hyperlink;
@property (nonatomic, copy, readonly) NSString *query;

+ (GrowingHybridViewElementBuilder *)builder;

@end

@interface GrowingHybridViewElementBuilder : GrowingViewElementBuilder

@property (nonatomic, copy, readonly) NSString *xcontent;
@property (nonatomic, copy, readonly) NSString *hyperlink;
@property (nonatomic, copy, readonly) NSString *query;

- (GrowingHybridViewElementBuilder * (^)(NSString *value))setXcontent;
- (GrowingHybridViewElementBuilder * (^)(NSString *value))setQuery;
- (GrowingHybridViewElementBuilder * (^)(NSString *value))setHyperlink;

// 重写
- (GrowingHybridViewElementBuilder * (^)(NSString *value))setPath;
- (GrowingHybridViewElementBuilder * (^)(NSString *value))setTextValue;
- (GrowingHybridViewElementBuilder * (^)(NSString *value))setXpath;
- (GrowingHybridViewElementBuilder * (^)(int value))setIndex;
- (GrowingHybridViewElementBuilder * (^)(NSString *value))setDomain;
- (GrowingHybridViewElementBuilder * (^)(NSDictionary<NSString *, NSObject *> *value))setAttributes;

// extra add
- (GrowingHybridViewElementBuilder * (^)(NSString *value))setEventType;

@end

NS_ASSUME_NONNULL_END
