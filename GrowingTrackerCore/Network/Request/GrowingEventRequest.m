//
//  GrowingEventRequest.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/6/17.
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

#import "GrowingTrackerCore/Network/Request/GrowingEventRequest.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingEventRequestAdapters.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Public/GrowingNetworkConfig.h"
#import "GrowingULTimeUtil.h"

@implementation GrowingEventRequest

@synthesize events;
@synthesize outsize;
@synthesize stm;

- (instancetype)initWithEvents:(NSData *)events {
    if (self = [super init]) {
        self.events = events;
        self.stm = [GrowingULTimeUtil currentTimeMillis];
    }
    return self;
}

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
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
    NSString *accountId = [GrowingConfigurationManager sharedInstance].trackConfiguration.projectId ?: @"";
    NSString *path = [NSString stringWithFormat:@"v3/projects/%@/collect", accountId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    GrowingRequestHeaderAdapter *basicHeaderAdapter = [GrowingRequestHeaderAdapter adapterWithRequest:self];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];

    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, nil];
    for (Class cls in GrowingEventRequestAdapters.sharedInstance.adapters) {
        [adapters addObject:[cls performSelector:@selector(adapterWithRequest:) withObject:self]];
    }
    return adapters;
}

- (NSDictionary *)query {
    NSString *stm = [NSString stringWithFormat:@"%llu", self.stm];
    return @{@"stm": stm};
}

- (NSTimeInterval)timeoutInSeconds {
    GrowingNetworkConfig *networkConfig = GrowingConfigurationManager.sharedInstance.trackConfiguration.networkConfig;
    if (networkConfig && networkConfig.requestTimeoutInSec > 0) {
        return networkConfig.requestTimeoutInSec;
    }
    return 60.0f;
}

@end
