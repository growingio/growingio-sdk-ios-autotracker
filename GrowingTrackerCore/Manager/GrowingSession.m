//
//  Created by xiangyang on 2020/11/10.
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

#import "GrowingSession.h"
#import "GrowingAppLifecycle.h"
#import "GrowingConfigurationManager.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingLogMacros.h"
#import "GrowingLogger.h"
#import "GrowingTimeUtil.h"
#import "NSString+GrowingHelper.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingEventGenerator.h"

@interface GrowingSession () <GrowingAppLifecycleDelegate>
@property(nonatomic, assign) BOOL alreadySendVisitEvent;
@property(nonatomic, copy) NSString *latestNonNullUserId;
@property(nonatomic, assign, readonly) long long sessionInterval;
@property(nonatomic, assign) long long latestVisitTime;
@property(nonatomic, assign) long long latestDidEnterBackgroundTime;
@property(strong, nonatomic, readonly) NSHashTable *userIdChangedDelegates;
@property(strong, nonatomic, readonly) NSLock *delegateLock;
@end

static GrowingSession *currentSession = nil;

@implementation GrowingSession
@synthesize sessionId = _sessionId;
@synthesize loginUserId = _loginUserId;
@synthesize loginUserKey = _loginUserKey;

- (instancetype)initWithSessionInterval:(NSTimeInterval)sessionInterval {
    self = [super init];
    if (self) {
        _sessionInterval = (long long) (sessionInterval * 1000LL);

        _alreadySendVisitEvent = NO;
        _latestVisitTime = 0;
        _latestDidEnterBackgroundTime = 0;
        _loginUserId = [GrowingPersistenceDataProvider sharedInstance].loginUserId;
        _loginUserKey = [GrowingPersistenceDataProvider sharedInstance].loginUserKey;
        _latestNonNullUserId = [GrowingPersistenceDataProvider sharedInstance].loginUserId;
        _userIdChangedDelegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _delegateLock = [[NSLock alloc] init];
    }

    return self;
}

- (BOOL)createdSession {
    return self.alreadySendVisitEvent;
}

+ (void)startSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTimeInterval sessionInterval = GrowingConfigurationManager.sharedInstance.trackConfiguration.sessionInterval;
        currentSession = [[self alloc] initWithSessionInterval:sessionInterval];
    });
    [GrowingAppLifecycle.sharedInstance addAppLifecycleDelegate:currentSession];
}

+ (instancetype)currentSession {
    return currentSession;
}

- (void)forceReissueVisit {
    if (self.alreadySendVisitEvent) {
        return;
    }
    [self refreshSessionId];
    [self sendVisitEventWithTimestamp:GrowingTimeUtil.currentTimeMillis];
}

- (void)addUserIdChangedDelegate:(id <GrowingUserIdChangedDelegate>)delegate {
    [self.delegateLock lock];
    [self.userIdChangedDelegates addObject:delegate];
    [self.delegateLock unlock];
}

- (void)removeUserIdChangedDelegate:(id <GrowingUserIdChangedDelegate>)delegate {
    [self.delegateLock lock];
    [self.userIdChangedDelegates removeObject:delegate];
    [self.delegateLock unlock];
}

- (void)dispatchUserIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId {
    [self.delegateLock lock];
    for (id <GrowingUserIdChangedDelegate> delegate in self.userIdChangedDelegates) {
        if ([delegate respondsToSelector:@selector(userIdDidChangedFrom:to:)]) {
            [delegate userIdDidChangedFrom:oldUserId.copy to:newUserId.copy];
        }
    }
    [self.delegateLock unlock];
}

