//
//  GrowingNetworkConfig.m
//  GrowingTracker
//
//  Created by GrowingIO on 16/9/21.
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
#import "GrowingNetworkConfig.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingConfigurationManager.h"
@implementation GrowingNetworkConfig

static GrowingNetworkConfig *sharedInstance;

static NSString * const kGrowingDataHost = @"https://www.growingio.com";
static NSString * const kGrowingTrackerHost = @"https://api.growingio.com";
static NSString * const kGrowingTagsHostFormat = @"https://tags.growingio.com";
static NSString * const kGrowingWsHostFormat =  @"wss://ws.growingio.com";

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)generateValidEndPoint:(NSString *)customHost {
    NSString *validEndPoint = [[customHost stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] copy];
    if (!validEndPoint.length) {
        GIOLogError(@"An empty string is set as tracker host.");
        return @"";
    }
    if (![validEndPoint hasPrefix:@"http://"] && ![validEndPoint hasPrefix:@"https://"]) {
        validEndPoint = [NSString stringWithFormat:@"https://%@", validEndPoint];
    }

    NSURL *url = [NSURL URLWithString:validEndPoint];
    if (url == nil) {
        GIOLogError(@"An Invalid URL is set as tracker host.");
        return @"";
    }
    return validEndPoint;
}

- (NSString *)buildEndPointWithTemplate:(NSString *)template
                              accountId:(NSString *)accountId
                                 andSTM:(unsigned long long)stm {
    return [NSString stringWithFormat:@"%@/%@",
                         (_customTrackerHost.length > 0 ? _customTrackerHost : [self growingApiHostEnd]),
                         [NSString stringWithFormat:template, accountId, stm]];
}

- (void)setCustomTrackerHost:(NSString *)customHost {
    NSString *validEndPoint = [GrowingNetworkConfig generateValidEndPoint:customHost];
    if (validEndPoint.length) {
        _customTrackerHost = validEndPoint;
    }
}

- (void)setCustomDataHost:(NSString *)customHost {
    NSString *validEndPoint = [GrowingNetworkConfig generateValidEndPoint:customHost];
    if (validEndPoint.length) {
        _customDataHost = validEndPoint;
    }
}

//- (void)setCustomWsHost:(NSString *)customHost {
//    // web socket 直接赋值, 不需要调用|generateValidEndPoint|
//    if (customHost && customHost.length > 0) {
//        _customWsHost = customHost;
//    }
//}

- (NSString *)growingApiHostEnd {
    return GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionServerHost;
}

- (NSString *)growingDataHostEnd {
    return _customDataHost.length > 0 ? _customDataHost : kGrowingDataHost;
}

- (NSString *)tagsHost {
    return [NSString stringWithFormat:kGrowingTagsHostFormat];
}


//
- (NSString *)wsEndPoint {
    if (_customWsHost.length > 0) {
        return [_customWsHost stringByAppendingString:@"/app/%@/circle/%@"];
    } else {
        return [kGrowingWsHostFormat stringByAppendingString:@"/app/%@/circle/%@"];
    }
}

- (NSString *)dataCheckEndPoint {
    if (_customWsHost.length > 0) {
        return [_customWsHost stringByAppendingString:kGrowingDataCheckAddress];
    } else {
        return [kGrowingWsHostFormat stringByAppendingString:kGrowingDataCheckAddress];
    }
}

@end
