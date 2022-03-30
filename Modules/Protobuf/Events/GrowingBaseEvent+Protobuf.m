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

#import "Modules/Protobuf/Events/GrowingBaseEvent+Protobuf.h"
#import "Modules/Protobuf/Proto/GrowingEvent.pbobjc.h"

@implementation GrowingBaseEvent (Protobuf)

- (GrowingPBEventV3Dto *)toProtobuf {
    GrowingPBEventV3Dto *dto = [[GrowingPBEventV3Dto alloc] init];
    
    // ************************* CDP *************************
    if (self.extraParams.count > 0) {
        dto.dataSourceId = self.extraParams[@"dataSourceId"];
        dto.gioId = self.extraParams[@"gioId"];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self isKindOfClass:NSClassFromString(@"GrowingResourceCustomEvent")]
        && [self respondsToSelector:@selector(resourceItem)]) {
        id resourceItem = [self performSelector:@selector(resourceItem)];
        if (resourceItem) {
            NSString *itemId;
            NSString *itemKey;
            SEL itemIdSel = NSSelectorFromString(@"itemId");
            SEL itemKeySel = NSSelectorFromString(@"itemKey");
            if ([resourceItem respondsToSelector:itemIdSel]) {
                itemId = [resourceItem performSelector:itemIdSel];
            }
            if ([resourceItem respondsToSelector:itemKeySel]) {
                itemKey = [resourceItem performSelector:itemKeySel];
            }
            
            GrowingPBResourceItem *pbResourceItem = [[GrowingPBResourceItem alloc] init];
            pbResourceItem.id_p = itemId;
            pbResourceItem.key = itemKey;
            dto.resourceItem = pbResourceItem;
        }
    }
#pragma clang diagnostic pop
    // ************************* CDP *************************
    
    dto.sessionId = self.sessionId;
    dto.timestamp = self.timestamp;
    dto.eventType = self.pbEventType;
    dto.domain = self.domain;
    dto.userId = self.userId;
    dto.deviceId = self.deviceId;
    dto.platform = self.platform;
    dto.platformVersion = self.platformVersion;
    dto.globalSequenceId = self.globalSequenceId;
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
    return dto;
}

- (GrowingPBEventType)pbEventType {
    NSString *reason = [NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

@end