- (void)setLoginUserId:(NSString *)loginUserId userKey:(NSString *)userKey {
    if (loginUserId && loginUserId.length > 1000) {
        GIOLogError(@"setLoginUserId:userKey:, loginUserId is too long");
        return;
    }
    if (userKey && userKey.length > 1000) {
        GIOLogError(@"setLoginUserId:userKey:, userKey is too long");
        return;
    }
    if (!loginUserId || loginUserId.length == 0) {
        NSString *oldUserId = _loginUserId.copy;
        _loginUserId = nil;
        _loginUserKey = nil;
        [[GrowingPersistenceDataProvider sharedInstance] setLoginUserId:nil];
        [[GrowingPersistenceDataProvider sharedInstance] setLoginUserKey:nil];
        //额外的处理者
        if (oldUserId && oldUserId.length > 0) {
            [self dispatchUserIdDidChangedFrom:oldUserId to:nil];
        }
        GIOLogDebug(@"setLoginUserId:userKey:, clean loginUserId and userKey");
        return;
    }
    
    if ([NSString growingHelper_isEqualStringA:loginUserId andStringB:self.loginUserId] && [NSString growingHelper_isEqualStringA:userKey andStringB:self.loginUserKey]) {
        GIOLogWarn(@"setLoginUserId:userKey:, but loginUserId and loginUserKey is equal");
        return;
    }

    NSString *oldUserId = _loginUserId.copy;
    _loginUserId = loginUserId.copy;
    _loginUserKey = userKey.copy;
    
    // 持久化
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserId:_loginUserId];
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserKey:_loginUserKey];

    //额外的处理者
    [self dispatchUserIdDidChangedFrom:oldUserId to:_loginUserId.copy];
    //重发visit事件，必须在分发UserIdDidChangedFrom:to:方法之后，处理者可能修改visit中的数据内容
    [self resendVisitByUserIdDidChangedFrom:oldUserId to:_loginUserId.copy];
}

- (void)setLoginUserId:(NSString *)loginUserId {
    [self setLoginUserId:loginUserId userKey:nil];
}

- (void)resendVisitByUserIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId {
    GIOLogDebug(@"resendVisitByUserIdDidChangedFrom %@ to %@", oldUserId, newUserId);
    if (![NSString growingHelper_isBlankString:newUserId]) {
        if ([NSString growingHelper_isBlankString:self.latestNonNullUserId]) {
            [self resendVisitEvent];
        } else {
            if (![newUserId isEqualToString:self.latestNonNullUserId]) {
                [self refreshSessionId];
                [self sendVisitEventWithTimestamp:GrowingTimeUtil.currentTimeMillis];
            }
        }
        self.latestNonNullUserId = newUserId;
    }
}

// ios 11 系统上面VC的viewDidAppear生命周期会早于AppDelegate的applicationDidBecomeActive，这样会造成Page事件早于visit事件
- (void)applicationDidBecomeActive {
    // 第一次启动，且已经发送过visit事件，说明visit事件被强制补发了，这里就不在发送visit事件了
    if (self.latestDidEnterBackgroundTime == 0 && self.alreadySendVisitEvent) {
        GIOLogDebug(@"First launched and already send visit");
        return;
    }

    long long now = GrowingTimeUtil.currentTimeMillis;
    if (now - self.latestDidEnterBackgroundTime >= self.sessionInterval) {
        [self refreshSessionId];
        [self sendVisitEventWithTimestamp:now];
    }
}

/// 设置经纬度坐标
/// @param latitude 纬度
/// @param longitude 经度
- (void)setLocation:(double)latitude longitude:(double)longitude {
    //经纬度从无到有会发visit
    if ((_latitude == 0 && (ABS(latitude) > 0)) || (_longitude == 0 && ABS(longitude) > 0)) {
        _latitude = latitude;
        _longitude = longitude;
        if (self.alreadySendVisitEvent) {
            [self resendVisitEvent];
        }
        return;
    }
    _latitude = latitude;
    _longitude = longitude;
}

/// 清除地理位置
- (void)cleanLocation {
    _latitude = 0;
    _longitude = 0;
}

- (void)resendVisitEvent {
    GIOLogDebug(@"resendVisitEvent");
    [self sendVisitEventWithTimestamp:self.latestVisitTime];
}

- (void)sendVisitEventWithTimestamp:(long long)timestamp {
    if (!self.alreadySendVisitEvent) {
        self.alreadySendVisitEvent = YES;
    }
    self.latestVisitTime = timestamp;
    // 发送VisitEvent
    [GrowingEventGenerator generateVisitEvent:timestamp];
}

- (void)refreshSessionId {
    _sessionId = NSUUID.UUID.UUIDString;
}

- (void)applicationDidEnterBackground {
    self.latestDidEnterBackgroundTime = GrowingTimeUtil.currentTimeMillis;
    [self sendAppClosedEventWithTimestamp:self.latestDidEnterBackgroundTime];
}

- (void)sendAppClosedEventWithTimestamp:(NSTimeInterval)timestamp {
    // 发送AppClosedEvent
    [GrowingEventGenerator generateAppCloseEvent];
}


@end
