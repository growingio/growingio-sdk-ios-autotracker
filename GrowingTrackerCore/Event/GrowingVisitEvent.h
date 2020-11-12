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


#import "GrowingEvent.h"
#import "GrowingBaseEvent.h"

typedef NS_ENUM(NSUInteger, GrowingDeviceType) {
    GrowingDeviceTypePhone, GrowingDeviceTypePad
};

@interface GrowingVisitEvent : GrowingBaseEvent

@property(nonatomic, copy, readonly) NSString *_Nullable networkState;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull screenHeight;
@property(nonatomic, strong, readonly) NSNumber *_Nonnull screenWidth;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceBrand;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceModel;
@property(nonatomic, copy, readonly) NSString *_Nonnull deviceType;
@property(nonatomic, copy, readonly) NSString *_Nonnull platform;
@property(nonatomic, copy, readonly) NSString *_Nonnull platformVersion;
@property(nonatomic, copy, readonly) NSString *_Nonnull appName;
@property(nonatomic, copy, readonly) NSString *_Nonnull appVersion;
@property(nonatomic, copy, readonly) NSString *_Nonnull language;
@property(nonatomic, strong, readonly) NSNumber *_Nullable latitude;
@property(nonatomic, strong, readonly) NSNumber *_Nullable longitude;
@property(nonatomic, copy, readonly) NSString *_Nonnull idfa;
@property(nonatomic, copy, readonly) NSString *_Nonnull idfv;
@property(nonatomic, copy, readonly) NSString *_Nonnull sdkVersion;
@property(nonatomic, strong, readonly) NSDictionary *_Nonnull extraSdk;

//@property(nonatomic, copy, readwrite) NSString *_Nullable sessionId;
//@property(nonatomic, strong, readwrite) NSNumber *_Nonnull timestamp;

@end

