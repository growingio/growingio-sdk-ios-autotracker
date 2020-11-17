//
//  GrowingVisitEvent.m
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

#import "GrowingVisitEvent.h"
#import "GrowingDeviceInfo.h"
#import "GrowingEventManager.h"
#import "GrowingNetworkInterfaceManager.h"
#import "GrowingRealTracker.h"

@import CoreLocation;

@interface GrowingVisitEvent ()

@end

@implementation GrowingVisitEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingVisitBuidler *subBuilder = (GrowingVisitBuidler*)builder;
        _networkState = subBuilder.networkState;
        _screenWidth = subBuilder.screenWidth;
        _screenHeight = subBuilder.screenHeight;
        _deviceBrand = subBuilder.deviceBrand;
        _deviceModel = subBuilder.deviceModel;
        _deviceType = subBuilder.deviceType;
        _appName = subBuilder.appName;
        _appVersion = subBuilder.appVersion;
        _language = subBuilder.language;
        _latitude = subBuilder.latitude;
        _longitude = subBuilder.longitude;
        _idfa = subBuilder.idfa;
        _idfv = subBuilder.idfv;
        _sdkVersion = subBuilder.sdkVersion;
        _extraSdk = subBuilder.extraSdk;
    }
    return self;
}

+ (GrowingVisitBuidler *_Nonnull)builder {
    return [[GrowingVisitBuidler alloc] init];
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"networkState"] = self.networkState;
    dataDictM[@"screenWidth"] = @(self.screenWidth);
    dataDictM[@"screenHeight"] = @(self.screenHeight);
    dataDictM[@"deviceBrand"] = self.deviceBrand;
    dataDictM[@"deviceModel"] = self.deviceModel;
    dataDictM[@"deviceType"] = self.deviceType;
    dataDictM[@"appName"] = self.appName;
    dataDictM[@"appVersion"] = self.appVersion;
    dataDictM[@"language"] = self.language;
    dataDictM[@"latitude"] = ABS(self.latitude) > 0 ? @(self.latitude) : nil;
    dataDictM[@"longitude"] = ABS(self.longitude) > 0 ? @(self.longitude) : nil;
    dataDictM[@"idfa"] = self.idfa;
    dataDictM[@"idfv"] = self.idfv;
    dataDictM[@"sdkVersion"] = self.sdkVersion;
    return dataDictM;
}

@end


@implementation GrowingVisitBuidler

- (void)readPropertyInMainThread {
    [super readPropertyInMainThread];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
    _screenWidth = screenSize.width;
    _screenHeight = screenSize.height;
    _networkState = [[GrowingNetworkInterfaceManager sharedInstance] networkType];
    _sdkVersion = GrowingTrackerVersionName;
    _deviceBrand = deviceInfo.deviceBrand;
    _deviceModel = deviceInfo.deviceModel;
    _deviceType = deviceInfo.deviceType;
    _appName = deviceInfo.displayName;
    _appVersion = deviceInfo.appVersion;
    _language = deviceInfo.language;
    
    _idfa = deviceInfo.idfa;
    _idfv = deviceInfo.idfv;
    
}

- (GrowingVisitBuidler *(^)(NSString *value))setNetworkState {
    return ^(NSString *value) {
        self->_networkState = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setAppChannel {
    return ^(NSString *value) {
        self->_appChannel = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSInteger value))setScreenHeight {
    return ^(NSInteger value) {
        self->_screenHeight = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSInteger value))setScreenWidth {
    return ^(NSInteger value) {
        self->_screenWidth = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setDeviceBrand {
    return ^(NSString *value) {
        self->_deviceBrand = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setDeviceModel {
    return ^(NSString *value) {
        self->_deviceModel = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setDeviceType {
    return ^(NSString *value) {
        self->_deviceType = value;
        return self;
    };
}

- (GrowingVisitBuidler *(^)(NSString *value))setAppName {
    return ^(NSString *value) {
        self->_appName = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setAppVersion {
    return ^(NSString *value) {
        self->_appVersion = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setLanguage {
    return ^(NSString *value) {
        self->_language = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(double value))setLatitude {
    return ^(double value) {
        self->_latitude = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(double value))setLongitude {
    return ^(double value) {
        self->_longitude = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setIdfa {
    return ^(NSString *value) {
        self->_idfa = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setIdfv {
    return ^(NSString *value) {
        self->_idfv = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSString *value))setSdkVersion {
    return ^(NSString *value) {
        self->_sdkVersion = value;
        return self;
    };
}
- (GrowingVisitBuidler *(^)(NSDictionary<NSString *,NSString*> *value))setExtraSdk {
    return ^(NSDictionary<NSString *,NSString*> *value) {
        self->_extraSdk = value;
        return self;
    };
}
//_eventType成员变量并没有值
- (NSString *)eventType {
    return GrowingEventTypeVisit;
}

- (GrowingBaseEvent *)build {
    return [[GrowingVisitEvent alloc] initWithBuilder:self];
}


@end
