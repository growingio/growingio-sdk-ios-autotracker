//
//  GrowingVisitEvent.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/5/18.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingVisitEvent.h"
#import "GrowingDeviceInfo.h"
#import "GrowingEventManager.h"
#import "GrowingNetworkInterfaceManager.h"
#import "GrowingRealTracker.h"

@interface GrowingVisitEvent ()

@end

@implementation GrowingVisitEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingVisitBuilder *subBuilder = (GrowingVisitBuilder*)builder;
        _idfa = subBuilder.idfa;
        _idfv = subBuilder.idfv;
        _extraSdk = subBuilder.extraSdk;
    }
    return self;
}

+ (GrowingVisitBuilder *_Nonnull)builder {
    return [[GrowingVisitBuilder alloc] init];
}

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dataDictM[@"idfa"] = self.idfa;
    dataDictM[@"idfv"] = self.idfv;
    return dataDictM;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingVisitBuilder

- (void)readPropertyInTrackThread {
    [super readPropertyInTrackThread];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _idfa = deviceInfo.idfa;
    _idfv = deviceInfo.idfv;
}

- (GrowingVisitBuilder *(^)(NSString *value))setIdfa {
    return ^(NSString *value) {
        self->_idfa = value;
        return self;
    };
}
- (GrowingVisitBuilder *(^)(NSString *value))setIdfv {
    return ^(NSString *value) {
        self->_idfv = value;
        return self;
    };
}
- (GrowingVisitBuilder *(^)(NSDictionary<NSString *,NSString*> *value))setExtraSdk {
    return ^(NSDictionary<NSString *,NSString*> *value) {
        self->_extraSdk = value;
        return self;
    };
}
//_eventType成员变量并没有值
- (NSString *)eventType {
    return GrowingEventTypeVisit;
}

- (GrowingBaseEvent *)build {
    return [[GrowingVisitEvent alloc] initWithBuilder:self];
}


@end
#pragma clang diagnostic pop
