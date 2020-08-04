//
//  GrowingLoginRequest.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/6/29.
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


#import "GrowingLoginRequest.h"
#import "GrowingNetworkConfig.h"
#import "NSString+GrowingHelper.h"
#import "GrowingRequestAdapter.h"

@interface GrowingLoginRequest ()

@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSDictionary *header;

@end

@implementation GrowingLoginRequest

+ (instancetype)loginRequestWithHeader:(NSDictionary *)header Parameter:(NSDictionary *)parameter {
    GrowingLoginRequest *loginRequest = [[GrowingLoginRequest alloc] init];
    loginRequest.parameter = parameter;
    loginRequest.header = header;
    return loginRequest;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = [GrowingNetworkConfig sharedInstance].growingDataHostEnd;
    if (!baseUrl.length) {
        return nil;
    }
    
    NSString *absoluteURLString = [baseUrl absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSDictionary *)query {
    return nil;
}

- (NSString *)path {
    return @"oauth2/token";
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    
    GrowingRequestHeaderAdapter *basicHeaderAdapter = [GrowingRequestHeaderAdapter headerAdapterWithHeader:self.header];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter methodAdpterWithMethod:self.method];
    GrowingRequestJsonBodyAdapter *jsonBodyAdapter = [GrowingRequestJsonBodyAdapter jsonBodyWithParameter:self.parameter];
    
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, jsonBodyAdapter, nil];
    
    return adapters;
}

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
}

@end

#pragma mark GrowingWebSocketRequest

@implementation GrowingWebSocketRequest

+ (instancetype)webSocketRequestWithParameter:(NSDictionary *)parameter {
    GrowingWebSocketRequest *wsRequest = [[GrowingWebSocketRequest alloc] init];
    wsRequest.parameter = parameter;
    return wsRequest;
}

- (NSString *)path {
    return @"mobile/link";
}

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
}

@end
