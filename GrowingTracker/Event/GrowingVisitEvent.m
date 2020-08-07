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
#import "GrowingInstance.h"
#import "GrowingVersionManager.h"
#import "GrowingEventManager.h"
#import "GrowingCustomField.h"

@interface GrowingVisitEvent ()

@property (nonatomic, copy, readwrite) NSString * _Nonnull language;
@property (nonatomic, copy, readwrite) NSString * _Nonnull deviceModel;
@property (nonatomic, strong, readwrite) NSNumber * _Nonnull isPhone;
@property (nonatomic, copy, readwrite) NSString * _Nonnull deviceBrand;
@property (nonatomic, copy, readwrite) NSString * _Nonnull systemName;
@property (nonatomic, copy, readwrite) NSString * _Nonnull systemVersion;
@property (nonatomic, copy, readwrite) NSString * _Nonnull displayName;
@property (nonatomic, copy, readwrite) NSString * _Nonnull bundleID;
@property (nonatomic, copy, readwrite) NSString * _Nonnull appShortVersion;
@property (nonatomic, copy, readwrite) NSString * _Nonnull urlScheme;
/// Identifier For Advertising
@property (nonatomic, copy, readwrite) NSString * _Nonnull idfa;
/// Identifier For Vendor
@property (nonatomic, copy, readwrite) NSString * _Nonnull idfv;
@property (nonatomic, copy, readwrite) NSString * _Nonnull sdkVersion;
@property (nonatomic, copy, readwrite) NSString * _Nonnull versionInfo;

@property (nonatomic, strong, readwrite) NSNumber * _Nonnull screenW;
@property (nonatomic, strong, readwrite) NSNumber * _Nonnull screenH;

@property (nonatomic, strong, readwrite) NSNumber * _Nullable latitude;
@property (nonatomic, strong, readwrite) NSNumber * _Nullable longitude;

@end

@implementation GrowingVisitEvent

- (GrowingEventType)simpleEventType
{
    return GrowingEventTypeAppLifeCycleAppNewVisit;
}

- (instancetype)init {
    if (self = [super init]) {
        GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
        self.language  = deviceInfo.language;
        self.deviceModel = deviceInfo.deviceModel;
        self.isPhone = deviceInfo.isPhone;
        self.deviceBrand = deviceInfo.deviceBrand;
        self.systemName = deviceInfo.systemName;
        self.systemVersion = deviceInfo.systemVersion;
        self.displayName = deviceInfo.displayName;
        self.bundleID = deviceInfo.bundleID;
        self.appShortVersion = deviceInfo.appShortVersion;
        self.urlScheme  = deviceInfo.urlScheme;
        self.idfa = deviceInfo.idfa;
        self.idfv = deviceInfo.idfv;
        self.sdkVersion = [Growing getTrackVersion];
        self.versionInfo = [GrowingVersionManager versionInfo];
        
        CGSize screenSize = [GrowingDeviceInfo deviceScreenSize];
        self.screenW = [NSNumber numberWithInteger:screenSize.width];
        self.screenH = [NSNumber numberWithInteger:screenSize.height];
        
        CLLocation * gpsLocation = [GrowingInstance sharedInstance].gpsLocation;
        if (gpsLocation != nil) {
            self.latitude = @(gpsLocation.coordinate.latitude);
            self.longitude = @(gpsLocation.coordinate.longitude);
        }
        
        // 记录当前的vst事件
        [GrowingEventManager shareInstance].vstEvent = self;
    }
    return self;
}

- (NSString*)eventTypeKey {
    return kEventTypeKeyVisit;
}

+ (void)onGpsLocationChanged:(CLLocation * _Nullable)location {
    // TODO: 工程中最后一次发的visit 事件，应该存在多线程问题
    GrowingVisitEvent *vstEvent = [GrowingEventManager shareInstance].vstEvent;
    
    if (location != nil && vstEvent.latitude == nil && vstEvent.longitude == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            vstEvent.latitude = @(location.coordinate.latitude);
            vstEvent.longitude = @(location.coordinate.longitude);
            [GrowingVisitEvent sendWithEvent:vstEvent];
        });
    }
}

+ (void)send {
    GrowingVisitEvent *event = [[self alloc] init];
    [self sendWithEvent:event];
}

+ (void)sendWithEvent:(GrowingVisitEvent *)event {
    
    [[GrowingEventManager shareInstance] addEvent:event
                                         thisNode:nil
                                      triggerNode:nil
                                      withContext:nil];
    
    [[GrowingCustomField shareInstance] sendGIOFakePageEvent];
}

#pragma mark GrowingEventSendPolicyDelegate

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"l"]  = self.language;
    dataDictM[@"dm"] = self.deviceModel;
    dataDictM[@"ph"] = self.isPhone;
    dataDictM[@"db"] = self.deviceBrand;
    dataDictM[@"os"] = self.systemName;
    dataDictM[@"osv"]= self.systemVersion;
    dataDictM[@"sn"] = self.displayName;
    dataDictM[@"d"]  = self.bundleID;
    dataDictM[@"cv"] = self.appShortVersion;
    dataDictM[@"v"]  = self.urlScheme;
    dataDictM[@"ui"] = self.idfa;
    dataDictM[@"iv"] = self.idfv;
    dataDictM[@"av"] = self.sdkVersion;
    dataDictM[@"fv"] = self.versionInfo;
    dataDictM[@"sw"] = self.screenW;
    dataDictM[@"sh"] = self.screenH;
    dataDictM[@"lat"] = self.latitude;
    dataDictM[@"lng"] = self.longitude;
    return dataDictM;;
}

@end
