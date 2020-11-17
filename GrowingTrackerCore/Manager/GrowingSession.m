//
// Created by xiangyang on 2020/11/10.
//

#import <CoreLocation/CoreLocation.h>
#import "GrowingSession.h"
#import "GrowingAppLifecycle.h"
#import "GrowingConfigurationManager.h"
#import "GrowingTrackConfiguration.h"
#import "GrowingLogMacros.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingTimeUtil.h"
#import "NSString+GrowingHelper.h"

@interface GrowingSession () <GrowingAppLifecycleDelegate>
@property(nonatomic, assign) BOOL alreadySendVisitEvent;
@property(nonatomic, copy) NSString *latestNonNullUserId;
@property(nonatomic, assign, readonly) long long sessionInterval;
@property(nonatomic, copy) CLLocation *location;
@property(nonatomic, assign) long long latestVisitTime;
@property(nonatomic, assign) long long latestDidEnterBackgroundTime;

@property(strong, nonatomic, readonly) NSHashTable *userIdChangedDelegates;
@property(strong, nonatomic, readonly) NSLock *delegateLock;
@end

static GrowingSession *currentSession = nil;

@implementation GrowingSession
@synthesize sessionId = _sessionId;
@synthesize loginUserId = _loginUserId;

- (instancetype)initWithSessionInterval:(NSTimeInterval)sessionInterval {
    self = [super init];
    if (self) {
        _sessionInterval = (long long) (sessionInterval * 1000LL);

        _alreadySendVisitEvent = NO;
        _latestVisitTime = 0;
        _latestDidEnterBackgroundTime = 0;
        // todo latestNonNullUserId 取值;

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
        [delegate userIdDidChangedFrom:oldUserId.copy to:newUserId.copy];
    }
    [self.delegateLock unlock];
}

- (void)setLoginUserId:(NSString *)loginUserId {
    NSString *oldUserId = _loginUserId.copy;
    _loginUserId = loginUserId.copy;
    // todo loginUserId 持久化
    [self resendVisitByUserIdDidChangedFrom:oldUserId to:_loginUserId.copy];
    [self dispatchUserIdDidChangedFrom:oldUserId to:_loginUserId.copy];
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

- (void)applicationDidBecomeActive {
    long long now = GrowingTimeUtil.currentTimeMillis;
    if (now - self.latestDidEnterBackgroundTime >= self.sessionInterval) {
        [self refreshSessionId];
        [self sendVisitEventWithTimestamp:now];
    }
}

- (void)resendVisitEvent {
    GIOLogDebug(@"resendVisitEvent");
    [self sendVisitEventWithTimestamp:self.latestVisitTime];
}

- (void)sendVisitEventWithTimestamp:(long long)timestamp {
    GIOLogDebug(@"sendVisitEventWithTimestamp");
    if (!self.alreadySendVisitEvent) {
        self.alreadySendVisitEvent = YES;
    }
    self.latestVisitTime = timestamp;
    // todo 发送VisitEvent
}

- (void)refreshSessionId {
    _sessionId = NSUUID.UUID.UUIDString;
}

- (void)applicationDidEnterBackground {
    self.latestDidEnterBackgroundTime = GrowingTimeUtil.currentTimeMillis;
    [self sendAppClosedEventWithTimestamp:self.latestDidEnterBackgroundTime];
}

- (void)sendAppClosedEventWithTimestamp:(NSTimeInterval)timestamp {
    // todo 发送AppClosedEvent
}


@end