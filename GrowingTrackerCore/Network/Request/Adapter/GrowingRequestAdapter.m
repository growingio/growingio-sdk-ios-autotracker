//
//  GrowingRequestAdapter.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/6/22.
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

#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingULTimeUtil.h"

#pragma mark GrowingRequestHeaderAdapter

@implementation GrowingRequestHeaderAdapter

+ (instancetype)adapterWithRequest:(id<GrowingRequestProtocol>)request {
    GrowingRequestHeaderAdapter *adapter = [[self alloc] init];
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    [needAdaptReq setValue:[NSString stringWithFormat:@"%lld", [GrowingULTimeUtil currentTimeMillis]]
        forHTTPHeaderField:@"X-Timestamp"];
    [needAdaptReq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 0;
}

@end

#pragma mark GrowingRequestMethodAdapter

@interface GrowingRequestMethodAdapter ()

@property (nonatomic, weak) id<GrowingRequestProtocol> request;

@end

@implementation GrowingRequestMethodAdapter

+ (instancetype)adapterWithRequest:(id<GrowingRequestProtocol>)request {
    GrowingRequestMethodAdapter *adapter = [[self alloc] init];
    adapter.request = request;
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    NSString *httpMethod = @"POST";

    switch (self.request.method) {
        case GrowingHTTPMethodPOST:
            httpMethod = @"POST";
            break;
        case GrowingHTTPMethodGET:
            httpMethod = @"GET";
            break;

        case GrowingHTTPMethodPUT:
            httpMethod = @"PUT";
            break;

        case GrowingHTTPMethodDELETE:
            httpMethod = @"DELETE";
            break;

        default:
            break;
    }

    needAdaptReq.HTTPMethod = httpMethod;
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 0;
}

@end
