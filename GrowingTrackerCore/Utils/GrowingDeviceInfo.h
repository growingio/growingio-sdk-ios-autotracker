//
//  GrowingDeviceInfo.h
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/11/19.
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

#import <Foundation/Foundation.h>

@interface GrowingDeviceInfo : NSObject

@property (nonatomic, readonly, copy) NSString *deviceIDString;
@property (nonatomic, readonly, copy) NSString *bundleID;
@property (nonatomic, readonly, copy) NSString *displayName;
@property (nonatomic, readonly, copy) NSString *language;
@property (nonatomic, readonly, copy) NSString *deviceModel;
@property (nonatomic, readonly, copy) NSString *deviceBrand;
@property (nonatomic, readonly, copy) NSString *deviceType;
@property (nonatomic, readonly, copy) NSString *platform;
@property (nonatomic, readonly, copy) NSString *platformVersion;
@property (nonatomic, readonly, copy) NSString *appFullVersion;
@property (nonatomic, readonly, copy) NSString *appVersion;
@property (nonatomic, readonly, copy) NSString *urlScheme;
@property (nonatomic, readonly, copy) NSString *deviceOrientation;
@property (nonatomic, readonly, copy) NSString *idfv;
@property (nonatomic, readonly, copy) NSString *idfa;
@property (nonatomic, readonly, assign) int appState;
@property (nonatomic, readonly, assign) CGFloat screenWidth;
@property (nonatomic, readonly, assign) CGFloat screenHeight;
@property (nonatomic, readonly, assign) NSInteger timezoneOffset;
@property (nonatomic, readonly, assign) BOOL isNewDevice;

+ (instancetype)currentDeviceInfo;
+ (void)setup;

@end
