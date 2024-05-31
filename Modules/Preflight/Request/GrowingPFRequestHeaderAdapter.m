//
//  GrowingPFRequestHeaderAdapter.m
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

#import "Modules/Preflight/Request/GrowingPFRequestHeaderAdapter.h"

@interface GrowingPFRequestHeaderAdapter ()

@property (nonatomic, weak) id<GrowingRequestProtocol> request;

@end

@implementation GrowingPFRequestHeaderAdapter

+ (instancetype)adapterWithRequest:(id<GrowingRequestProtocol>)request {
    GrowingPFRequestHeaderAdapter *adapter = [[self alloc] init];
    adapter.request = request;
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    [needAdaptReq setValue:@"POST" forHTTPHeaderField:@"Access-Control-Request-Method"];
    [needAdaptReq setValue:@"Accept, Content-Type, X-Timestamp, X-Crypt-Codec, X-Compress-Codec"
        forHTTPHeaderField:@"Access-Control-Request-Headers"];
    NSURL *url = [self.request absoluteURL];
    NSString *origin = [NSString stringWithFormat:@"%@://%@", url.scheme, url.host];
    [needAdaptReq setValue:origin forHTTPHeaderField:@"Origin"];
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 0;
}

@end
