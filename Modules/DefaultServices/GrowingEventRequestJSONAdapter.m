//
//  GrowingEventRequestJSONAdapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/4/26.
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

#import "Modules/DefaultServices/GrowingEventRequestJSONAdapter.h"

@implementation GrowingEventRequestJSONAdapter

+ (instancetype)adapterWithRequest:(id <GrowingRequestProtocol>)request {
    GrowingEventRequestJSONAdapter *adapter = [[self alloc] init];
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    [needAdaptReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 1;
}

@end
