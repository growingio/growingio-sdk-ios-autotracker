//
// GrowingViewElementEvent.h
// GrowingAnalytics
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

#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"
#import "GrowingTrackerCore/Event/GrowingBaseAttributesEvent.h"

// 泛型类型，可以生成多个类型event，故可以设置eventType

NS_ASSUME_NONNULL_BEGIN

@class GrowingViewElementBuilder;

@interface GrowingViewElementEvent : GrowingBaseAttributesEvent

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *textValue;
@property (nonatomic, copy, readonly) NSString *xpath;
@property (nonatomic, copy, readonly) NSString *xcontent;
@property (nonatomic, assign, readonly) int index;

+ (GrowingViewElementBuilder *)builder;

@end

@interface GrowingViewElementBuilder : GrowingBaseAttributesBuilder

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *textValue;
@property (nonatomic, copy, readonly) NSString *xpath;
@property (nonatomic, copy, readonly) NSString *xcontent;
@property (nonatomic, assign, readonly) int index;

- (GrowingViewElementBuilder * (^)(NSString *value))setPath;
- (GrowingViewElementBuilder * (^)(NSString *value))setTextValue;
- (GrowingViewElementBuilder * (^)(NSString *value))setXpath;
- (GrowingViewElementBuilder * (^)(NSString *value))setXcontent;
- (GrowingViewElementBuilder * (^)(int value))setIndex;
- (GrowingViewElementBuilder * (^)(NSDictionary<NSString *, NSObject *> *value))setAttributes;

// extra add
// 覆盖返回值类型为GrowingViewElementBuilder
- (GrowingViewElementBuilder * (^)(NSString *value))setEventType;

@end

NS_ASSUME_NONNULL_END
