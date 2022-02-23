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

#import "GrowingEventRequestAdapter.h"
#import "GrowingEventRequest.h"
#import "NSData+GrowingHelper.h"
#import "GrowingTimeUtil.h"
#import "GrowingConfigurationManager.h"
#import "GrowingLogger.h"

@implementation GrowingEventRequestHeaderAdapter

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
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

@property (nonatomic, copy) NSData *events;
@property (nonatomic, assign, readwrite) unsigned long long timestamp;
@property (nonatomic, copy) void(^outsizeBlock)(unsigned long long);

@end

@implementation GrowingEventRequestJsonBodyAdpter

+ (instancetype)eventJsonBodyAdpter:(NSData *)events
                          timestamp:(unsigned long long)timestamp
                       outsizeBlock:(nonnull void (^)(unsigned long long))outsizeBlock {
    GrowingEventRequestJsonBodyAdpter *bodyAdapter = [[GrowingEventRequestJsonBodyAdpter alloc] init];
    bodyAdapter.events = events;
    bodyAdapter.timestamp = timestamp;
    bodyAdapter.outsizeBlock = outsizeBlock;
    return bodyAdapter;
}

- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
    if (self.events.length == 0) {
        return nil;
    }
    NSData *JSONData = self.events.copy;
    @autoreleasepool {
        // jsonString malloc to much
#ifdef GROWING_ANALYSIS_ENABLE_ENCRYPTION
        // deprecated
        JSONData = [JSONData growingHelper_LZ4String];
        JSONData = [JSONData growingHelper_xorEncryptWithHint:(self.timestamp & 0xFF)];
#else
        BOOL encryptEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.encryptEnabled;
        if (encryptEnabled) {
            JSONData = [JSONData growingHelper_LZ4String];
            JSONData = [JSONData growingHelper_xorEncryptWithHint:(self.timestamp & 0xFF)];
        }
#endif
    }
    if (self.outsizeBlock) {
        self.outsizeBlock(JSONData.length);
    }
    NSMutableURLRequest *needAdaptReq = request;
    needAdaptReq.HTTPBody = JSONData;
    
    return needAdaptReq;
}

@end
