//
//  GrowingVisitEvent.h
//  GrowingTracker
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


#import "GrowingBaseEvent.h"

typedef NS_ENUM(NSUInteger, GrowingDeviceType) {
    GrowingDeviceTypePhone, GrowingDeviceTypePad
};
@class GrowingVisitBuilder;
@interface GrowingVisitEvent : GrowingBaseEvent

@property(nonatomic, copy, readonly) NSString *_Nonnull idfa;
@property(nonatomic, copy, readonly) NSString *_Nonnull idfv;
@property(nonatomic, strong, readonly) NSDictionary<NSString *,NSString*> *_Nonnull extraSdk;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

+ (GrowingVisitBuilder *_Nonnull)builder;

@end

@interface GrowingVisitBuilder : GrowingBaseBuilder

@property(nonatomic, copy, readonly) NSString *_Nonnull idfa;
@property(nonatomic, copy, readonly) NSString *_Nonnull idfv;
@property(nonatomic, strong, readonly) NSDictionary<NSString *,NSString*> *_Nonnull extraSdk;

NS_ASSUME_NONNULL_BEGIN
//override set method return type
- (GrowingVisitBuilder *(^)(long long value))setTimestamp;
- (GrowingVisitBuilder *(^)(NSString *value))setPlatform;
- (GrowingVisitBuilder *(^)(NSString *value))setPlatformVersion;

//new set methods
- (GrowingVisitBuilder *(^)(NSString *value))setIdfa;
- (GrowingVisitBuilder *(^)(NSString *value))setIdfv;
- (GrowingVisitBuilder *(^)(NSDictionary<NSString *,NSString*> *value))setExtraSdk;

NS_ASSUME_NONNULL_END
@end
