//
// GrowingDeepLinkHandler.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/30.
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


#import "GrowingDeepLinkHandler.h"
#import "NSURL+GrowingHelper.h"
#import "GrowingNetworkConfig.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingASLLoggerFormat.h"
#import "GrowingWebCircle.h"

@implementation GrowingDeepLinkHandler

+ (BOOL)isV1Url:(NSURL *)url {
    return ([url.host isEqualToString:@"datayi.cn"] || [url.host hasSuffix:@".datayi.cn"]);
}

+ (BOOL)isShortChainUlink:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    BOOL isShortChainUlink = ([url.host isEqualToString:@"gio.ren"] || [self isV1Url:url]) && [url.path componentsSeparatedByString:@"/"].count == 2;
    return isShortChainUlink;
}

+ (BOOL)isLongChainDeeplink:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    NSDictionary *params = url.growingHelper_queryDict;
    
    if (params[@"link_id"]) {
        return YES;
    } else {
        return NO;
    }
}

static NSString *kGrowingDeeplinkKey_serviceType = @"serviceType";
static NSString *kGrowingDeeplinkKey_wsUrl = @"wsUrl";


+ (BOOL)handlerUrl:(NSURL *)url {

    NSDictionary *params = url.growingHelper_queryDict;
    //  open console.app 中的log
    NSString *openConsoleLog = params[@"openConsoleLog"];
    if ([openConsoleLog isEqualToString:@"Yes"] && ![GrowingLog.allLoggers containsObject:[GrowingASLLogger sharedInstance]]) {
        [GrowingLog addLogger:[GrowingASLLogger sharedInstance] withLevel:GrowingLogLevelAll];
        [GrowingASLLogger sharedInstance].logFormatter = [GrowingASLLoggerFormat new];
        return YES;
    }
    
    //  TODO:GrowingPushKit 扫描弹窗
//    if ([params.allKeys containsObject:@"gtouchType"]) {
//        return [[[GrowingMediator sharedInstance] performClass:@"GrowingTouchHandleURL" action:@"growingTouchHandleUrl:" params:@{@"0":params}] boolValue];
//    }
    
    NSString *serviceType = params[kGrowingDeeplinkKey_serviceType];
    NSString *wsurl = params[kGrowingDeeplinkKey_wsUrl];
    if (!serviceType.length && !wsurl) {
        return NO;
    }
    [GrowingWebCircle runWithCircle:[NSURL URLWithString:wsurl]
                                   readyBlock:^{}
                                  finishBlock:^{}];

    
    return YES;
}


@end
