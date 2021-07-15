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
@class GrowingVisitBuidler;
@interface GrowingVisitEvent : GrowingBaseEvent

//@property(nonatomic, copy, readonly) NSString *_Nonnull platform;
//@property(nonatomic, copy, readonly) NSString *_Nonnull platformVersion;
@property(nonatomic, copy, readonly) NSString *_Nonnull idfa;
@property(nonatomic, copy, readonly) NSString *_Nonnull idfv;
@property(nonatomic, strong, readonly) NSDictionary<NSString *,NSString*> *_Nonnull extraSdk;

//@property(nonatomic, copy, readwrite) NSString *_Nullable sessionId;
//@property(nonatomic, strong, readwrite) NSNumber *_Nonnull timestamp;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

+ (GrowingVisitBuidler *_Nonnull)builder;

@end

@interface GrowingVisitBuidler : GrowingBaseBuilder

@property(nonatomic, copy, readonly) NSString *_Nonnull idfa;
@property(nonatomic, copy, readonly) NSString *_Nonnull idfv;
@property(nonatomic, strong, readonly) NSDictionary<NSString *,NSString*> *_Nonnull extraSdk;

NS_ASSUME_NONNULL_BEGIN
//override set method return type
- (GrowingVisitBuidler *(^)(long long value))setTimestamp;
- (GrowingVisitBuidler *(^)(NSString *value))setPlatform;
- (GrowingVisitBuidler *(^)(NSString *value))setPlatformVersion;

//new set methods
- (GrowingVisitBuidler *(^)(NSString *value))setIdfa;
- (GrowingVisitBuidler *(^)(NSString *value))setIdfv;
- (GrowingVisitBuidler *(^)(NSDictionary<NSString *,NSString*> *value))setExtraSdk;

NS_ASSUME_NONNULL_END
@end
