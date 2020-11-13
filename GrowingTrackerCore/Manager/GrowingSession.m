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

@interface GrowingSession () <GrowingAppLifecycleDelegate>
@property(nonatomic, copy, readwrite) NSString *sessionId;

@property(nonatomic, assign) BOOL alreadySendVisitEvent;
@property(nonatomic, copy) NSString *latestNonNullUserId;
@property(nonatomic, assign, readonly) NSTimeInterval sessionInterval;
@property(nonatomic, copy) CLLocation *location;
@property(nonatomic, assign) NSTimeInterval latestVisitTime;
@property(nonatomic, assign) NSTimeInterval latestDidEnterBackgroundTime;
@end

static id _currentSession = nil;

@implementation GrowingSession

- (instancetype)initWithSessionInterval:(NSTimeInterval)sessionInterval {
    self = [super init];
    if (self) {
        _sessionInterval = sessionInterval;

        _alreadySendVisitEvent = NO;
        _latestVisitTime = 0;
        _latestDidEnterBackgroundTime = 0;
    }

    return self;
}

+ (void)startSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTimeInterval sessionInterval = GrowingConfigurationManager.sharedInstance.trackConfiguration.sessionInterval;
        _currentSession = [[self alloc] initWithSessionInterval:sessionInterval];
    });
    [GrowingAppLifecycle.sharedInstance addAppLifecycleDelegate:_currentSession];
}

+ (instancetype)currentSession {
    return _currentSession;
}

- (NSString *)sessionId {
    return _sessionId.copy;
}

- (void)applicationDidBecomeActive {
    NSTimeInterval now = NSDate.date.timeIntervalSince1970;
    if (now - self.latestDidEnterBackgroundTime >= self.sessionInterval) {
        [self refreshSessionId];
        self.latestVisitTime = now;
        [self sendVisitEventWithTimestamp:now];
    }
}

- (void)sendVisitEventWithTimestamp:(NSTimeInterval)timestamp {
    GIOLogDebug(@"sendVisitEventWithTimestamp, timestamp = %d", timestamp);
    self.alreadySendVisitEvent = YES;
}

- (void)refreshSessionId {
    _sessionId = NSUUID.UUID.UUIDString;
}

- (void)applicationDidEnterBackground {
    self.latestDidEnterBackgroundTime = NSDate.date.timeIntervalSince1970;
}

- (void)sendAppClosedEventWithTimestamp:(NSTimeInterval)timestamp {

}

@end