//
//  GrowingDeeplinkRequest.m
//  GrowingTracker
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


#import "GrowingDeeplinkRequest.h"
#import "GrowingInstance.h"
#import "GrowingDeviceInfo.h"
#import "NSString+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "GrowingEventRequestAdapter.h"
#import "GrowingRequestAdapter.h"

@interface GrowingDeeplinkRequest ()

@property (nonatomic, copy) NSString *hashId;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, assign) BOOL manual;
@property (nonatomic, copy) NSString *linkQuery;

@end

@implementation GrowingDeeplinkRequest

- (instancetype)initWithHashId:(NSString *)hashId
                         query:(NSString *)query
                     userAgent:(NSString *)userAgent
                        manual:(BOOL)manual {
    
    if (self = [super init]) {
        self.hashId = hashId;
        self.linkQuery = query;
        self.userAgent = userAgent;
        self.manual = manual;
    }
    return self;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = @"https://t.growingio.com";
    
    NSString *absoluteURLString = [baseUrl absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSString *)path {
    NSString *info = self.manual ? @"inapp" : @"defer";
    NSString *projectId = [GrowingInstance sharedInstance].projectID;
    NSString *bundleId = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    NSString *path = [NSString stringWithFormat:@"app/at6/%@/ios/%@/%@/%@", info, projectId, bundleId, self.hashId];
    return path;
}

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodGET;
}

- (NSTimeInterval)timeoutInSeconds {
    return 15.0;
}

- (NSDictionary *)query {
    return self.linkQuery.growingHelper_queryObject;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    
    GrowingDeeplinkRequestHeaderAdapter *deeplinkHeaderAdapter = [GrowingDeeplinkRequestHeaderAdapter deeplinkHeaderAdapterWithUserAgent:self.userAgent];
    GrowingRequestHeaderAdapter *basicHeaderAdapter = [GrowingRequestHeaderAdapter headerAdapterWithHeader:nil];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter methodAdpterWithMethod:self.method];
    
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:deeplinkHeaderAdapter, basicHeaderAdapter, methodAdapter, nil];
    
    return adapters;
}

@end

@interface GrowingDeeplinkRequestHeaderAdapter ()

@property (nonatomic, copy) NSString *userAgent;

@end

@implementation GrowingDeeplinkRequestHeaderAdapter

+ (instancetype)deeplinkHeaderAdapterWithUserAgent:(NSString *)userAgent {
    GrowingDeeplinkRequestHeaderAdapter *adapter = [[GrowingDeeplinkRequestHeaderAdapter alloc] init];
    adapter.userAgent = userAgent;
    return adapter;
}

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
    
    NSMutableURLRequest *needAdaptReq = request;
    if (self.userAgent.length) {
        [needAdaptReq setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    }
    return needAdaptReq;
}

@end
