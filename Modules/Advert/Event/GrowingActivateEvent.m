//
//  GrowingActivateEvent.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/8/29.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "Modules/Advert/Event/GrowingActivateEvent.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

NSString *const GrowingEventTypeActivate = @"ACTIVATE";
NSString *const GrowingAdvertEventNameActivate = @"$app_activation";
NSString *const GrowingAdvertEventNameDefer = @"$app_defer";
NSString *const GrowingAdvertEventNameReengage = @"$app_reengage";

@implementation GrowingActivateEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingActivateBuilder *subBuilder = (GrowingActivateBuilder *)builder;
        _eventName = subBuilder.eventName;
        _idfa = subBuilder.idfa;
        _idfv = subBuilder.idfv;
    }
    return self;
}

+ (GrowingActivateBuilder *)builder {
    return [[GrowingActivateBuilder alloc] init];
}

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"eventName"] = self.eventName;
    dataDictM[@"idfa"] = self.idfa;
    dataDictM[@"idfv"] = self.idfv;
    return [dataDictM copy];
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingActivateBuilder

- (void)readPropertyInTrackThread {
    [super readPropertyInTrackThread];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _idfa = deviceInfo.idfa;
    _idfv = deviceInfo.idfv;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmethod-signatures"
#pragma clang diagnostic ignored "-Wmismatched-return-types"
- (GrowingBaseBuilder * (^)(NSString *value))setEventName {
    return ^(NSString *value) {
        self->_eventName = value;
        return self;
    };
}
#pragma clang diagnostic pop

- (GrowingBaseEvent *)build {
    return [[GrowingActivateEvent alloc] initWithBuilder:self];
}

- (NSString *)eventType {
    return GrowingEventTypeActivate;
}

@end
#pragma clang diagnostic pop
