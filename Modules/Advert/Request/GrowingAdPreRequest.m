//
//  GrowingAdPreRequest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/11/21.
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

#import "Modules/Advert/Request/GrowingAdPreRequest.h"
#import "Modules/Advert/Public/GrowingAdvertising.h"
#import "Modules/Advert/Request/GrowingAdRequestHeaderAdapter.h"

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

@implementation GrowingAdPreRequest

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodGET;
}

- (NSURL *)absoluteURL {
    NSURL *baseURL;
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (config.deepLinkHost && config.deepLinkHost.length > 0) {
        baseURL = [NSURL URLWithString:config.deepLinkHost];
    } else {
        baseURL = [NSURL URLWithString:GrowingAdDefaultDeepLinkHost];
    }
    return [NSURL URLWithString:self.path relativeToURL:baseURL];
}

- (NSString *)path {
    GrowingTrackConfiguration *config = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    NSString *projectKey = config.projectId ?: @"";
    NSString *datasourceId = config.dataSourceId ?: @"";
    NSString *path = [NSString stringWithFormat:@"deep/v1/%@/ios/%@/%@/%@", self.isManual ? @"inapp" : @"defer",
                                                                            projectKey,
                                                                            datasourceId,
                                                                            self.trackId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    NSDictionary *headers = @{@"User-Agent" : self.userAgent};
    GrowingAdRequestHeaderAdapter *basicHeaderAdapter = [GrowingAdRequestHeaderAdapter adapterWithRequest:self
                                                                                                   header:headers];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, nil];
    return adapters;
}

@end
