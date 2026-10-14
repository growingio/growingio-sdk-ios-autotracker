//
//  GrowingConfigurationManager.m
//  GrowingAnalytics
//
// Created by xiangyang on 2020/11/10.
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

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"

@implementation GrowingConfigurationManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

+ (NSString *)normalizedServerHost:(NSString *)host {
    if (![host isKindOfClass:NSString.class] || !host.length ||
        [host rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].location != NSNotFound) {
        return nil;
    }
    NSURLComponents *url = [NSURLComponents componentsWithString:host];
    NSString *scheme = url.scheme.lowercaseString;
    if (!([scheme isEqualToString:@"https"] || [scheme isEqualToString:@"http"]) || !url.host.length || url.user ||
        url.password || url.query || url.fragment) {
        return nil;
    }
    url.scheme = scheme;
    url.host = url.host.lowercaseString;
    if (([scheme isEqualToString:@"https"] && url.port.integerValue == 443) ||
        ([scheme isEqualToString:@"http"] && url.port.integerValue == 80)) {
        url.port = nil;
    }
    if (url.port && (url.port.integerValue < 1 || url.port.integerValue > 65535)) {
        return nil;
    }
    NSString *path = url.percentEncodedPath;
    while ([path hasSuffix:@"/"]) {
        path = [path substringToIndex:path.length - 1];
    }
    url.percentEncodedPath = path;
    return url.URL ? url.string : nil;
}

+ (NSDictionary<NSString *, NSString *> *)validatedMapping:(GrowingTrackConfiguration *)configuration
                                                     error:(NSError **)error {
    NSDictionary *input = configuration.serverHostMapping;
    if (!input && configuration.dataSourceId.length && configuration.dataCollectionServerHost.length) {
        input = @{configuration.dataSourceId: configuration.dataCollectionServerHost};
    }
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    BOOL valid = [input isKindOfClass:NSDictionary.class] && configuration.dataSourceId.length;
    if (valid) {
        for (id key in input) {
            NSString *host = [self normalizedServerHost:input[key]];
            if (![key isKindOfClass:NSString.class] || ![key length] || !host) {
                valid = NO;
                break;
            }
            mapping[[key copy]] = host;
        }
        valid = valid && mapping[configuration.dataSourceId] != nil;
    }
    if (!valid) {
        if (error) {
            *error =
                [NSError errorWithDomain:@"com.growing.routing"
                                    code:1
                                userInfo:@{NSLocalizedDescriptionKey: @"Invalid data source or server host mapping"}];
        }
        return nil;
    }
    return mapping.copy;
}

- (NSString *)serverHostForDataSourceId:(NSString *)dataSourceId {
    return dataSourceId.length ? self.trackConfiguration.serverHostMapping[dataSourceId] : nil;
}

- (NSDictionary *)eventContext {
    GrowingSession *session = GrowingSession.currentSession;
    return @{
        @"dataSourceId": self.trackConfiguration.dataSourceId ?: @"",
        @"sessionId": session.sessionId ?: @"",
        @"userId": session.loginUserId ?: NSNull.null,
        @"userKey": session.loginUserKey ?: NSNull.null,
        @"sequence": @(self.routingSequence)
    };
}

@end
