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

#import "GrowingWebViewJavascriptBridgeConfiguration.h"


@implementation GrowingWebViewJavascriptBridgeConfiguration

- (instancetype)initWithProjectId:(NSString *)projectId appId:(NSString *)appId nativeSdkVersionCode:(int)nativeSdkVersionCode {
    self = [super init];
    if (self) {
        _projectId = [projectId copy];
        _appId = [appId copy];
        _nativeSdkVersionCode = nativeSdkVersionCode;
    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId appId:(NSString *)appId nativeSdkVersionCode:(int)nativeSdkVersionCode {
    return [[self alloc] initWithProjectId:projectId appId:appId nativeSdkVersionCode:nativeSdkVersionCode];
}

- (NSString *)toJsonString {
    NSDictionary* configuration = [self dictionaryWithValuesForKeys:@[@"projectId",@"appId",@"nativeSdkVersionCode"]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:configuration options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"json解析失败:%@", error);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}


@end
