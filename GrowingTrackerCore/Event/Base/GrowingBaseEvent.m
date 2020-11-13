//
// Created by xiangyang on 2020/11/10.
//

#import "GrowingBaseEvent.h"
#import "GrowingDeviceInfo.h"
#import "GrowingSession.h"
#import "GrowingTimeUtil.h"

@implementation GrowingBaseEvent
- (instancetype)init {
    self = [super init];
    if (self) {
        _deviceId = [GrowingDeviceInfo currentDeviceInfo].deviceIDString;
        _userId = @"";
        _sessionId = GrowingSession.currentSession.sessionId;
//        _timestamp = GrowingTimeUtil.currentTimeMillis;
        _domain = @"";
        _urlScheme = @"";
//        _appState =0;
//        _globalSequenceId =;
//        _eventSequenceId =;
//        _extraParams =;
    }

    return self;
}

- (NSString *)eventType {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end