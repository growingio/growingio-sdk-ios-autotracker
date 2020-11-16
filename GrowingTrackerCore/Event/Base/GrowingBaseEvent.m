//
// Created by xiangyang on 2020/11/10.
//

#import "GrowingBaseEvent.h"
#import "GrowingDeviceInfo.h"
#import "GrowingSession.h"
#import "GrowingTimeUtil.h"

@implementation GrowingBaseEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder*)builder {
    self = [super init];
    if (self) {
        _deviceId = builder.deviceId;
        _userId = builder.userId;
        _sessionId = builder.sessionId;
        _timestamp = builder.timestamp;
        _domain = builder.domain;
        _urlScheme = builder.urlScheme;
        _appState = builder.appState;
        _globalSequenceId = builder.globalSequenceId;
        _eventSequenceId = builder.eventSequenceId;
        _extraParams = builder.extraParams;
    }
    return self;
}


- (NSString *)eventType {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
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

    dataDict[@"globalSequenceId"] = self.globalSequenceId;
    dataDict[@"eventSequenceId"] = self.eventSequenceId;
    dataDict[@"appState"] = (self.appState.intValue == GrowingAppStateForeground) ? @"FOREGROUND" : @"BACKGROUND";
    dataDict[@"urlScheme"] = self.urlScheme;
    return [dataDict copy];
}

@end


@implementation GrowingBaseBuilder

- (instancetype)init {
    if (self = [super init]) {
        GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
        _sessionId = deviceInfo.sessionID ?: @"";
        _timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
        _domain = deviceInfo.bundleID;
        _deviceId = deviceInfo.deviceIDString ?: @"";
        _urlScheme = deviceInfo.urlScheme;
    }
    return self;
}
//赋值属性，eg:deviceId,userId,sessionId,globalSequenceId,eventSequenceId
- (void)readPropertyInMainThread {
    _appState = [NSNumber numberWithInteger:[UIApplication sharedApplication].applicationState];
    //TODO: 赋值
//    _globalSequenceId =
//    _userId =
}

- (GrowingBaseBuilder *(^)(NSString *value))setDeviceId {
    return ^(NSString *value) {
        self->_deviceId = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSString *value))setUserId {
    return ^(NSString *value) {
        self->_userId = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSString *value))setSessionId {
    return ^(NSString *value) {
        self->_sessionId = value;
        return self;
    };
}

- (GrowingBaseBuilder *(^)(long long value))setTimestamp; {
    return ^(long long value) {
        self->_timestamp = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSString *value))setDomain {
    return ^(NSString *value) {
        self->_domain = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSString *value))setUrlScheme {
    return ^(NSString *value) {
        self->_urlScheme = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSNumber *value))setAppState {
    return ^(NSNumber *value) {
        self->_appState = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSNumber *value))setGlobalSequenceId {
    return ^(NSNumber *value) {
        self->_globalSequenceId = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSNumber *value))setEventSequenceId {
    return ^(NSNumber *value) {
        self->_eventSequenceId = value;
        return self;
    };
}
- (GrowingBaseBuilder *(^)(NSDictionary *value))setExtraParams {
    return ^(NSDictionary *value) {
        self->_extraParams = value;
        return self;
    };
}

- (GrowingBaseEvent *)build {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
