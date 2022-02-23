//
// GrowingBaseEvent.m
// GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
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

#import "GrowingDeviceInfo.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingRealTracker.h"
#import "GrowingSession.h"
#import "GrowingTimeUtil.h"
#import "GrowingNetworkInterfaceManager.h"
#import "GrowingFieldsIgnore.h"

@implementation GrowingBaseEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    self = [super init];
    if (self) {
        _deviceId = builder.deviceId;
        _userId = builder.userId;
        _sessionId = builder.sessionId;
        _eventType = builder.eventType;
        _timestamp = builder.timestamp;
        _domain = builder.domain;
        _urlScheme = builder.urlScheme;
        _appState = builder.appState;
        _globalSequenceId = builder.globalSequenceId;
        _eventSequenceId = builder.eventSequenceId;
        _platform = builder.platform;
        _platformVersion = builder.platformVersion;
        _extraParams = builder.extraParams;
        _networkState = builder.networkState;
        _screenHeight = builder.screenHeight;
        _screenWidth = builder.screenWidth;
        _deviceBrand = builder.deviceBrand;
        _deviceModel = builder.deviceModel;
        _deviceType = builder.deviceType;
        _appName = builder.appName;
        _appVersion = builder.appVersion;
        _language = builder.language;
        _latitude = builder.latitude;
        _longitude = builder.longitude;
        _sdkVersion = builder.sdkVersion;
        _userKey = builder.userKey;
    }
    return self;
}

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyMobileData;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    //如果有额外参数添加
    if (self.extraParams.count > 0) {
        [dataDict addEntriesFromDictionary:self.extraParams];
    }
    // NSMutableDictionary class dataDict[key] = nil
    // Passing nil will cause any object corresponding to aKey to be removed from the dictionary.
    // actually use method (setObject:forKeyedSubscript:)
    dataDict[@"sessionId"] = self.sessionId;
    dataDict[@"timestamp"] = @(self.timestamp);
    dataDict[@"eventType"] = self.eventType;
    dataDict[@"domain"] = self.domain;
    dataDict[@"userId"] = self.userId.length > 0 ? self.userId : nil;
    dataDict[@"deviceId"] = self.deviceId;
    dataDict[@"platform"] = self.platform;
    dataDict[@"platformVersion"] = self.platformVersion;
    dataDict[@"globalSequenceId"] = @(self.globalSequenceId);
    dataDict[@"eventSequenceId"] = @(self.eventSequenceId);
    dataDict[@"appState"] = (self.appState == GrowingAppStateForeground) ? @"FOREGROUND" : @"BACKGROUND";
    dataDict[@"urlScheme"] = self.urlScheme;
    dataDict[@"networkState"] = self.networkState ? self.networkState : nil;
    dataDict[@"screenWidth"] = self.screenWidth > 0 ? @(self.screenWidth) : nil;
    dataDict[@"screenHeight"] = self.screenHeight > 0 ? @(self.screenHeight) : nil;
    dataDict[@"deviceBrand"] = self.deviceBrand ? self.deviceBrand : nil;
    dataDict[@"deviceModel"] = self.deviceModel ? self.deviceModel : nil;
    dataDict[@"deviceType"] = self.deviceType ? self.deviceType : nil;
    dataDict[@"appName"] = self.appName;
    dataDict[@"appVersion"] = self.appVersion;
    dataDict[@"language"] = self.language;
    dataDict[@"latitude"] = ABS(self.latitude) > 0 ? @(self.latitude) : nil;
    dataDict[@"longitude"] = ABS(self.longitude) > 0 ? @(self.longitude) : nil;
    dataDict[@"sdkVersion"] = self.sdkVersion;
    dataDict[@"userKey"] = self.userKey.length > 0 ? self.userKey : nil;
    return [dataDict copy];
}

+ (GrowingBaseBuilder *_Nonnull)builder {
    return [[GrowingBaseBuilder alloc] init];
}

@end

@implementation GrowingBaseBuilder

