//
//  GrowingEventRequestAdapter.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/6/18.
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

#import "GrowingTrackerCore/Network/Request/Adapter/GrowingEventRequestAdapter.h"
#import "GrowingTrackerCore/Network/Request/GrowingEventRequest.h"
#import "GrowingTrackerCore/Helpers/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"

@implementation GrowingEventRequestHeaderAdapter

+ (instancetype)adapterWithRequest:(id <GrowingRequestProtocol>)request {
    GrowingEventRequestHeaderAdapter *adapter = [[self alloc] init];
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
#ifdef GROWING_ANALYSIS_ENABLE_ENCRYPTION
    // deprecated
    [needAdaptReq setValue:@"3" forHTTPHeaderField:@"X-Compress-Codec"];
    [needAdaptReq setValue:@"1" forHTTPHeaderField:@"X-Crypt-Codec"];
#else
    BOOL encryptEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.encryptEnabled;
    if (encryptEnabled) {
        [needAdaptReq setValue:@"3" forHTTPHeaderField:@"X-Compress-Codec"];
        [needAdaptReq setValue:@"1" forHTTPHeaderField:@"X-Crypt-Codec"];
    }
#endif
    [needAdaptReq setValue:[NSString stringWithFormat:@"%lld",[GrowingTimeUtil currentTimeMillis]] forHTTPHeaderField:@"X-Timestamp"];
    [needAdaptReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return needAdaptReq;
}

@end

#pragma mark GrowingEventRequestJsonBodyAdpter

@interface GrowingEventRequestJsonBodyAdpter ()

@property (nonatomic, weak) id <GrowingRequestProtocol> request;

@end

@implementation GrowingEventRequestJsonBodyAdpter

+ (instancetype)adapterWithRequest:(id <GrowingRequestProtocol>)request {
    GrowingEventRequestJsonBodyAdpter *adapter = [[self alloc] init];
    adapter.request = request;
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    if (self.request.events.length == 0) {
        return nil;
    }
    NSData *JSONData = self.request.events.copy;
    @autoreleasepool {
        // jsonString malloc to much
#ifdef GROWING_ANALYSIS_ENABLE_ENCRYPTION
        // deprecated
        JSONData = [JSONData growingHelper_LZ4String];
        JSONData = [JSONData growingHelper_xorEncryptWithHint:(self.request.stm & 0xFF)];
#else
        BOOL encryptEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.encryptEnabled;
        if (encryptEnabled) {
            JSONData = [JSONData growingHelper_LZ4String];
            JSONData = [JSONData growingHelper_xorEncryptWithHint:(self.request.stm & 0xFF)];
        }
#endif
    }
    NSMutableURLRequest *needAdaptReq = request;
    needAdaptReq.HTTPBody = JSONData;
    
    return needAdaptReq;
}

@end
