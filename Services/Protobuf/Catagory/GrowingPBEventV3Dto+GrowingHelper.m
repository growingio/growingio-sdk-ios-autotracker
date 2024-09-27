//
//  GrowingPBEventV3Dto+GrowingHelper.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/9.
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

#import "Services/Protobuf/Catagory/GrowingPBEventV3Dto+GrowingHelper.h"

@implementation GrowingPBEventV3Dto (GrowingHelper)

- (id)growingHelper_jsonObject {
    // Protobuf官方不提供对应JSON转换
    // https://github.com/protocolbuffers/protobuf/pull/4808
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    if (self.deviceId.length > 0) {
        [dic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.userId.length > 0) {
        [dic setObject:self.userId forKey:@"userId"];
    }
    if (self.sessionId.length > 0) {
        [dic setObject:self.sessionId forKey:@"sessionId"];
    }
    if (self.dataSourceId.length > 0) {
        [dic setObject:self.dataSourceId forKey:@"dataSourceId"];
    }
    switch (self.eventType) {
        case GrowingPBEventType_Visit: {
            [dic setObject:@"VISIT" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_Custom: {
            [dic setObject:@"CUSTOM" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_LoginUserAttributes: {
            [dic setObject:@"LOGIN_USER_ATTRIBUTES" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_AppClosed: {
            [dic setObject:@"APP_CLOSED" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_Page: {
            [dic setObject:@"PAGE" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_ViewClick: {
            [dic setObject:@"VIEW_CLICK" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_ViewChange: {
            [dic setObject:@"VIEW_CHANGE" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_FormSubmit: {
            [dic setObject:@"FORM_SUBMIT" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_Activate: {
            [dic setObject:@"ACTIVATE" forKey:@"eventType"];
        } break;
        case GrowingPBEventType_PageAttributes: { /* Deprecated */
            [dic setObject:@"PAGE_ATTRIBUTES" forKey:@"eventType"];
        } break;
        default:
            break;
    }
    if (self.platform.length > 0) {
        [dic setObject:self.platform forKey:@"platform"];
    }
    if (self.timestamp > 0) {
        [dic setObject:@(self.timestamp) forKey:@"timestamp"];
    }
    if (self.domain.length > 0) {
        [dic setObject:self.domain forKey:@"domain"];
    }
    if (self.path.length >= 0 &&
        (self.eventType == GrowingPBEventType_Page || self.eventType == GrowingPBEventType_Custom || self.eventType == GrowingPBEventType_ViewClick ||
         self.eventType == GrowingPBEventType_ViewChange)) {
        [dic setObject:self.path forKey:@"path"];
    }
    if (self.query.length > 0) {
        [dic setObject:self.query forKey:@"query"];
    }
    if (self.title.length > 0) {
        [dic setObject:self.title forKey:@"title"];
    }
    if (self.referralPage.length > 0) {
        [dic setObject:self.referralPage forKey:@"referralPage"];
    }
    if (self.eventSequenceId > 0) {
        [dic setObject:@(self.eventSequenceId) forKey:@"eventSequenceId"];
    }
    if (self.screenHeight > 0) {
        [dic setObject:@(self.screenHeight) forKey:@"screenHeight"];
    }
    if (self.screenWidth > 0) {
        [dic setObject:@(self.screenWidth) forKey:@"screenWidth"];
    }
    if (self.language.length > 0) {
        [dic setObject:self.language forKey:@"language"];
    }
    if (self.sdkVersion.length > 0) {
        [dic setObject:self.sdkVersion forKey:@"sdkVersion"];
    }
    if (self.appVersion.length > 0) {
        [dic setObject:self.appVersion forKey:@"appVersion"];
    }
    if (self.eventName.length > 0) {
        [dic setObject:self.eventName forKey:@"eventName"];
    }
    if (self.attributes_Count > 0) {
        [dic setObject:self.attributes forKey:@"attributes"];
    }
    if (self.protocolType.length > 0) {
        [dic setObject:self.protocolType forKey:@"protocolType"];
    }
    if (self.textValue.length > 0) {
        [dic setObject:self.textValue forKey:@"textValue"];
    }
    if (self.xpath.length > 0) {
        [dic setObject:self.xpath forKey:@"xpath"];
    }
    if (self.xcontent.length > 0) {
        [dic setObject:self.xcontent forKey:@"xcontent"];
    }
    if (self.index > 0) {
        [dic setObject:@(self.index) forKey:@"index"];
    }
    if (self.hyperlink.length > 0) {
        [dic setObject:self.hyperlink forKey:@"hyperlink"];
    }
    if (self.URLScheme.length > 0) {
        [dic setObject:self.URLScheme forKey:@"urlScheme"];
    }
    if (self.appState.length > 0) {
        [dic setObject:self.appState forKey:@"appState"];
    }
    if (self.networkState.length > 0) {
        [dic setObject:self.networkState forKey:@"networkState"];
    }
    if (self.platformVersion.length > 0) {
        [dic setObject:self.platformVersion forKey:@"platformVersion"];
    }
    if (self.deviceBrand.length > 0) {
        [dic setObject:self.deviceBrand forKey:@"deviceBrand"];
    }
    if (self.deviceModel.length > 0) {
        [dic setObject:self.deviceModel forKey:@"deviceModel"];
    }
    if (self.deviceType.length > 0) {
        [dic setObject:self.deviceType forKey:@"deviceType"];
    }
    if (self.appName.length > 0) {
        [dic setObject:self.appName forKey:@"appName"];
    }
    if (self.latitude != 0) {
        [dic setObject:@(self.latitude) forKey:@"latitude"];
    }
    if (self.longitude != 0) {
        [dic setObject:@(self.longitude) forKey:@"longitude"];
    }
    if (self.idfa.length > 0) {
        [dic setObject:self.idfa forKey:@"idfa"];
    }
    if (self.idfv.length > 0) {
        [dic setObject:self.idfv forKey:@"idfv"];
    }
    if (self.orientation.length > 0) {
        [dic setObject:self.orientation forKey:@"orientation"];
    }
    if (self.userKey.length > 0) {
        [dic setObject:self.userKey forKey:@"userKey"];
    }
    if (self.timezoneOffset.length > 0) {
        [dic setObject:self.timezoneOffset forKey:@"timezoneOffset"];
    }

    return dic;
}

+ (nullable instancetype)growingHelper_parseFromJsonObject:(NSDictionary *)jsonObject {
    GrowingPBEventV3Dto *dto = [[GrowingPBEventV3Dto alloc] init];
    dto.dataSourceId = jsonObject[@"dataSourceId"];
    dto.sessionId = jsonObject[@"sessionId"];
    dto.timestamp = ((NSNumber *)jsonObject[@"timestamp"]).longLongValue;
    dto.eventType = [dto growingHelper_eventType:jsonObject[@"eventType"]];
    dto.domain = jsonObject[@"domain"];
    dto.userId = jsonObject[@"userId"];
    dto.deviceId = jsonObject[@"deviceId"];
    dto.platform = jsonObject[@"platform"];
    dto.platformVersion = jsonObject[@"platformVersion"];
    dto.eventSequenceId = ((NSNumber *)jsonObject[@"eventSequenceId"]).intValue;
    dto.appState = jsonObject[@"appState"];
    dto.URLScheme = jsonObject[@"urlScheme"];
    dto.networkState = jsonObject[@"networkState"];
    dto.screenWidth = ((NSNumber *)jsonObject[@"screenWidth"]).intValue;
    dto.screenHeight = ((NSNumber *)jsonObject[@"screenHeight"]).intValue;
    dto.deviceBrand = jsonObject[@"deviceBrand"];
    dto.deviceModel = jsonObject[@"deviceModel"];
    dto.deviceType = jsonObject[@"deviceType"];
    dto.appName = jsonObject[@"appName"];
    dto.appVersion = jsonObject[@"appVersion"];
    dto.language = jsonObject[@"language"];
    dto.latitude = ((NSNumber *)jsonObject[@"latitude"]).doubleValue;
    dto.longitude = ((NSNumber *)jsonObject[@"longitude"]).doubleValue;
    dto.sdkVersion = jsonObject[@"sdkVersion"];
    dto.userKey = jsonObject[@"userKey"];
    dto.idfa = jsonObject[@"idfa"];
    dto.idfv = jsonObject[@"idfv"];
    dto.extraSdk = jsonObject[@"extraSdk"];
    dto.path = jsonObject[@"path"];
    dto.textValue = jsonObject[@"textValue"];
    dto.xpath = jsonObject[@"xpath"];
    dto.xcontent = jsonObject[@"xcontent"];
    int index = ((NSNumber *)jsonObject[@"index"]).intValue;
    if (index > 0) {
        dto.index = index;
    }
    dto.query = jsonObject[@"query"];
    dto.hyperlink = jsonObject[@"hyperlink"];
    dto.attributes = jsonObject[@"attributes"];
    dto.orientation = jsonObject[@"orientation"];
    dto.title = jsonObject[@"title"];
    dto.referralPage = jsonObject[@"referralPage"];
    dto.protocolType = jsonObject[@"protocolType"];
    dto.eventName = jsonObject[@"eventName"];
    dto.timezoneOffset = jsonObject[@"timezoneOffset"];

    return dto;
}

- (NSMutableDictionary<NSString *, NSString *> *)growingHelper_safeMap:(NSDictionary *)originMap {
    NSMutableDictionary<NSString *, NSString *> *map = originMap.mutableCopy;
    for (NSString *key in map.allKeys) {
        if ([map[key] isKindOfClass:[NSNull class]]) {
            // NSNull will crash
            map[key] = nil;
        }
    }

    return map;
}

- (GrowingPBEventType)growingHelper_eventType:(NSString *)eventType {
    if ([eventType isEqualToString:@"VISIT"]) {
        return GrowingPBEventType_Visit;
    } else if ([eventType isEqualToString:@"CUSTOM"]) {
        return GrowingPBEventType_Custom;
    } else if ([eventType isEqualToString:@"LOGIN_USER_ATTRIBUTES"]) {
        return GrowingPBEventType_LoginUserAttributes;
    } else if ([eventType isEqualToString:@"APP_CLOSED"]) {
        return GrowingPBEventType_AppClosed;
    } else if ([eventType isEqualToString:@"PAGE"]) {
        return GrowingPBEventType_Page;
    } else if ([eventType isEqualToString:@"VIEW_CLICK"]) {
        return GrowingPBEventType_ViewClick;
    } else if ([eventType isEqualToString:@"VIEW_CHANGE"]) {
        return GrowingPBEventType_ViewChange;
    } else if ([eventType isEqualToString:@"FORM_SUBMIT"]) {
        return GrowingPBEventType_FormSubmit;
    } else if ([eventType isEqualToString:@"ACTIVATE"]) {
        return GrowingPBEventType_Activate;
    } else if ([eventType isEqualToString:@"PAGE_ATTRIBUTES"] /* Deprecated */) {
        return GrowingPBEventType_PageAttributes;
    }

    return GrowingPBEventType_GPBUnrecognizedEnumeratorValue;
}

@end
