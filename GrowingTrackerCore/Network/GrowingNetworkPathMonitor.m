//
//  GrowingNetworkPathMonitor.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/2/5.
//  Copyright (C) 2024 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Network/GrowingNetworkPathMonitor.h"
#import <Network/Network.h>
#import "GrowingTargetConditionals.h"

@interface GrowingNetworkPathMonitor ()

@property (nonatomic, assign, readwrite) GrowingNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, strong) nw_path_monitor_t monitor;

@end

@implementation GrowingNetworkPathMonitor

- (instancetype)initWithQueue:(dispatch_queue_t)monitorQueue {
    if (self = [super init]) {
        _reachabilityStatus = GrowingNetworkReachabilityUndetermined;
#if Growing_OS_VISION
        if (1) {  // if (@available(visionOS 1.0, *)) {
#else
        if (@available(iOS 12.0, macCatalyst 13.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)) {
#endif
            _monitor = nw_path_monitor_create();
            nw_path_monitor_set_queue(_monitor, monitorQueue);

            __weak typeof(self) weakSelf = self;
            nw_path_monitor_set_update_handler(_monitor, ^(nw_path_t _Nonnull path) {
                if (weakSelf == nil) {
                    return;
                }
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf reachabilityPathChanged:path];
            });
        }
    }

    return self;
}

+ (instancetype)monitorWithQueue:(dispatch_queue_t)queue {
    return [[self alloc] initWithQueue:queue];
}

- (void)dealloc {
    [self stopMonitor];
}

- (void)startMonitor {
#if Growing_OS_VISION
    if (1) {  // if (@available(visionOS 1.0, *)) {
#else
    if (@available(iOS 12.0, macCatalyst 13.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)) {
#endif
        nw_path_monitor_start(self.monitor);
    }
}

- (void)stopMonitor {
#if Growing_OS_VISION
    if (1) {  // if (@available(visionOS 1.0, *)) {
#else
    if (@available(iOS 12.0, macCatalyst 13.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)) {
#endif
        nw_path_monitor_cancel(self.monitor);
    }
}

#if Growing_OS_VISION
- (GrowingNetworkReachabilityStatus)reachabilityStatusForPath:(nw_path_t)path {
#else
- (GrowingNetworkReachabilityStatus)reachabilityStatusForPath:(nw_path_t)path
    API_AVAILABLE(ios(12.0), tvos(12.0), macos(10.14), watchos(6.0)) {
    nw_path_status_t status = nw_path_get_status(path);
    if (status != nw_path_status_satisfied) {
        return GrowingNetworkReachabilityNotReachable;
    }

    BOOL isWiFi = nw_path_uses_interface_type(path, nw_interface_type_wifi);
    BOOL isCellular = nw_path_uses_interface_type(path, nw_interface_type_cellular);
    BOOL isEthernet = nw_path_uses_interface_type(path, nw_interface_type_wired);
    if (isEthernet) {
        return GrowingNetworkReachabilityReachableViaEthernet;
    } else if (isWiFi) {
        return GrowingNetworkReachabilityReachableViaWiFi;
    } else if (isCellular) {
        return GrowingNetworkReachabilityReachableViaWWAN;
    }

    return GrowingNetworkReachabilityUndetermined;
}
#endif

#if Growing_OS_VISION
    -(void)reachabilityPathChanged : (nw_path_t)path {
#else
- (void)reachabilityPathChanged:(nw_path_t)path API_AVAILABLE(ios(12.0), tvos(12.0), macos(10.14), watchos(6.0)) {
    GrowingNetworkReachabilityStatus status = [self reachabilityStatusForPath:path];
    if (self.reachabilityStatus != status) {
        self.reachabilityStatus = status;
    }
}
#endif

        @end
