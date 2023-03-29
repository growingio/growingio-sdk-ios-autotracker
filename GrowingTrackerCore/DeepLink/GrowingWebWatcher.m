//
// GrowingWebWatcher.m
// GrowingAnalytics
//
//  Created by 李嘉辉 on 2020/12/16.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/DeepLink/GrowingWebWatcher.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/LogFormat/GrowingASLLoggerFormat.h"

@interface GrowingWebWatcher () <GrowingDeepLinkHandlerProtocol>
@end

@implementation GrowingWebWatcher

static GrowingWebWatcher *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GrowingWebWatcher alloc] init];
    });
    return sharedInstance;
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
    NSDictionary *params = url.growingHelper_queryDict;
    //  open console.app 中的log
    NSString *openConsoleLog = params[@"openConsoleLog"];
    if (openConsoleLog && [openConsoleLog caseInsensitiveCompare:@"Yes"] == NSOrderedSame && ![GrowingLog.allLoggers containsObject:[GrowingASLLogger sharedInstance]]) {
        [GrowingLog addLogger:[GrowingASLLogger sharedInstance] withLevel:GrowingLogLevelAll];
        [GrowingASLLogger sharedInstance].logFormatter = [GrowingASLLoggerFormat new];
        return YES;
    }
    
    return NO;
}

@end
