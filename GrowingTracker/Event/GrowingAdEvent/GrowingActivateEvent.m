//
//  GrowingActivateEvent.m
//  GrowingTracker
//
//  Created by GrowingIO on 2020/4/3.
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

//
/*
    iOS Measurement Protocol（v2.5）: https://growingio.atlassian.net/wiki/spaces/SDK/pages/269746335/iOS+Measurement+Protocol+v2.5#iOSMeasurementProtocol%EF%BC%88v2.5%EF%BC%89-activate%E8%AF%B7%E6%B1%82%E5%9B%A0%E5%AE%89%E5%85%A8%E6%80%A7%E6%96%B0%E6%8E%A5%E5%8F%A3%E4%BD%BF%E7%94%A8POST
 */

#import "GrowingActivateEvent.h"

@implementation GrowingActivateEvent

- (NSString *)eventTypeKey {
    return kEventTypeKeyActivate;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictDataM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    
    if (self.deeplinkInfo.linkId) {
        dictDataM[@"link_id"] = self.deeplinkInfo.linkId;
    }
    
    if (self.deeplinkInfo.clickId) {
        dictDataM[@"click_id"] = self.deeplinkInfo.clickId;
    }
    
    if (self.deeplinkInfo.clickTime) {
        dictDataM[@"tm_click"] = self.deeplinkInfo.clickTime;
    }
    
    dictDataM[@"ua"] = self.deeplinkInfo.userAgent;
    dictDataM[@"cl"] = self.deeplinkInfo.cl;
    
    return dictDataM;
}


@end

