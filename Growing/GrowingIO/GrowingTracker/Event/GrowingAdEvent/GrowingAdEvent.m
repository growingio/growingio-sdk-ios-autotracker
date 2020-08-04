//
//  GrowingAdEvent.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/5/28.
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


#import "GrowingAdEvent.h"
#import "GrowingDeviceInfo.h"
#import "GrowingInstance.h"
#import "GrowingEventManager.h"


@interface GrowingDeeplinkInfo ()

@property (nonatomic, copy, readwrite) NSString * _Nullable linkId;
@property (nonatomic, copy, readwrite) NSString * _Nullable clickId;
@property (nonatomic, copy, readwrite) NSString * _Nullable clickTime;
@property (nonatomic, copy, readwrite) NSString * _Nullable userAgent;
@property (nonatomic, copy, readwrite) NSString * _Nullable cl;

@end

@implementation GrowingDeeplinkInfo

- (instancetype)initWithLinkId:(NSString *)linkId
                       clickId:(NSString *)clickId
                     clickTime:(NSString *)clickTime {
    
    GrowingDeeplinkInfo *info = [[GrowingDeeplinkInfo alloc] initWithLinkId:linkId
                                                                    clickId:clickId
                                                                  clickTime:clickTime
                                                                  userAgent:nil
                                                                         cl:nil];
    
    return info;
}

- (instancetype)initWithLinkId:(NSString *)linkId
                       clickId:(NSString *)clickId
                     clickTime:(NSString *)clickTime
                     userAgent:(NSString *)ua
                            cl:(NSString *)cl {
    
    GrowingDeeplinkInfo *info = [[GrowingDeeplinkInfo alloc] init];
    info.linkId = linkId;
    info.clickId = clickId;
    info.clickTime = clickTime;
    info.userAgent = ua;
    info.cl = cl;
    return info;
}

- (instancetype)initWithQueryDict:(NSDictionary *)queryDict {
    if (!queryDict) {
        return nil;
    }
    
    if (![queryDict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    GrowingDeeplinkInfo *info = [[GrowingDeeplinkInfo alloc] initWithLinkId:queryDict[@"link_id"]
                                                                    clickId:queryDict[@"click_id"]
                                                                  clickTime:queryDict[@"tm_click"]];
    info.cl = queryDict[@"cl"];
    info.userAgent = queryDict[@"ua"];
    info.renngageMechanism = queryDict[@"rngg_mch"];
    
    return info;
}

@end

@interface GrowingAdEvent ()

@property (nonatomic, strong, readwrite) GrowingDeeplinkInfo *deeplinkInfo;

@end

@implementation GrowingAdEvent

+ (void)sendEventWithDeeplinkInfo:(GrowingDeeplinkInfo *)deeplinkInfo {
    
    if (deeplinkInfo == nil) {
        return;
    }
    
    if ([GrowingInstance sharedInstance] == nil) {
        return;
    }
    
    GrowingAdEvent *adEvent = [[self alloc] init];
    adEvent.deeplinkInfo = deeplinkInfo;
    
    [[GrowingEventManager shareInstance] addEvent:adEvent
                                         thisNode:nil
                                      triggerNode:nil
                                      withContext:nil];
}

#pragma mark GrowingEventSendPolicyDelegate

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictDataM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];

    dictDataM[@"ui"] = deviceInfo.idfa;
    dictDataM[@"iv"] = deviceInfo.idfv;
    dictDataM[@"osv"]= deviceInfo.systemVersion;
    dictDataM[@"dm"] = deviceInfo.deviceModel;

    return dictDataM;
}

@end

