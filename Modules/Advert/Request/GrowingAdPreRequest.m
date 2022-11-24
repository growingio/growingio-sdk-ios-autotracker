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
#import "Modules/Advert/Request/GrowingAdRequestHeaderAdapter.h"

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"

@implementation GrowingAdPreRequest

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = @"https://t.growingio.com";
    if (!baseUrl.length) {
        return nil;
    }
    NSString *absoluteURLString = [baseUrl growingHelper_absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSString *)path {
    NSString *projectKey = GrowingConfigurationManager.sharedInstance.trackConfiguration.projectId ?: @"";
    NSString *datasourceId = GrowingConfigurationManager.sharedInstance.trackConfiguration.dataSourceId ?: @"";
    NSString *path = [NSString stringWithFormat:@"deep/v1/%@/ios/%@/%@/%@", self.isManual ? @"inapp" : @"defer",
                                                                            projectKey,
                                                                            datasourceId,
                                                                            self.trackId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    NSDictionary *headers = @{@"Content-Type" : @"application/json",
                              @"User-Agent" : self.userAgent};
    GrowingAdRequestHeaderAdapter *basicHeaderAdapter = [GrowingAdRequestHeaderAdapter adapterWithRequest:self
                                                                                                   header:headers];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, nil];
    return adapters;
}

@end