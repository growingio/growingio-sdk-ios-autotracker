//
//  GrowingEventRequestHeaderAdapter+Protobuf.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/3.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Protobuf/GrowingEventRequestHeaderAdapter+Protobuf.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"

@implementation GrowingEventRequestHeaderAdapter (Protobuf)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

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
    [needAdaptReq setValue:@"application/protobuf" forHTTPHeaderField:@"Content-Type"];
    return needAdaptReq;
}

#pragma clang diagnostic pop

@end
