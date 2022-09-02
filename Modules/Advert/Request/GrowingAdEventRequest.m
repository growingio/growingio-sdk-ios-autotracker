//
//  GrowingAdEventRequest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Advert/Request/GrowingAdEventRequest.h"
#import "Modules/Advert/Request/Adapter/GrowingAdEventRequestAdapter.h"
#import "Modules/Advert/Request/Adapter/GrowingAdRequestHeaderAdapter.h"

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"

@implementation GrowingAdEventRequest
@synthesize events;
@synthesize outsize;
@synthesize stm;

- (instancetype)init {
    if (self = [super init]) {
        self.stm = [GrowingTimeUtil currentTimeMillis];
    }
    return self;
}

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = @"https://t.growingio.com";
    NSString *absoluteURLString = [baseUrl growingHelper_absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSString *)path {
    NSString *accountId = GrowingConfigurationManager.sharedInstance.trackConfiguration.projectId ?: @"";
    NSString *path = [NSString stringWithFormat:@"app/%@/ios/ctvt", accountId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    // on 2.0 server, content-type must be application/octet-stream
    NSDictionary *headers = @{@"Content-Type" : @"application/octet-stream"};
    GrowingAdRequestHeaderAdapter *basicHeaderAdapter = [GrowingAdRequestHeaderAdapter adapterWithRequest:self header:headers];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    GrowingAdEventRequestAdapter *bodyAdapter = [GrowingAdEventRequestAdapter adapterWithRequest:self];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, bodyAdapter, nil];
    return adapters;
}

- (NSDictionary *)query {
    NSString *stm = [NSString stringWithFormat:@"%llu", self.stm];
    return @{@"stm" : stm};
}

@end
