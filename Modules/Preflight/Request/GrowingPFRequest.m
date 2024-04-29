//
//  GrowingPFRequest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/4/24.
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

#import "Modules/Preflight/Request/GrowingPFRequest.h"
#import "Modules/Preflight/Request/GrowingPFRequestHeaderAdapter.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingULTimeUtil.h"

@implementation GrowingPFRequest

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodOPTIONS;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = GrowingConfigurationManager.sharedInstance.trackConfiguration.dataCollectionServerHost;
    if (!baseUrl.length) {
        return nil;
    }

    NSString *absoluteURLString = [baseUrl growingHelper_absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSString *)path {
    NSString *accountId = [GrowingConfigurationManager sharedInstance].trackConfiguration.accountId;
    NSString *path = [NSString stringWithFormat:@"v3/projects/%@/collect", accountId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    GrowingPFRequestHeaderAdapter *basicHeaderAdapter =
        [GrowingPFRequestHeaderAdapter adapterWithRequest:self];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    return @[basicHeaderAdapter, methodAdapter];
}

- (NSDictionary *)query {
    NSString *stm = [NSString stringWithFormat:@"%llu", [GrowingULTimeUtil currentTimeMillis]];
    return @{@"stm": stm};
}

- (NSTimeInterval)timeoutInSeconds {
    return 30.0f;
}

@end
