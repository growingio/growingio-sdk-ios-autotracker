//
//  GrowingWSLogger.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/5/6.
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

#import "GrowingTrackerCore/Thirdparty/Logger/GrowingWSLogger.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"

static const NSInteger kGIOMaxCachesLogNumber = 100;

@interface GrowingWSLogger ()

@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, assign) NSInteger maxCachesNumber;

@end

@implementation GrowingWSLogger

+ (instancetype)sharedInstance {

    static GrowingWSLogger *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.cacheArray      = [NSMutableArray array];
        sharedInstance.maxCachesNumber = kGIOMaxCachesLogNumber;
    });
    return sharedInstance;
}

- (GrowingLoggerName)loggerName {
    return GrowingLoggerNameWS;
}

- (void)logMessage:(GrowingLogMessage *)logMessage {
    NSString *logMsg = logMessage->_message;
    BOOL isFormatted = NO;
    if (_logFormatter) {
        logMsg      = [_logFormatter formatLogMessage:logMessage];
        isFormatted = logMsg != logMessage->_message;
    }
    
    if (logMsg) {
        NSDictionary *logDic = [logMsg growingHelper_dictionaryObject];
        if (self.loggerBlock) {
            [self.cacheArray addObject:logDic];
            self.loggerBlock(self.cacheArray.copy);
            [self.cacheArray removeAllObjects];
        } else {
            while ((NSInteger)self.cacheArray.count >= self.maxCachesNumber) {
              [self.cacheArray removeObjectAtIndex:0];
            }
            [self.cacheArray addObject:logDic];
        }
    }
}

@end
