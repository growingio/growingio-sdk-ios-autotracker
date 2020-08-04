//
//  GrowingReengageEvent.m
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


#import "GrowingReengageEvent.h"

@implementation GrowingReengageEvent


- (NSString *)eventTypeKey {
    return @"reengage";
}


#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictDataM = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    
    if (self.deeplinkInfo.customParams.count != 0) {
        dictDataM[@"var"] = self.deeplinkInfo.customParams;
    }
    
    if (self.deeplinkInfo.linkId) {
        dictDataM[@"link_id"] = self.deeplinkInfo.linkId;
    }
    
    if (self.deeplinkInfo.clickId) {
        dictDataM[@"click_id"] = self.deeplinkInfo.clickId;
    }
    
    if (self.deeplinkInfo.clickTime) {
        dictDataM[@"tm_click"] = self.deeplinkInfo.clickTime;
    }
    
    dictDataM[@"cl"] = self.deeplinkInfo.cl;
    dictDataM[@"ua"] = self.deeplinkInfo.userAgent;
    dictDataM[@"rngg_mch"] = self.deeplinkInfo.renngageMechanism;
    dictDataM[@"var"] = self.deeplinkInfo.customParams;
    
    return dictDataM;
}


@end
