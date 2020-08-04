//
//  GrowingEventAdRequest.m
//  GrowingTracker
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


#import "GrowingEventAdRequest.h"
#import "GrowingNetworkConfig.h"
#import "GrowingInstance.h"
#import "NSString+GrowingHelper.h"

@implementation GrowingEventAdRequest

- (NSURL *)absoluteURL {
    
    NSString *baseUrl = [GrowingNetworkConfig sharedInstance].growingReportEndPoint;
    if (!baseUrl.length) {
        return nil;
    }
    
    NSString *absoluteURLString = [baseUrl absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSDictionary *)query {
    return nil;
}

- (NSString *)path {
    NSString *accountId = [GrowingInstance sharedInstance].projectID ? : @"";
    NSString *path = [NSString stringWithFormat:@"app/%@/ios/ctvt", accountId];
    return path;
}

- (NSTimeInterval)timeoutInSeconds {
    return 60;
}

@end
