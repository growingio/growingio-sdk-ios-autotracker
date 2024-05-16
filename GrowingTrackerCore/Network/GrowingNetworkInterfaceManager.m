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
#import "GrowingTargetConditionals.h"
#import "GrowingTrackerCore/Network/GrowingNetworkPathMonitor.h"
#import "GrowingTrackerCore/Thirdparty/Reachability/GrowingReachability.h"

#if Growing_OS_PURE_IOS
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#endif

@interface GrowingNetworkInterfaceManager ()

@property (nonatomic, strong) GrowingReachability *internetReachability;
@property (nonatomic, strong) GrowingNetworkPathMonitor *monitor;
@property (nonatomic, strong) dispatch_queue_t monitorQueue;

#if Growing_OS_PURE_IOS
@property (nonatomic, strong) CTTelephonyNetworkInfo *teleInfo;
#endif

@end

@implementation GrowingNetworkInterfaceManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _monitorQueue = dispatch_queue_create("com.growingio.network.monitorQueue", DISPATCH_QUEUE_SERIAL);

#if Growing_OS_PURE_IOS
        _teleInfo = [[CTTelephonyNetworkInfo alloc] init];
#endif
        [self monitorInitialize];
    }
    return self;
}

+ (void)startMonitor {
    [[self sharedInstance] startMonitor];
}

- (NSString *)networkType {
    GrowingNetworkReachabilityStatus reachabilityStatus = [self currentStatus];
    if (reachabilityStatus == GrowingNetworkReachabilityReachableViaWiFi) {
        return @"WIFI";
    } else if (reachabilityStatus == GrowingNetworkReachabilityReachableViaWWAN) {
#if Growing_OS_WATCH
        // https://www.apple.com/watch/cellular/
        return @"4G";
#elif Growing_OS_PURE_IOS
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            accessString = self.teleInfo.currentRadioAccessTechnology;
#pragma clang diagnostic pop
        }

        if ([typeStrings4G containsObject:accessString]) {
            return @"4G";
#if defined(__IPHONE_14_1) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_1)
        } else if (@available(iOS 14.1, *)) {
            NSArray *typeStrings5G = @[CTRadioAccessTechnologyNR, CTRadioAccessTechnologyNRNSA];
            if ([typeStrings5G containsObject:accessString]) {
                return @"5G";
            }
#endif
        }
#endif
    } else if (reachabilityStatus == GrowingNetworkReachabilityReachableViaEthernet) {
        return @"WIFI";  // @"Ethernet"
    }

    // GrowingNetworkReachabilityUndetermined or GrowingNetworkReachabilityNotReachable
    return @"UNKNOWN";
}

- (GrowingNetworkReachabilityStatus)currentStatus {
    GrowingNetworkReachabilityStatus reachabilityStatus = GrowingNetworkReachabilityUndetermined;
    if (@available(iOS 12.0, macCatalyst 13.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)) {
        reachabilityStatus = self.monitor.reachabilityStatus;
    } else {
        reachabilityStatus = self.internetReachability.reachabilityStatus;
    }

    return reachabilityStatus;
}

- (void)monitorInitialize {
    if (@available(iOS 12.0, macCatalyst 13.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)) {
        _monitor = [GrowingNetworkPathMonitor monitorWithQueue:_monitorQueue];
    } else {
        _internetReachability = [GrowingReachability reachabilityForInternetConnection];
    }
}

- (void)startMonitor {
    if (@available(iOS 12.0, macCatalyst 13.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)) {
        [_monitor startMonitor];
    } else {
        [_internetReachability startNotifier];
    }
}

@end
