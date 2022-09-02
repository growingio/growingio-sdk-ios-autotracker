//
//  GrowingReengageEvent.m
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

#import "Modules/Advert/Event/GrowingReengageEvent.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

NSString * const GrowingEventTypeReengage = @"REENGAGE";

@implementation GrowingReengageEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingReengageBuilder *subBuilder = (GrowingReengageBuilder *)builder;
        _idfa = subBuilder.idfa;
        _idfv = subBuilder.idfv;
    }
    return self;
}

+ (GrowingReengageBuilder *_Nonnull)builder {
    return [[GrowingReengageBuilder alloc] init];
}

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    //如果有额外参数添加
    if (self.extraParams.count > 0) {
        [dataDict addEntriesFromDictionary:self.extraParams];
    }
    
    dataDict[@"s"] = self.sessionId;
    dataDict[@"u"] = self.deviceId;
    dataDict[@"t"] = self.eventType;
    dataDict[@"tm"] = @(self.timestamp);
    dataDict[@"d"] = self.domain;
    dataDict[@"dm"] = self.deviceModel;
    dataDict[@"osv"] = self.platformVersion;
    dataDict[@"ui"] = self.idfa;
    dataDict[@"iv"] = self.idfv;
    dataDict[@"gesid"] = @(self.globalSequenceId);
    dataDict[@"esid"] = @(self.eventSequenceId);
    return [dataDict copy];
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingReengageBuilder

- (void)readPropertyInTrackThread {
    [super readPropertyInTrackThread];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _idfa = deviceInfo.idfa;
    _idfv = deviceInfo.idfv;
}

- (GrowingBaseEvent *)build {
    return [[GrowingReengageEvent alloc] initWithBuilder:self];
}

- (NSString *)eventType {
    return GrowingEventTypeReengage;
}

@end
#pragma clang diagnostic pop
