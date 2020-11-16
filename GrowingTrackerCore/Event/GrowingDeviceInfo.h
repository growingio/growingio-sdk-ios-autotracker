//
//  GrowingDeviceInfo.h
//  GrowingTracker
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
#import "GrowingFileStorage.h"

@interface GrowingDeviceInfo : NSObject

+ (instancetype)currentDeviceInfo;

@property (nonatomic, copy)     NSString*(^deviceIDBlock)(void);
@property (nonatomic, copy)     NSString*(^encryptStringBlock)(NSString *string);

@property (nonatomic, readonly) BOOL isNewInstall;
@property (nonatomic, readonly) BOOL isPastedDeeplinkCallback;
@property (nonatomic, readonly) NSString *idfv;
@property (nonatomic, readonly) NSString *idfa;
@property (nonatomic, readonly) NSString *deviceIDString;
@property (nonatomic, readonly) NSString *bundleID;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSString *language;
@property (nonatomic, readonly) NSString *deviceModel;
@property (nonatomic, readonly) NSString *deviceBrand;
@property (nonatomic, readonly) NSNumber *isPhone;
@property (nonatomic, readonly) NSString *deviceType;
@property (nonatomic, readonly) NSString *platform;
@property (nonatomic, readonly) NSString *platformVersion;
@property (nonatomic, readonly) NSString *appFullVersion;
@property (nonatomic, readonly) NSString *appVersion;
@property (nonatomic, readonly) NSString *carrier;
@property (nonatomic, readonly) NSString *urlScheme;

+ (void)configUrlScheme:(NSString *)urlScheme;

@property (nonatomic, readonly) NSString *sessionID;

@property (nonatomic, strong) GrowingFileStorage *deviceStorage;

- (void)resetSessionID;
- (void)deviceInfoReported;
- (void)pasteboardDeeplinkReported;
+ (CGSize)deviceScreenSize;
+ (NSString *)deviceOrientation;

@end
