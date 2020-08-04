//
//  KDNetworkInterfaceManager.m
//  Netpas
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


#import "GrowingNetworkInterfaceManager.h"
#import "GrowingReachability.h"
#import "GrowingInstance.h"
#import "GrowingGlobal.h"

@interface GrowingNetworkInterfaceManager()
@property (nonatomic, retain) GrowingReachability * internetReachability;
@property (nonatomic, assign) BOOL isUnknown;
@end

@implementation GrowingNetworkInterfaceManager {
}

+ (instancetype)sharedInstance {
    if ([GrowingInstance sharedInstance].projectID.length == 0 ||
        SDKDoNotTrack()) {
        return nil;
    }
    
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
        self.internetReachability = [GrowingReachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        self.isUnknown = YES;
    }
    return self;
}

- (void)updateInterfaceInfo {
#ifdef GROWINGIO_SIMULATING_3G
    _WiFiValid = NO;
    _WWANValid = YES;
    _isUnknown = NO;
#else // #ifdef GROWINGIO_SIMULATING_3G
    GrowingNetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    BOOL connectionRequired = [self.internetReachability connectionRequired];
    _isUnknown = (netStatus == GrowingUnknown);
    _WiFiValid = (netStatus == GrowingReachableViaWiFi && !connectionRequired);
    _WWANValid = (netStatus == GrowingReachableViaWWAN && !connectionRequired);
    _isReachable = (_WiFiValid || _WWANValid);
#endif // #ifdef GROWINGIO_SIMULATING_3G
}

- (NSString *)networkType {
    
    [self updateInterfaceInfo];
    
    NSString *netType = @"UNKNOWN";
    if (self.isUnknown) {
        netType = @"UNKNOWN";
    } else if (self.WiFiValid) {
        netType = @"WIFI";
    } else if (self.WWANValid) {
        netType = @"CELL";
    } else {
        netType = @"NONE";
    }
    return netType;
}

@end
