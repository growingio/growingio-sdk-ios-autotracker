//
// GrowingBaseEvent+SendPolicy.h
// Pods
//
//  Created by sheng on 2020/11/13.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingBaseEvent.h"

typedef NS_ENUM(NSUInteger, GrowingEventSendPolicy) {
    GrowingEventSendPolicyInstant = 1,///实时发送
    GrowingEventSendPolicyMobileData = 2,///移动网络流量发送
    GrowingEventSendPolicyWifi = 3,///wif情况下发送
};
NS_ASSUME_NONNULL_BEGIN

@interface GrowingBaseEvent (SendPolicy)

@property (nonatomic, assign) GrowingEventSendPolicy sendPolicy;

@end

NS_ASSUME_NONNULL_END
