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

#import "GrowingCustomField.h"
#import "GrowingDeviceInfo.h"
#import "GrowingEventManager.h"
#import "GrowingNetworkInterfaceManager.h"

@import CoreLocation;

@interface GrowingVisitEvent ()

@end

@implementation GrowingVisitEvent



- (instancetype)init {
    if (self = [super init]) {
        GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
//        _language = deviceInfo.language;
//        _deviceModel = deviceInfo.deviceModel;
//        _isPhone = deviceInfo.isPhone;
//        _deviceBrand = deviceInfo.deviceBrand;
//        _operatingSystem = deviceInfo.systemName;
//        _operatingSystemVersion = deviceInfo.systemVersion;
//        _appName = deviceInfo.displayName;
//        _bundleID = deviceInfo.bundleID;
//        _appShortVersion = deviceInfo.appShortVersion;
//        _urlScheme = deviceInfo.urlScheme;
//        _idfa = deviceInfo.idfa;
//        _idfv = deviceInfo.idfv;
//        _sdkVersion = [Growing getVersion];
//        _networkState = [[GrowingNetworkInterfaceManager sharedInstance] networkType];
//        CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
//        _screenW = [NSNumber numberWithInteger:screenSize.width];
//        _screenH = [NSNumber numberWithInteger:screenSize.height];
//
//        CLLocation *gpsLocation = [GrowingInstance sharedInstance].gpsLocation;
//        if (gpsLocation != nil) {
//            self.latitude = @(gpsLocation.coordinate.latitude);
//            self.longitude = @(gpsLocation.coordinate.longitude);
//        }
//
//        // 记录当前的vst事件
//        [GrowingEventManager shareInstance].visitEvent = self;
    }
    return self;
}

- (NSString *)eventTypeKey {
    return kEventTypeKeyVisit;
}

+ (void)onGpsLocationChanged:(CLLocation *_Nullable)location {
    // TODO: 工程中最后一次发的visit 事件，应该存在多线程问题
    GrowingVisitEvent *visitEvent = [GrowingEventManager shareInstance].visitEvent;

    if (location != nil && visitEvent.latitude == nil && visitEvent.longitude == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            visitEvent.latitude = @(location.coordinate.latitude);
//            visitEvent.longitude = @(location.coordinate.longitude);
            [GrowingVisitEvent sendWithEvent:visitEvent];
        });
    }
}

+ (void)send {
    GrowingVisitEvent *event = [[self alloc] init];
    [self sendWithEvent:event];
}

+ (void)sendWithEvent:(GrowingVisitEvent *)event {
    [[GrowingEventManager shareInstance] addEvent:event thisNode:nil triggerNode:nil withContext:nil];

    [[GrowingCustomField shareInstance] sendGIOFakePageEvent];
}

#pragma mark GrowingEventSendPolicyDelegate

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
//    dataDictM[@"language"] = self.language;
//    dataDictM[@"deviceModel"] = self.deviceModel;
//    dataDictM[@"deviceType"] = self.isPhone.boolValue ? @"PHONE" : @"PAD";
//    dataDictM[@"deviceBrand"] = self.deviceBrand;
//    dataDictM[@"operatingSystem"] = self.operatingSystem;
//    dataDictM[@"operatingSystemVersion"] = self.operatingSystemVersion;
//    dataDictM[@"appName"] = self.appName;
//    dataDictM[@"domain"] = self.bundleID;
//    dataDictM[@"appVersion"] = self.appShortVersion;
//    dataDictM[@"urlScheme"] = self.urlScheme;
//    dataDictM[@"idfa"] = self.idfa;
//    dataDictM[@"idfv"] = self.idfv;
//    dataDictM[@"sdkVersion"] = self.sdkVersion;
//    dataDictM[@"screenWidth"] = self.screenW;
//    dataDictM[@"screenHeight"] = self.screenH;
//    dataDictM[@"latitude"] = self.latitude;
//    dataDictM[@"longitude"] = self.longitude;
//    dataDictM[@"networkState"] = self.networkState;
    //TODO: extraSdk字段在后续应该添加
    return dataDictM;
}

@end
