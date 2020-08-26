//
//  GrowingPageEvent.h
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/5/18.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingPageEvent : GrowingEvent

@property (nonatomic, copy, readonly) NSString * _Nullable pageTitle;
@property (nonatomic, copy, readonly) NSString * _Nullable referralPage;
@property (nonatomic, copy, readonly) NSString * _Nullable pageName;
@property (nonatomic, copy, readonly) NSString * _Nullable orientation;
@property (nonatomic, copy, readonly) NSString * _Nullable networkState;

+ (instancetype)pageEventWithTitle:(NSString *)title pageName:(NSString *)pageName timestamp:(NSNumber *)timestamp;

+ (instancetype)pageEventWithTitle:(NSString *)title pageName:(NSString *)pageName referralPage:(NSString * _Nullable)referralPage;

- (instancetype)initWithTitle:(NSString *)title pageName:(NSString *)pageName referralPage:(NSString * _Nullable )referralPage;

+ (instancetype)hybridPageEventWithDataDict:(NSDictionary *)dataDict;

@end

NS_ASSUME_NONNULL_END
