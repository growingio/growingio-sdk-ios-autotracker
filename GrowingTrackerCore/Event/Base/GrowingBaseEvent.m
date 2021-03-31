//
// Created by xiangyang on 2020/11/10.
//

#import "GrowingBaseEvent.h"

#import "GrowingDeviceInfo.h"
#import "GrowingPersistenceDataProvider.h"
#import "GrowingRealTracker.h"
#import "GrowingSession.h"
#import "GrowingTimeUtil.h"

@implementation GrowingBaseEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    self = [super init];
    if (self) {
        _deviceId = builder.deviceId;
        _userId = builder.userId;
        _sessionId = builder.sessionId;
        _eventType = builder.eventType;
        _timestamp = builder.timestamp;
        _domain = builder.domain;
        _urlScheme = builder.urlScheme;
        _appState = builder.appState;
        _globalSequenceId = builder.globalSequenceId;
        _eventSequenceId = builder.eventSequenceId;
        _platform = builder.platform;
        _platformVersion = builder.platformVersion;
        _extraParams = builder.extraParams;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    //如果有额外参数添加
    if (self.extraParams.count > 0) {
        [dataDict addEntriesFromDictionary:self.extraParams];
    }
    dataDict[@"sessionId"] = self.sessionId;
    dataDict[@"timestamp"] = @(self.timestamp);
    dataDict[@"eventType"] = self.eventType;
    dataDict[@"domain"] = self.domain;
    dataDict[@"userId"] = self.userId;
    dataDict[@"deviceId"] = self.deviceId;
    dataDict[@"platform"] = self.platform;
    dataDict[@"platformVersion"] = self.platformVersion;
    dataDict[@"globalSequenceId"] = @(self.globalSequenceId);
    dataDict[@"eventSequenceId"] = @(self.eventSequenceId);
    dataDict[@"appState"] = (self.appState == GrowingAppStateForeground) ? @"FOREGROUND" : @"BACKGROUND";
    dataDict[@"urlScheme"] = self.urlScheme;
    return [dataDict copy];
}

@end

@implementation GrowingBaseBuilder

- (instancetype)init {
    if (self = [super init]) {
        _timestamp = [GrowingTimeUtil currentTimeMillis];
        GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
        _domain = deviceInfo.bundleID;
    }
    return self;
}
//赋值属性，eg:deviceId,userId,sessionId,globalSequenceId,eventSequenceId
- (void)readPropertyInMainThread {
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _appState = deviceInfo.appState;
    _deviceId = deviceInfo.deviceIDString ?: @"";
    _urlScheme = deviceInfo.urlScheme;
    _platform = deviceInfo.platform;
    _platformVersion = deviceInfo.platformVersion;

    GrowingEventSequenceObject *sequence =
        [[GrowingPersistenceDataProvider sharedInstance] getAndIncrement:self.eventType];
    _globalSequenceId = sequence.globalId;
    _eventSequenceId = sequence.eventTypeId;
    GrowingSession *session = [GrowingSession currentSession];
    _userId = session.loginUserId;
    _sessionId = session.sessionId;
}

- (GrowingBaseBuilder * (^)(NSString *value))setDeviceId {
    return ^(NSString *value) {
        self->_deviceId = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(NSString *value))setUserId {
    return ^(NSString *value) {
        self->_userId = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(NSString *value))setSessionId {
    return ^(NSString *value) {
        self->_sessionId = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(long long value))setTimestamp;
{
    return ^(long long value) {
        self->_timestamp = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(NSString *value))setDomain {
    return ^(NSString *value) {
        self->_domain = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(NSString *value))setUrlScheme {
    return ^(NSString *value) {
        self->_urlScheme = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(int value))setAppState {
    return ^(int value) {
        self->_appState = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(long long value))setGlobalSequenceId {
    return ^(long long value) {
        self->_globalSequenceId = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(long long value))setEventSequenceId {
    return ^(long long value) {
        self->_eventSequenceId = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setPlatform {
    return ^(NSString *value) {
        self->_platform = value;
        return self;
    };
}
- (GrowingBaseBuilder * (^)(NSString *value))setPlatformVersion {
    return ^(NSString *value) {
        self->_platformVersion = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSDictionary *value))setExtraParams {
    return ^(NSDictionary *value) {
        self->_extraParams = value;
        return self;
    };
}

- (GrowingBaseBuilder * (^)(NSString *value))setEventType {
    return ^(NSString *value) {
        self->_eventType = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    @throw [NSException
        exceptionWithName:NSInternalInconsistencyException
                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                 userInfo:nil];
}

@end
