//
//  GrowingBaseEvent+Protobuf.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/3.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
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

#import <objc/message.h>
#import "Services/Protobuf/Catagory/GrowingBaseEvent+Protobuf.h"
#import "Services/Protobuf/Catagory/GrowingPBEventV3Dto+GrowingHelper.h"
#import "Services/Protobuf/Proto/GrowingEvent.pbobjc.h"

@implementation GrowingBaseEvent (Protobuf)

- (GrowingPBEventV3Dto *)toProtobuf {
    GrowingPBEventV3Dto *dto = [[GrowingPBEventV3Dto alloc] init];
    dto.dataSourceId = self.dataSourceId;
    dto.sessionId = self.sessionId;
    dto.timestamp = self.timestamp;
    dto.eventType = [dto growingHelper_eventType:self.eventType];
    dto.domain = self.domain;
    dto.userId = self.userId;
    dto.deviceId = self.deviceId;
    dto.platform = self.platform;
    dto.platformVersion = self.platformVersion;
    dto.eventSequenceId = (int)self.eventSequenceId;
    dto.appState = (self.appState == GrowingAppStateForeground) ? @"FOREGROUND" : @"BACKGROUND";
    dto.URLScheme = self.urlScheme;
    dto.networkState = self.networkState;
    dto.screenWidth = (int)self.screenWidth;
    dto.screenHeight = (int)self.screenHeight;
    dto.deviceBrand = self.deviceBrand;
    dto.deviceModel = self.deviceModel;
    dto.deviceType = self.deviceType;
    dto.appName = self.appName;
    dto.appVersion = self.appVersion;
    dto.language = self.language;
    dto.latitude = self.latitude;
    dto.longitude = self.longitude;
    dto.sdkVersion = self.sdkVersion;
    dto.userKey = self.userKey;

    __weak typeof(self) weakSelf = self;
    NSString * (^stringBlock)(NSString *) = ^(NSString *selectorString) {
        __strong typeof(weakSelf) self = weakSelf;
        SEL selector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:selector]) {
            return ((NSString * (*)(id, SEL)) objc_msgSend)(self, selector);
        }
        return @"";
    };

    int32_t (^int32Block)(NSString *) = ^(NSString *selectorString) {
        __strong typeof(weakSelf) self = weakSelf;
        SEL selector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:selector]) {
            int32_t result = ((int32_t(*)(id, SEL))objc_msgSend)(self, selector);
            return result > 0 ? result : 0;
        }
        return 0;
    };

    NSDictionary<NSString *, NSString *> * (^dicBlock)(NSString *) = ^(NSString *selectorString) {
        __strong typeof(weakSelf) self = weakSelf;
        SEL selector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:selector]) {
            return ((NSDictionary * (*)(id, SEL)) objc_msgSend)(self, selector);
        }
        return @{};
    };

    dto.idfa = stringBlock(@"idfa");
    dto.idfv = stringBlock(@"idfv");
    dto.extraSdk = dicBlock(@"extraSdk").mutableCopy;
    dto.path = stringBlock(@"path");
    dto.textValue = stringBlock(@"textValue");
    dto.xpath = stringBlock(@"xpath");
    dto.xcontent = stringBlock(@"xcontent");
    dto.index = int32Block(@"index");
    dto.query = stringBlock(@"query");
    dto.hyperlink = stringBlock(@"hyperlink");
    dto.attributes = [dto growingHelper_safeMap:dicBlock(@"attributes")];  // hybrid 可能会返回 NSNull value
    dto.orientation = stringBlock(@"orientation");
    dto.title = stringBlock(@"title");
    dto.referralPage = stringBlock(@"referralPage");
    dto.protocolType = stringBlock(@"protocolType");
    dto.eventName = stringBlock(@"eventName");

    return dto;
}

@end
