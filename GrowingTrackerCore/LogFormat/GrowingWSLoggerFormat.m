//
// GrowingWSLoggerFormat.m
// GrowingAnalytics
//
//  Created by GrowingIO on 2020/8/13.
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

#import "GrowingTrackerCore/LogFormat/GrowingWSLoggerFormat.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

NS_INLINE NSString *logLevel(GrowingLogFlag level) {
    switch (level) {
        case GrowingLogFlagError:
            return @"Error";
        case GrowingLogFlagWarning:
            return @"Warn";
        case GrowingLogFlagInfo:
            return @"Info";
        case GrowingLogFlagDebug:
            return @"Debug";
        case GrowingLogFlagVerbose:
        default:
            return @"Verbose";
    }
}

@implementation GrowingWSLoggerFormat

- (nullable NSString *)formatLogMessage:(GrowingLogMessage *)logMessage {
    long long epoch = [logMessage->_timestamp timeIntervalSince1970] * 1000;
    NSMutableDictionary *logDic = [NSMutableDictionary dictionary];
    [logDic setValue:[logLevel(logMessage->_flag) uppercaseString] forKey:@"type"];
    [logDic setValue:@"" forKey:@"subType"];
    [logDic setValue:logMessage->_message forKey:@"message"];
    [logDic setValue:[NSNumber numberWithLongLong:epoch] forKey:@"time"];
    return [logDic growingHelper_jsonString];
}

@end
