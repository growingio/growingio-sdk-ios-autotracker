//
//  GrowingSession.m
//  GrowingAnalytics
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

#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingTrackerCore/Event/GrowingEventGenerator.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/Tools/GrowingPersistenceDataProvider.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Public/GrowingTrackConfiguration.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogMacros.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Timer/GrowingEventTimer.h"
#import "GrowingTrackerCore/Utils/GrowingInternalMacros.h"
#import "GrowingULAppLifecycle.h"
#import "GrowingULTimeUtil.h"
#import "GrowingTrackerCore/Network/GrowingNetworkPreflight.h"

@interface GrowingSession () <GrowingULAppLifecycleDelegate>

@property (nonatomic, copy, readwrite) NSString *sessionId;
@property (nonatomic, copy, readwrite) NSString *loginUserId;
@property (nonatomic, copy, readwrite) NSString *loginUserKey;
@property (nonatomic, copy, readwrite) NSString *latestNonNullUserId;
@property (nonatomic, assign, readonly) long long sessionInterval;
@property (nonatomic, assign) long long latestDidEnterBackgroundTime;
@property (nonatomic, strong, readonly) NSHashTable *userIdChangedDelegates;
@property (nonatomic, assign, readwrite) GrowingSessionState state;

@end

static GrowingSession *currentSession = nil;

@implementation GrowingSession {
    GROWING_LOCK_DECLARE(lock);
}

- (instancetype)initWithSessionInterval:(NSTimeInterval)sessionInterval {
    self = [super init];
    if (self) {
        _sentVisitAfterRefreshSessionId = NO;
        _sessionInterval = (long long)(sessionInterval * 1000LL);
        _latestDidEnterBackgroundTime = 0;
        _loginUserId = [GrowingPersistenceDataProvider sharedInstance].loginUserId;
        _loginUserKey = [GrowingPersistenceDataProvider sharedInstance].loginUserKey;
        _latestNonNullUserId = [GrowingPersistenceDataProvider sharedInstance].loginUserId;
        _userIdChangedDelegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _state = GrowingSessionStateActive;
        GROWING_LOCK_INIT(lock);
    }

    return self;
}

+ (void)startSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTimeInterval sessionInterval = GrowingConfigurationManager.sharedInstance.trackConfiguration.sessionInterval;
        currentSession = [[self alloc] initWithSessionInterval:sessionInterval];
    });

    [GrowingULAppLifecycle.sharedInstance addAppLifecycleDelegate:currentSession];
    [currentSession refreshSessionId];
}

+ (instancetype)currentSession {
    return currentSession;
}

- (void)generateVisit {
    [GrowingNetworkPreflight sendPreflight];
    
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!trackConfiguration.dataCollectionEnabled) {
        return;
    }
    _sentVisitAfterRefreshSessionId = YES;
    [GrowingEventGenerator generateVisitEvent];
}

- (void)refreshSessionId {
    _sessionId = NSUUID.UUID.UUIDString;
    _sentVisitAfterRefreshSessionId = NO;
}

// iOS 11系统上面VC的viewDidAppear生命周期会早于AppDelegate的applicationDidBecomeActive，这样会造成Page事件早于Visit事件
- (void)applicationDidBecomeActive {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        self.state = GrowingSessionStateActive;
        if (self.latestDidEnterBackgroundTime == 0) {
            // 首次启动，在SDK初始化时，即发送visit事件
            return;
        }
        long long now = GrowingULTimeUtil.currentTimeMillis;
        if (now - self.latestDidEnterBackgroundTime >= self.sessionInterval) {
            [self refreshSessionId];
            [self generateVisit];
        }
        [GrowingEventTimer handleAllTimersResume];
    }];
}

// 下拉显示通知中心/系统权限授权弹窗显示
- (void)applicationWillResignActive {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        self.state = GrowingSessionStateInactive;
        self.latestDidEnterBackgroundTime = GrowingULTimeUtil.currentTimeMillis;
    }];
}

