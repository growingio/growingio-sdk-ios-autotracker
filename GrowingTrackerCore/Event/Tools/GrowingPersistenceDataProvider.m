//
// GrowingEventPersistence.m
// Pods
//
//  Created by sheng on 2020/11/13.
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


#import "GrowingPersistenceDataProvider.h"

static NSString *GrowingUserdefault_file = @"growingio.userdefault";
static NSString *GrowingUserdefault_deviceId = @"growingio.userdefault.deviceid";
//static NSString *GrowingUserdefault_sessionId = @"growingio.userdefault.sessionId";
static NSString *GrowingUserdefault_loginUserId = @"growingio.userdefault.loginUserId";


static NSString *GrowingUserdefault_globalId = @"growingio.userdefault.globalId";
static NSString *GrowingUserdefault_prefix = @"growingio.userdefault";


@class GrowingEventSequenceObject;
@interface GrowingPersistenceDataProvider()
@property (nonatomic, strong) NSUserDefaults *growingUserdefault;
@end

@implementation GrowingPersistenceDataProvider

static GrowingPersistenceDataProvider *persistence = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistence = [[GrowingPersistenceDataProvider alloc] init];
    });
    return persistence;
}

- (instancetype)init {
    if (self = [super init]) {
        _growingUserdefault = [[NSUserDefaults alloc] initWithSuiteName:GrowingUserdefault_file];
    }
    return self;
}

- (void)setDeviceId:(NSString *)deviceId {
    //空值
    if (deviceId.length == 0) {
        return;
    }
    [_growingUserdefault setValue:deviceId forKey:GrowingUserdefault_deviceId];
    //write now!
    [_growingUserdefault synchronize];
}


- (NSString *)deviceId {
    return  [_growingUserdefault valueForKey:GrowingUserdefault_deviceId];;
}

//- (void)setSessionId:(NSString * _Nonnull)sessionId {
//    //空值
//    if (sessionId.length == 0) {
//        return;
//    }
//    [_growingUserdefault setValue:sessionId forKey:GrowingUserdefault_sessionId];
//    //write now!
//    [_growingUserdefault synchronize];
//}
//- (NSString *)sessionId {
//    return  [_growingUserdefault valueForKey:GrowingUserdefault_sessionId];
//}

- (void)setLoginUserId:(NSString * _Nonnull)loginUserId {
    //空值
    if (loginUserId.length == 0) {
        return;
    }
    [_growingUserdefault setValue:loginUserId forKey:GrowingUserdefault_loginUserId];
    //write now!
    [_growingUserdefault synchronize];
}

- (NSString *)loginUserId {
    return  [_growingUserdefault valueForKey:GrowingUserdefault_loginUserId];
}

///设置NSString,NSNumber
- (void)setString:(NSString *)value forKey:(NSString *)key {
    [_growingUserdefault setValue:value forKey:key];
}

- (void)getStringforKey:(NSString *)key {
    [_growingUserdefault valueForKey:key];
}

- (GrowingEventSequenceObject*)getAndIncrement:(NSString *)eventType {
    long long globalId = [self increaseFor:GrowingUserdefault_globalId spanValue:1];
    long long eventTypeId = [self increaseFor:[NSString stringWithFormat:@"%@.%@",GrowingUserdefault_prefix,eventType] spanValue:1];
    GrowingEventSequenceObject* obj = [[GrowingEventSequenceObject alloc] init];
    obj.globalId = globalId;
    obj.eventTypeId = eventTypeId;
    return  obj;
}

- (long long)increaseFor:(NSString *)key spanValue:(int)span {
    @synchronized (self) {
        NSNumber *value = [_growingUserdefault valueForKey:key];
        if (!value) {
            value = [NSNumber numberWithLongLong:0];
        }
        
        long long result = value.longLongValue + span;
        value = @(result);
        [_growingUserdefault setValue:value forKey:key];
        [_growingUserdefault synchronize];
        return result;
    }
}

@end


@implementation GrowingEventSequenceObject


@end
