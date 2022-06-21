//
//  GrowingEventRequestCompressionAdapter.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/4/24.
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

#import "Modules/DefaultServices/GrowingEventRequestCompressionAdapter.h"
#import "GrowingTrackerCore/Helpers/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"

@interface GrowingEventRequestCompressionAdapter ()

@property (nonatomic, weak) id <GrowingRequestProtocol> request;

@end

@implementation GrowingEventRequestCompressionAdapter

+ (instancetype)adapterWithRequest:(id <GrowingRequestProtocol>)request {
    GrowingEventRequestCompressionAdapter *adapter = [[self alloc] init];
    adapter.request = request;
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
#ifdef GROWING_ANALYSIS_ENABLE_ENCRYPTION
    // deprecated
    [needAdaptReq setValue:@"3" forHTTPHeaderField:@"X-Compress-Codec"];
#else
    BOOL encryptEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.encryptEnabled;
    if (encryptEnabled) {
        [needAdaptReq setValue:@"3" forHTTPHeaderField:@"X-Compress-Codec"];
    }
#endif
    
    if (![self.request respondsToSelector:@selector(events)] || self.request.events.length == 0) {
        return nil;
    }
    NSData *JSONData = self.request.events.copy;
    @autoreleasepool {
        // jsonString malloc to much
#ifdef GROWING_ANALYSIS_ENABLE_ENCRYPTION
        // deprecated
        JSONData = [JSONData growingHelper_LZ4String];
#else
        BOOL encryptEnabled = GrowingConfigurationManager.sharedInstance.trackConfiguration.encryptEnabled;
        if (encryptEnabled) {
            JSONData = [JSONData growingHelper_LZ4String];
        }
#endif
    }
    needAdaptReq.HTTPBody = JSONData;
    return needAdaptReq;
}

- (NSUInteger)priority {
    return 10;
}

@end
