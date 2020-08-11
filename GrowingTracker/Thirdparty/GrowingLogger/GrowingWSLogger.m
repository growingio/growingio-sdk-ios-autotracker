//
//  GrowingWSLogger.m
//  GrowingTracker
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


#import "GrowingWSLogger.h"

static const NSInteger kGIOMaxCachesLogNumber = 100;

@interface GrowingWSLogger ()

@property (nonatomic, strong) dispatch_queue_t cacheQueue;
@property (nonatomic, strong) NSMutableArray *cacheArray;

@end

@implementation GrowingWSLogger

+ (instancetype)sharedInstance {

    static GrowingWSLogger *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.cacheQueue =
            dispatch_queue_create("com.cacheLogger.queue", DISPATCH_QUEUE_CONCURRENT);
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

    //  timestamp formatter
    NSTimeInterval epoch = [logMessage->_timestamp timeIntervalSince1970];
    struct tm tm;
    time_t time = (time_t)epoch;
    (void)localtime_r(&time, &tm);
//    int milliseconds = (int)((epoch - floor(epoch)) * 1000.0);
//    NSString *timeStamp = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d:%03d", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, milliseconds];
    
    //  获取对应的字典构成字典，转成json进行发送
    
    if (logMsg) {
        dispatch_barrier_async(self.cacheQueue, ^{
            
            if (0/*  WS 开启 && 日志打开*/) {
                //  1、如果有缓存 self.cacheArray.count > 0，获取所有缓存
                //  2、当前这条日志
                //  3、ws发送
                //  4、清除缓存  [self.cacheArray removeAllObjects];
            } else {
                  while ((NSInteger)self.cacheArray.count >= self.maxCachesNumber) {
                      [self.cacheArray removeObjectAtIndex:0];
                  }
                [self.cacheArray addObject:logMessage];
            }
        });
    }
}

- (NSArray *)cacheLogArray {

    __block NSArray *cacheArray;
    dispatch_async(self.cacheQueue, ^{
        cacheArray = self.cacheArray.copy;
    });
    return cacheArray;
}

@end
