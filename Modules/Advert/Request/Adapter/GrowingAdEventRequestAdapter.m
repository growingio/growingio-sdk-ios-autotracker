//
//  GrowingAdEventRequestAdapter.m
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

#import "Modules/Advert/Request/Adapter/GrowingAdEventRequestAdapter.h"
#import "GrowingTrackerCore/Helpers/NSData+GrowingHelper.h"

@interface GrowingAdEventRequestAdapter ()

@property (nonatomic, weak) id <GrowingRequestProtocol> request;

@end

@implementation GrowingAdEventRequestAdapter

+ (instancetype)adapterWithRequest:(id <GrowingRequestProtocol>)request {
    GrowingAdEventRequestAdapter *adapter = [[self alloc] init];
    adapter.request = request;
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    if (![self.request respondsToSelector:@selector(events)] || self.request.events.length == 0) {
        return request;
    }
    
    // advertising events must compress and encrypt
    NSMutableURLRequest *needAdaptReq = request;
    [needAdaptReq setValue:@"3" forHTTPHeaderField:@"X-Compress-Codec"];
    [needAdaptReq setValue:@"1" forHTTPHeaderField:@"X-Crypt-Codec"];
    
    NSData *JSONData = self.request.events.copy;
    @autoreleasepool {
        // jsonString malloc to much
        JSONData = [JSONData growingHelper_LZ4String];
        if ([self.request respondsToSelector:@selector(stm)]) {
            JSONData = [JSONData growingHelper_xorEncryptWithHint:(self.request.stm & 0xFF)];
        }
    }
    needAdaptReq.HTTPBody = JSONData;
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 10;
}

@end