- (void)applicationDidEnterBackground {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        self.state = GrowingSessionStateBackground;
        self.latestDidEnterBackgroundTime = GrowingULTimeUtil.currentTimeMillis;
        [GrowingEventGenerator generateAppCloseEvent];
        [[GrowingEventManager sharedInstance] flushDB];
        [GrowingEventTimer handleAllTimersPause];
    }];
}

- (void)applicationWillTerminate {
    [GrowingDispatchManager
        dispatchInGrowingThread:^{
            // make sure APP_CLOSED event did saved, and all events did flush to database
        }
                  waitUntilDone:YES];
}

- (void)addUserIdChangedDelegate:(id<GrowingUserIdChangedDelegate>)delegate {
    GROWING_LOCK(lock);
    [self.userIdChangedDelegates addObject:delegate];
    GROWING_UNLOCK(lock);
}

- (void)removeUserIdChangedDelegate:(id<GrowingUserIdChangedDelegate>)delegate {
    GROWING_LOCK(lock);
    [self.userIdChangedDelegates removeObject:delegate];
    GROWING_UNLOCK(lock);
}

- (void)dispatchUserIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId {
    GROWING_LOCK(lock);
    for (id<GrowingUserIdChangedDelegate> delegate in self.userIdChangedDelegates) {
        if ([delegate respondsToSelector:@selector(userIdDidChangedFrom:to:)]) {
            [delegate userIdDidChangedFrom:oldUserId.copy to:newUserId.copy];
        }
    }
    GROWING_UNLOCK(lock);
}

- (void)setLoginUserId:(NSString *)loginUserId userKey:(NSString *)userKey {
    GrowingTrackConfiguration *trackConfiguration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if (!trackConfiguration.idMappingEnabled) {
        userKey = nil;
    }
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
        // 额外的处理者
        if (oldUserId && oldUserId.length > 0) {
            [self dispatchUserIdDidChangedFrom:oldUserId to:nil];
        }
        GIOLogDebug(@"setLoginUserId:userKey:, clean loginUserId and userKey");
        return;
    }

    if ([NSString growingHelper_isEqualStringA:loginUserId andStringB:self.loginUserId] &&
        [NSString growingHelper_isEqualStringA:userKey andStringB:self.loginUserKey]) {
        GIOLogWarn(@"setLoginUserId:userKey:, but loginUserId and loginUserKey is equal");
        return;
    }

    NSString *oldUserId = _loginUserId.copy;
    _loginUserId = loginUserId.copy;
    _loginUserKey = userKey.copy;

    // 持久化
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserId:_loginUserId];
    [[GrowingPersistenceDataProvider sharedInstance] setLoginUserKey:_loginUserKey];

    // 额外的处理者
    [self dispatchUserIdDidChangedFrom:oldUserId to:_loginUserId.copy];
    // 重发visit事件，必须在分发UserIdDidChangedFrom:to:方法之后，处理者可能修改visit中的数据内容
    [self resendVisitByUserIdDidChangedFrom:oldUserId to:_loginUserId.copy];
}

- (void)setLoginUserId:(NSString *)loginUserId {
    [self setLoginUserId:loginUserId userKey:nil];
}

- (void)resendVisitByUserIdDidChangedFrom:(NSString *)oldUserId to:(NSString *)newUserId {
    GIOLogDebug(@"resendVisitByUserIdDidChangedFrom %@ to %@", oldUserId, newUserId);
    if (![NSString growingHelper_isBlankString:newUserId]) {
        NSString *latestNonNullUserId = self.latestNonNullUserId.copy;
        self.latestNonNullUserId = newUserId;
        if (![NSString growingHelper_isBlankString:latestNonNullUserId] &&
            ![newUserId isEqualToString:latestNonNullUserId]) {
            [self refreshSessionId];
            [self generateVisit];
        }
    }
}

- (void)setLocation:(double)latitude longitude:(double)longitude {
    _latitude = latitude;
    _longitude = longitude;
}

- (void)cleanLocation {
    _latitude = 0;
    _longitude = 0;
}

@end
