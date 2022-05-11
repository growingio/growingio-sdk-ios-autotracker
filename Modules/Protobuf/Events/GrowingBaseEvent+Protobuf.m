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
#import "GrowingTrackerCore/Event/GrowingAppCloseEvent.h"
#import "GrowingTrackerCore/Event/GrowingBaseAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingConversionVariableEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageAttributesEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageCustomEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitorAttributesEvent.h"
#import "Modules/Protobuf/Proto/GrowingEvent.pbobjc.h"
#import "Modules/Protobuf/GrowingPBEventV3Dto+GrowingHelper.h"

#if __has_include("Modules/Hybrid/GrowingHybridModule.h")
#import "Modules/Hybrid/Events/GrowingHybridCustomEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridPageAttributesEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridPageEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridViewElementEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridEventType.h"
#define GROWING_ANALYSIS_HYBRID
#endif

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
    
    if ([self isKindOfClass:GrowingPageEvent.class]) {
       GrowingPageEvent *event = (GrowingPageEvent *)self;
       dto.path = event.pageName;
       dto.orientation = event.orientation;
       dto.title = event.title;
       dto.referralPage = event.referralPage;
       
#ifdef GROWING_ANALYSIS_HYBRID
       if ([self isKindOfClass:GrowingHybridPageEvent.class]) {
           GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)self;
           dto.query = event.query;
           dto.protocolType = event.protocolType;
       }
#endif
    } else if ([self isKindOfClass:GrowingVisitEvent.class]) {
        GrowingVisitEvent *event = (GrowingVisitEvent *)self;
        dto.idfa = event.idfa;
        dto.idfv = event.idfv;
        dto.extraSdk = [dto growingHelper_safeMap:event.extraSdk];
    } else if ([self isKindOfClass:GrowingViewElementEvent.class]) {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)self;
        dto.path = event.path;
        dto.pageShowTimestamp = event.pageShowTimestamp;
        dto.textValue = event.textValue;
        dto.xpath = event.xpath;
        dto.index = event.index;
        
#ifdef GROWING_ANALYSIS_HYBRID
        if ([self isKindOfClass:GrowingHybridViewElementEvent.class]) {
            GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)self;
            dto.query = event.query;
            dto.hyperlink = event.hyperlink;
        }
#endif
    } else if ([self isKindOfClass:GrowingConversionVariableEvent.class]) {
        GrowingConversionVariableEvent *event = (GrowingConversionVariableEvent *)self;
        dto.attributes = [dto growingHelper_safeMap:event.attributes];
    } else if ([self isKindOfClass:GrowingBaseAttributesEvent.class]) {
        GrowingBaseAttributesEvent *event = (GrowingBaseAttributesEvent *)self;
        dto.attributes = [dto growingHelper_safeMap:event.attributes];
        
        if ([self isKindOfClass:GrowingPageAttributesEvent.class]) {
            GrowingPageAttributesEvent *event = (GrowingPageAttributesEvent *)self;
            dto.path = event.path;
            dto.pageShowTimestamp = event.pageShowTimestamp;
            
#ifdef GROWING_ANALYSIS_HYBRID
            if ([self isKindOfClass:GrowingHybridPageAttributesEvent.class]) {
                GrowingHybridPageAttributesEvent *event = (GrowingHybridPageAttributesEvent *)self;
                dto.query = event.query;
            }
#endif
        } else if ([self isKindOfClass:GrowingCustomEvent.class]) {
            GrowingCustomEvent *event = (GrowingCustomEvent *)self;
            dto.eventName = event.eventName;
            
            if ([self isKindOfClass:GrowingPageCustomEvent.class]) {
                GrowingPageCustomEvent *event = (GrowingPageCustomEvent *)self;
                dto.path = event.path;
                dto.pageShowTimestamp = event.pageShowTimestamp;
                
#ifdef GROWING_ANALYSIS_HYBRID
                if ([self isKindOfClass:GrowingHybridCustomEvent.class]) {
                    GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)self;
                    dto.query = event.query;
                }
#endif
            }
        }
    }
    return dto;
}

- (GrowingPBEventType)pbEventType {
    if ([self isKindOfClass:GrowingPageEvent.class]) {
        return GrowingPBEventType_Page;
    } else if ([self isKindOfClass:GrowingVisitEvent.class]) {
        return GrowingPBEventType_Visit;
    } else if ([self isKindOfClass:GrowingViewElementEvent.class]) {
#ifdef GROWING_ANALYSIS_HYBRID
        if ([self isKindOfClass:GrowingHybridViewElementEvent.class]) {
            if ([self.eventType isEqualToString:GrowingEventTypeVisit]) {
                return GrowingPBEventType_Visit;
            } else if ([self.eventType isEqualToString:GrowingEventTypeViewClick]) {
                return GrowingPBEventType_ViewClick;
            } else if ([self.eventType isEqualToString:GrowingEventTypeViewChange]) {
                return GrowingPBEventType_ViewChange;
            } else if ([self.eventType isEqualToString:GrowingEventTypeFormSubmit]) {
                return GrowingPBEventType_FormSubmit;
            }
        }
#endif
        if ([self.eventType isEqualToString:GrowingEventTypeViewClick]) {
            return GrowingPBEventType_ViewClick;
        } else if ([self.eventType isEqualToString:GrowingEventTypeViewChange]) {
            return GrowingPBEventType_ViewChange;
        }
    } else if ([self isKindOfClass:GrowingAppCloseEvent.class]) {
        return GrowingPBEventType_AppClosed;
    } else if ([self isKindOfClass:GrowingConversionVariableEvent.class]) {
        return GrowingPBEventType_ConversionVariables;
    } else if ([self isKindOfClass:GrowingBaseAttributesEvent.class]) {
        if ([self isKindOfClass:GrowingPageAttributesEvent.class]) {
            return GrowingPBEventType_PageAttributes;
        } else if ([self isKindOfClass:GrowingVisitorAttributesEvent.class]) {
            return GrowingPBEventType_VisitorAttributes;
        } else if ([self isKindOfClass:GrowingLoginUserAttributesEvent.class]) {
            return GrowingPBEventType_LoginUserAttributes;
        } else if ([self isKindOfClass:GrowingCustomEvent.class]) {
            return GrowingPBEventType_Custom;
        }
    }
    
    return GrowingPBEventType_GPBUnrecognizedEnumeratorValue;
}

@end
