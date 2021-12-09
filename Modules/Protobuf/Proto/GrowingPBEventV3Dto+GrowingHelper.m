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


#import "GrowingPBEventV3Dto+GrowingHelper.h"
#import "GrowingTrackEventType.h"
#import "GrowingAutotrackEventType.h"
#ifdef GROWING_ANALYSIS_HYBRID
#import "GrowingHybridEventType.h"
#endif

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
    if (self.gioId.length > 0) {
        [dic setObject:self.gioId forKey:@"gioId"];
    }
    if (self.sessionId.length > 0) {
        [dic setObject:self.sessionId forKey:@"sessionId"];
    }
    if (self.dataSourceId.length > 0) {
        [dic setObject:self.dataSourceId forKey:@"dataSourceId"];
    }
    switch (self.eventType) {
        case GrowingPBEventType_Visit: {
            [dic setObject:GrowingEventTypeVisit forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_Custom: {
            [dic setObject:GrowingEventTypeCustom forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_VisitorAttributes: {
            [dic setObject:GrowingEventTypeVisitorAttributes forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_LoginUserAttributes: {
            [dic setObject:GrowingEventTypeLoginUserAttributes forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_ConversionVariables: {
            [dic setObject:GrowingEventTypeConversionVariables forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_AppClosed: {
            [dic setObject:GrowingEventTypeAppClosed forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_Page: {
            [dic setObject:GrowingEventTypePage forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_PageAttributes: {
            [dic setObject:GrowingEventTypePageAttributes forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_ViewClick: {
            [dic setObject:GrowingEventTypeViewClick forKey:@"eventType"];
        }
            break;
        case GrowingPBEventType_ViewChange: {
            [dic setObject:GrowingEventTypeViewChange forKey:@"eventType"];
        }
            break;
#ifdef GROWING_ANALYSIS_HYBRID
        case GrowingPBEventType_FormSubmit: {
            [dic setObject:GrowingEventTypeFormSubmit forKey:@"eventType"];
        }
            break;
#endif
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
    if (self.path.length > 0) {
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
    if (self.globalSequenceId > 0) {
        [dic setObject:@(self.globalSequenceId) forKey:@"globalSequenceId"];
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
    if (self.pageShowTimestamp > 0) {
        [dic setObject:@(self.pageShowTimestamp) forKey:@"pageShowTimestamp"];
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
    if (self.pageName.length > 0) {
        [dic setObject:self.pageName forKey:@"pageName"];
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
    if (self.operatingSystem.length > 0) {
        [dic setObject:self.operatingSystem forKey:@"operatingSystem"];
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
    
    return dic;
}

@end