//赋值属性，eg:deviceId,userId,sessionId,globalSequenceId,eventSequenceId
- (void)readPropertyInTrackThread {
    _timestamp = _timestamp > 0 ? _timestamp : [GrowingTimeUtil currentTimeMillis];

    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _domain = _domain.length > 0 ? _domain : deviceInfo.bundleID;
    _appState = deviceInfo.appState;
    _deviceId = deviceInfo.deviceIDString ?: @"";
    _urlScheme = deviceInfo.urlScheme;
    _platform = deviceInfo.platform;
    _platformVersion = deviceInfo.platformVersion;

    GrowingEventSequenceObject *sequence =
        [[GrowingPersistenceDataProvider sharedInstance] getAndIncrement:self.eventType];
    _globalSequenceId = sequence.globalId;
    _eventSequenceId = sequence.eventTypeId;
    GrowingSession *session = [GrowingSession currentSession];
    _userId = session.loginUserId;
    _sessionId = session.sessionId;
    _latitude = session.latitude;
    _longitude = session.longitude;
    _userKey = session.loginUserKey;

    CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
    _screenWidth = [GrowingFieldsIgnore isIgnoreFields:@"screenWidth"] ? 0 : screenSize.width;
    _screenHeight = [GrowingFieldsIgnore isIgnoreFields:@"screenHeight"] ? 0 : screenSize.height;
    _networkState = [GrowingFieldsIgnore isIgnoreFields:@"networkState"] ? nil : [[GrowingNetworkInterfaceManager sharedInstance] networkType];
    _sdkVersion = GrowingTrackerVersionName;
    _deviceBrand = [GrowingFieldsIgnore isIgnoreFields:@"deviceBrand"] ? nil : deviceInfo.deviceBrand;
    _deviceModel = [GrowingFieldsIgnore isIgnoreFields:@"deviceModel"] ? nil : deviceInfo.deviceModel;
    _deviceType = [GrowingFieldsIgnore isIgnoreFields:@"deviceType"] ? nil : deviceInfo.deviceType;
    _appName = deviceInfo.displayName;
    _appVersion = deviceInfo.appVersion;
    _language = deviceInfo.language;
}

- (GrowingBaseBuilder * (^)(NSString *value))setDeviceId {
    return ^(NSString *value) {
        self->_deviceId = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setUserId {
    return ^(NSString *value) {
        self->_userId = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setSessionId {
    return ^(NSString *value) {
        self->_sessionId = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(long long value))setTimestamp {
    return ^(long long value) {
        self->_timestamp = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setDomain {
    return ^(NSString *value) {
        self->_domain = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setUrlScheme {
    return ^(NSString *value) {
        self->_urlScheme = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(int value))setAppState {
    return ^(int value) {
        self->_appState = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(long long value))setGlobalSequenceId {
    return ^(long long value) {
        self->_globalSequenceId = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(long long value))setEventSequenceId {
    return ^(long long value) {
        self->_eventSequenceId = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setPlatform {
    return ^(NSString *value) {
        self->_platform = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setPlatformVersion {
    return ^(NSString *value) {
        self->_platformVersion = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSDictionary *value))setExtraParams {
    return ^(NSDictionary *value) {
        self->_extraParams = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setEventType {
    return ^(NSString *value) {
        self->_eventType = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setNetworkState {
    return ^(NSString *value) {
        self->_networkState = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSInteger value))setScreenHeight {
    return ^(NSInteger value) {
        self->_screenHeight = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSInteger value))setScreenWidth {
    return ^(NSInteger value) {
        self->_screenWidth = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setDeviceBrand {
    return ^(NSString *value) {
        self->_deviceBrand = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setDeviceModel {
    return ^(NSString *value) {
        self->_deviceModel = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setDeviceType {
    return ^(NSString *value) {
        self->_deviceType = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setAppName {
    return ^(NSString *value) {
        self->_appName = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setAppVersion {
    return ^(NSString *value) {
        self->_appVersion = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setLanguage {
    return ^(NSString *value) {
        self->_language = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(double value))setLatitude {
    return ^(double value) {
        self->_latitude = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(double value))setLongitude {
    return ^(double value) {
        self->_longitude = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setSdkVersion {
    return ^(NSString *value) {
        self->_sdkVersion = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setUserKey {
    return ^(NSString *value) {
        self->_userKey = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    @throw [NSException
        exceptionWithName:NSInternalInconsistencyException
                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                 userInfo:nil];
}

@end
