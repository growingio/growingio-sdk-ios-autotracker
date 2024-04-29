//
//  GrowingPFEventRequestAdapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2024/4/29.
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

#import "Modules/Preflight/Request/GrowingPFEventRequestAdapter.h"
#import "Modules/Preflight/GrowingNetworkPreflight+Private.h"

@implementation GrowingPFEventRequestAdapter

+ (instancetype)adapterWithRequest:(id<GrowingRequestProtocol>)request {
    GrowingPFEventRequestAdapter *adapter = [[self alloc] init];
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    NSString *serverHost = [GrowingNetworkPreflight dataCollectionServerHost];
    NSURL *url = [NSURL URLWithString:serverHost];
    NSURLComponents *components1 = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSURLComponents *components2 = [NSURLComponents componentsWithURL:needAdaptReq.URL resolvingAgainstBaseURL:NO];
    components2.host = components1.host;
    needAdaptReq.URL = components2.URL;
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 0;
}

@end
