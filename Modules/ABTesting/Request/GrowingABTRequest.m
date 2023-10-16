//
//  GrowingABTRequest.m
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

#import "Modules/ABTesting/Request/GrowingABTRequest.h"
#import "Modules/ABTesting/Public/GrowingABTesting.h"
#import "Modules/ABTesting/Request/GrowingABTRequestAdapter.h"

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

@implementation GrowingABTRequest

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
}

- (NSURL *)absoluteURL {
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    NSURL *baseURL = [NSURL URLWithString:config.abTestingServerHost];
    return [NSURL URLWithString:self.path relativeToURL:baseURL];
}

- (NSString *)path {
    return @"diversion/specified-layer-variables";
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    GrowingABTRequestAdapter *bodyAdapter = [GrowingABTRequestAdapter adapterWithRequest:self];
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    NSString *accountId = config.projectId;
    NSString *datasourceId = config.dataSourceId;
    NSString *distinctId = [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
    bodyAdapter.parameters = @{
        @"accountId": accountId,
        @"datasourceId": datasourceId,
        @"distinctId": distinctId,
        @"layerId": self.layerId.copy
    };

    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:bodyAdapter, methodAdapter, nil];
    return adapters;
}

- (NSTimeInterval)timeoutInSeconds {
    return 5.0f;
}

@end
