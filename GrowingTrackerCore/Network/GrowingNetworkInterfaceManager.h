//
//  GrowingNetworkInterfaceManager.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GrowingNetworkReachabilityStatus) {
    GrowingNetworkReachabilityUndetermined = 0,
    GrowingNetworkReachabilityNotReachable,
    GrowingNetworkReachabilityReachableViaEthernet,
    GrowingNetworkReachabilityReachableViaWiFi,
    GrowingNetworkReachabilityReachableViaWWAN,
};

@interface GrowingNetworkInterfaceManager : NSObject

+ (instancetype)sharedInstance;
+ (void)startMonitor;
- (GrowingNetworkReachabilityStatus)currentStatus;
- (NSString *)networkType;

@end
