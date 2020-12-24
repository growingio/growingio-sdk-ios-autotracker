//
// GrowingWebCircleElement.h
// GrowingAnalytics
//
//  Created by sheng on 2020/12/8.
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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GrowingWebCircleElementBuilder;
@interface GrowingWebCircleElement : NSObject
@property (nonatomic, assign, readonly) CGRect rect;
@property (nonatomic, assign, readonly) int zLevel;
@property (nonatomic, copy, readonly) NSString* _Nullable content;
@property (nonatomic, copy, readonly) NSString* _Nonnull xpath;
@property (nonatomic, copy, readonly) NSString* _Nonnull nodeType;
@property (nonatomic, copy, readonly) NSString* _Nullable parentXPath;
@property (nonatomic, assign, readonly) BOOL isContainer;
@property (nonatomic, assign, readonly) int index;
@property (nonatomic, copy, readonly) NSString* _Nonnull page;
@property (nonatomic, copy, readonly) NSString* _Nonnull domain;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

- (NSDictionary *)toDictionary;

- (instancetype)initWithBuilder:(GrowingWebCircleElementBuilder *)builder;
+ (GrowingWebCircleElementBuilder *)builder;

@end

@interface GrowingWebCircleElementBuilder : NSObject
@property (nonatomic, assign, readonly) CGRect rect;
@property (nonatomic, assign, readonly) int zLevel;
@property (nonatomic, copy, readonly) NSString* _Nullable content;
@property (nonatomic, copy, readonly) NSString* _Nonnull xpath;
@property (nonatomic, copy, readonly) NSString* _Nonnull nodeType;
@property (nonatomic, copy, readonly) NSString* _Nullable parentXPath;
@property (nonatomic, assign, readonly) BOOL isContainer;
@property (nonatomic, assign, readonly) int index;
@property (nonatomic, copy, readonly) NSString* _Nonnull page;

- (GrowingWebCircleElementBuilder *(^)(CGRect value))setRect;
- (GrowingWebCircleElementBuilder *(^)(int value))setZLevel;
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setContent;
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setXpath;
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setNodeType;
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setParentXPath;
- (GrowingWebCircleElementBuilder *(^)(BOOL value))setIsContainer;
- (GrowingWebCircleElementBuilder *(^)(int value))setIndex;
- (GrowingWebCircleElementBuilder *(^)(NSString *value))setPage;

- (GrowingWebCircleElement *)build;

@end

NS_ASSUME_NONNULL_END
