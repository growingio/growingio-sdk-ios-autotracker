//
// GrowingWebViewJavascriptBridgeConfiguration.m
// GrowingAnalytics
//
//  Created by GrowingIO on 2020/5/27.
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

#import "Modules/Hybrid/GrowingWebViewJavascriptBridgeConfiguration.h"

@implementation GrowingWebViewJavascriptBridgeConfiguration

- (instancetype)initWithAccountId:(NSString *)accountId
                     dataSourceId:(NSString *)dataSourceId
                            appId:(NSString *)appId
                       appPackage:(NSString *)appPackage
                 nativeSdkVersion:(NSString *)nativeSdkVersion
             nativeSdkVersionCode:(int)nativeSdkVersionCode {
    self = [super init];
    if (self) {
        _accountId = [accountId copy];
        _dataSourceId = [dataSourceId copy];
        _appId = [appId copy];
        _appPackage = [appPackage copy];
        _nativeSdkVersion = [nativeSdkVersion copy];
        _nativeSdkVersionCode = nativeSdkVersionCode;
    }

    return self;
}

+ (instancetype)configurationWithAccountId:(NSString *)accountId
                              dataSourceId:(NSString *)dataSourceId
                                     appId:(NSString *)appId
                                appPackage:(NSString *)appPackage
                          nativeSdkVersion:(NSString *)nativeSdkVersion
                      nativeSdkVersionCode:(int)nativeSdkVersionCode {
    return [[self alloc] initWithAccountId:accountId
                              dataSourceId:dataSourceId
                                     appId:appId
                                appPackage:appPackage
                          nativeSdkVersion:nativeSdkVersion
                      nativeSdkVersionCode:nativeSdkVersionCode];
}

- (NSString *)toJsonString {
    NSMutableDictionary *configuration = [self dictionaryWithValuesForKeys:@[
        @"dataSourceId",
        @"appId",
        @"appPackage",
        @"nativeSdkVersion",
        @"nativeSdkVersionCode"
    ]].mutableCopy;
    configuration[@"projectId"] = self.accountId;

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:configuration
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        return nil;
    }
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
