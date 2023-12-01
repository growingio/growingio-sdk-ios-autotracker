//
//  GrowingABTRequestAdapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/10/10.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/ABTesting/Request/GrowingABTRequestAdapter.h"

@implementation GrowingABTRequestAdapter

+ (instancetype)adapterWithRequest:(id<GrowingRequestProtocol>)request {
    GrowingABTRequestAdapter *adapter = [[self alloc] init];
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    [needAdaptReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    if (!self.parameters.count) {
        return needAdaptReq;
    }
    NSMutableArray *paramStrings = [NSMutableArray array];
    [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *paramString = [NSString stringWithFormat:@"%@=%@", key, obj];
        [paramStrings addObject:paramString];
    }];
    NSString *bodyString = [paramStrings componentsJoinedByString:@"&"];
    needAdaptReq.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 0;
}

@end
