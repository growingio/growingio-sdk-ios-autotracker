//
//  GrowingNetworkInterfaceManager.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 4/23/15.
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

#import "GrowingTrackerCore/Network/GrowingNetworkInterfaceManager.h"
#import "GrowingTrackerCore/Thirdparty/Reachability/GrowingReachability.h"

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#endif

@interface GrowingNetworkInterfaceManager()

@property (nonatomic, strong) GrowingReachability *internetReachability;
@property (nonatomic, assign) BOOL isUnknown;
@property (nonatomic, assign, readwrite) BOOL WWANValid;
@property (nonatomic, assign, readwrite) BOOL WiFiValid;
@property (nonatomic, assign, readwrite) BOOL isReachable;

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
@property (nonatomic, strong) CTTelephonyNetworkInfo *teleInfo;
#endif

@end

@implementation GrowingNetworkInterfaceManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _internetReachability = [GrowingReachability reachabilityForInternetConnection];
        [_internetReachability startNotifier];
        _isUnknown = YES;

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
        _teleInfo = [[CTTelephonyNetworkInfo alloc] init];
#endif
    }
    return self;
}

- (void)updateInterfaceInfo {
    GrowingNetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    BOOL connectionRequired = [self.internetReachability connectionRequired];
    self.isUnknown = (netStatus == GrowingUnknown);
    self.WiFiValid = (netStatus == GrowingReachableViaWiFi && !connectionRequired);
    self.WWANValid = (netStatus == GrowingReachableViaWWAN && !connectionRequired);
    self.isReachable = (self.WiFiValid || self.WWANValid);
}

- (NSString *)networkType {
    [self updateInterfaceInfo];
    
    if (self.isUnknown) {
        return @"UNKNOWN";
    } else if (self.WiFiValid) {
        return @"WIFI";
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    } else if (self.WWANValid) {
        NSArray *typeStrings2G = @[
            CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyGPRS,
            CTRadioAccessTechnologyCDMA1x
        ];

        NSArray *typeStrings3G = @[
            CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB,
            CTRadioAccessTechnologyeHRPD
        ];

        NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];

        NSString *accessString = CTRadioAccessTechnologyLTE;  // default 4G
        if (@available(iOS 12.0, *)) {
            if ([self.teleInfo respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
                NSDictionary *radioDic = self.teleInfo.serviceCurrentRadioAccessTechnology;
                if (radioDic.count) {
                    accessString = radioDic[radioDic.allKeys.firstObject];
                }
            }
        } else {
            accessString = self.teleInfo.currentRadioAccessTechnology;
        }

        if ([typeStrings4G containsObject:accessString]) {
            return @"4G";
        } else if ([typeStrings3G containsObject:accessString]) {
            return @"3G";
        } else if ([typeStrings2G containsObject:accessString]) {
            return @"2G";
#if defined(__IPHONE_14_1) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_1)
        } else if (@available(iOS 14.1, *)) {
            NSArray *typeStrings5G = @[
                CTRadioAccessTechnologyNR,
                CTRadioAccessTechnologyNRNSA
            ];
            if ([typeStrings5G containsObject:accessString]) {
                return @"5G";
            }
#endif
        }
#endif
    }
    
    return @"UNKNOWN";
}

@end
