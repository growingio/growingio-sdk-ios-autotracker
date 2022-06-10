//
// GrowingPageEvent.h
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

#import "GrowingBaseEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingAutotrackEventType.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingPageBuilder;

@interface GrowingPageEvent : GrowingBaseEvent

@property (nonatomic, copy, readonly) NSString *pageName;
@property (nonatomic, copy, readonly) NSString *orientation;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *referralPage;

+ (GrowingPageBuilder *)builder;

@end

@interface GrowingPageBuilder : GrowingBaseBuilder

@property (nonatomic, copy, readonly) NSString *pageName;
@property (nonatomic, copy, readonly) NSString *orientation;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *referralPage;

- (GrowingPageBuilder *(^)(NSString *value))setPath;
- (GrowingPageBuilder *(^)(NSString *value))setOrientation;
- (GrowingPageBuilder *(^)(NSString *value))setTitle;
- (GrowingPageBuilder *(^)(NSString *value))setReferralPage;

@end

NS_ASSUME_NONNULL_END
