//
//  GrowingFileStore.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/1/13.
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


#import "GrowingDataTraffic.h"
#import <pthread.h>
#import "GrowingFileStorage.h"

static NSString *const kGrowingUploadEventFileKey = @"GrowingUploadEventFileKey";
static NSString *const kGrowingCellularUploadEventSize = @"GrowingCellularUploadEventSize";

@interface GrowingDataTraffic ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSMutableDictionary *storeDict;

@property (nonatomic, strong) GrowingFileStorage *cellularTrafficStorage;

@end

@implementation GrowingDataTraffic

static pthread_mutex_t _mutex;
static GrowingDataTraffic *_instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setup];
        pthread_mutex_init(&_mutex,NULL);
    });
    return _instance;
}

- (void)setup {
    
    self.cellularTrafficStorage = [[GrowingFileStorage alloc] initWithName:@"config"];
    NSDictionary *savedDict = [self.cellularTrafficStorage dictionaryForKey:kGrowingUploadEventFileKey];
    
    if (savedDict == nil || [savedDict isKindOfClass:NSDictionary.class]) {
        self.storeDict = [NSMutableDictionary dictionaryWithDictionary:savedDict];
    }
}


+ (unsigned long long)cellularNetworkUploadEventSize {
    
    NSString *todayUploadEvent = [[GrowingDataTraffic sharedInstance].storeDict valueForKey:kGrowingCellularUploadEventSize];
    NSArray *todayUploadEventArray = [todayUploadEvent componentsSeparatedByString:@"/"];
    if (todayUploadEventArray.count >= 2 && [[todayUploadEventArray objectAtIndex:1] isEqualToString:[self getTodayKey]]) {
        return [todayUploadEventArray.firstObject longLongValue];
    } else {
        return 0;
    }
}

+ (void)cellularNetworkStorgeEventSize:(unsigned long long)uploadEventSize {
    
    pthread_mutex_lock(&_mutex);
    NSString *todayUploadEvent = [NSString stringWithFormat:@"%@/%@", [NSString stringWithFormat:@"%llu",uploadEventSize], [self getTodayKey]];
    [[GrowingDataTraffic sharedInstance].storeDict setObject:todayUploadEvent forKey:kGrowingCellularUploadEventSize];
    [[GrowingDataTraffic sharedInstance].cellularTrafficStorage setDictionary:[GrowingDataTraffic sharedInstance].storeDict forKey:kGrowingUploadEventFileKey];
    pthread_mutex_unlock(&_mutex);
    
}

+ (NSString*)getTodayKey {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    return date;
}


@end
