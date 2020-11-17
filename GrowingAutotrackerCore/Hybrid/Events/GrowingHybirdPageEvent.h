//
// GrowingHybirdPageEvent.h
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


#import "GrowingPageEvent.h"

NS_ASSUME_NONNULL_BEGIN
@class GrowingHybirdPageBuilder;
@interface GrowingHybirdPageEvent : GrowingPageEvent
@property (nonatomic, copy, readonly) NSString *protocolType;
@property (nonatomic, copy, readonly) NSString *query;

+ (GrowingHybirdPageBuilder*)builder;


@end

@interface GrowingHybirdPageBuilder : GrowingPageBuilder
@property (nonatomic, copy, readonly) NSString *protocolType;
@property (nonatomic, strong, readonly) NSString *query;

- (GrowingHybirdPageBuilder *(^)(NSString *value))setQuery;
- (GrowingHybirdPageBuilder *(^)(NSString *value))setProtocolType;

//重写
- (GrowingHybirdPageBuilder *(^)(NSString *value))setPageName;
- (GrowingHybirdPageBuilder *(^)(NSString *value))setOrientation;
- (GrowingHybirdPageBuilder *(^)(NSString *value))setTitle;
- (GrowingHybirdPageBuilder *(^)(NSString *value))setReferralPage;
@end

NS_ASSUME_NONNULL_END
