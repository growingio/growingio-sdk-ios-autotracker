//
//  ProtobufEventsTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/6.
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

#import <XCTest/XCTest.h>
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingTrackerCore/Event/GrowingAppCloseEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingLoginUserAttributesEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridCustomEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridEventType.h"
#import "Modules/Hybrid/Events/GrowingHybridPageEvent.h"
#import "Modules/Hybrid/Events/GrowingHybridViewElementEvent.h"
#import "Services/Protobuf/GrowingEventProtobufPersistence.h"
#import "Services/Protobuf/Proto/GrowingEvent.pbobjc.h"

@interface ProtobufEventsTest : XCTestCase

@end

@implementation ProtobufEventsTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEventConvertToPB_Visit {
    // GrowingVisitEvent
    {
        GrowingBaseBuilder *builder = GrowingVisitEvent.builder.setIdfa(@"idfa").setIdfv(@"idfv").setExtraSdk(@{@"key": @"value"});
        [builder readPropertyInTrackThread];
        GrowingVisitEvent *event = (GrowingVisitEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeVisit, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Visit, protobuf.eventType);
        XCTAssertEqualObjects(event.idfa ?: @"", protobuf.idfa);
        XCTAssertEqualObjects(event.idfv ?: @"", protobuf.idfv);
        XCTAssertEqualObjects(event.extraSdk ?: @{}, protobuf.extraSdk);
    }
    {
        GrowingBaseBuilder *builder = GrowingVisitEvent.builder;
        [builder readPropertyInTrackThread];
        GrowingVisitEvent *event = (GrowingVisitEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeVisit, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Visit, protobuf.eventType);
        XCTAssertEqualObjects(event.idfa ?: @"", protobuf.idfa);
        XCTAssertEqualObjects(event.idfv ?: @"", protobuf.idfv);
        XCTAssertEqualObjects(event.extraSdk ?: @{}, protobuf.extraSdk);
    }

    // GrowingHybridViewElementEvent - Useless
    {
        GrowingBaseBuilder *builder = GrowingHybridViewElementEvent.builder.setEventType(GrowingEventTypeVisit)
            .setPath(@"path")
            .setXpath(@"xpath")
            .setIndex(1)
            .setQuery(@"query");
        [builder readPropertyInTrackThread];
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeVisit, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Visit, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (void)testEventConvertToPB_Custom {
    // GrowingCustomEvent
    {
        GrowingBaseBuilder *builder = GrowingCustomEvent.builder.setEventName(@"custom")
            .setPath(@"path")
            .setAttributes(@{@"key": @"value"});
        [builder readPropertyInTrackThread];
        GrowingCustomEvent *event = (GrowingCustomEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingBaseBuilder *builder = GrowingCustomEvent.builder;
        [builder readPropertyInTrackThread];
        GrowingCustomEvent *event = (GrowingCustomEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }

    // GrowingHybridCustomEvent
    {
        GrowingBaseBuilder *builder = GrowingHybridCustomEvent.builder.setEventName(@"custom")
            .setPath(@"path")
            .setAttributes(@{@"key": @"value"})
            .setQuery(@"query");
        [builder readPropertyInTrackThread];
        GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingBaseBuilder *builder = GrowingHybridCustomEvent.builder;
        [builder readPropertyInTrackThread];
        GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (void)testEventConvertToPB_LoginUserAttributes {
    // GrowingLoginUserAttributesEvent
    {
        GrowingBaseBuilder *builder = GrowingLoginUserAttributesEvent.builder.setAttributes(@{@"key": @"value"});
        [builder readPropertyInTrackThread];
        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeLoginUserAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_LoginUserAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingBaseBuilder *builder = GrowingLoginUserAttributesEvent.builder;
        [builder readPropertyInTrackThread];
        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeLoginUserAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_LoginUserAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
}

- (void)testEventConvertToPB_AppClose {
    // GrowingAppCloseEvent
    {
        GrowingBaseBuilder *builder = GrowingAppCloseEvent.builder;
        [builder readPropertyInTrackThread];
        GrowingAppCloseEvent *event = (GrowingAppCloseEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        XCTAssertEqualObjects(GrowingEventTypeAppClosed, event.eventType);
        XCTAssertEqual(GrowingPBEventType_AppClosed, protobuf.eventType);
        [self contrastOfDefaultParamter:event protobuf:protobuf];
    }
}

- (void)testEventConvertToPB_Page {
    // GrowingPageEvent
    {
        GrowingBaseBuilder *builder = GrowingPageEvent.builder.setPath(@"path")
            .setOrientation(@"PORTRAIT")
            .setTitle(@"title")
            .setReferralPage(@"referralPage")
            .setAttributes(@{@"key": @"value"});
        [builder readPropertyInTrackThread];
        GrowingPageEvent *event = (GrowingPageEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingBaseBuilder *builder = GrowingPageEvent.builder;
        [builder readPropertyInTrackThread];
        GrowingPageEvent *event = (GrowingPageEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }

    // GrowingHybridPageEvent
    {
        GrowingBaseBuilder *builder = GrowingHybridPageEvent.builder.setPath(@"path")
            .setOrientation(@"PORTRAIT")
            .setTitle(@"title")
            .setReferralPage(@"referralPage")
            .setQuery(@"query")
            .setProtocolType(@"https")
            .setAttributes(@{@"key": @"value"});
        [builder readPropertyInTrackThread];
        GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
        XCTAssertEqualObjects(event.protocolType ?: @"", protobuf.protocolType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingBaseBuilder *builder = GrowingHybridPageEvent.builder;
        [builder readPropertyInTrackThread];
        GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
        XCTAssertEqualObjects(event.protocolType ?: @"", protobuf.protocolType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
}

- (void)testEventConvertToPB_ViewClick {
    // GrowingViewElementEvent
    {
        GrowingBaseBuilder *builder = GrowingViewElementEvent.builder.setEventType(GrowingEventTypeViewClick)
            .setPath(@"path")
            .setTextValue(@"textvalue")
            .setXpath(@"xpath")
            .setIndex(1);
        [builder readPropertyInTrackThread];
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }
    {
        GrowingBaseBuilder *builder = GrowingViewElementEvent.builder.setEventType(GrowingEventTypeViewClick);
        [builder readPropertyInTrackThread];
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }

    // GrowingHybridViewElementEvent
    {
        GrowingBaseBuilder *builder = GrowingHybridViewElementEvent.builder
            .setEventType(GrowingEventTypeViewClick)
            .setPath(@"path")
            .setTextValue(@"textvalue")
            .setXpath(@"xpath")
            .setIndex(1)
            .setHyperlink(@"hyperlink")
            .setQuery(@"query");
        [builder readPropertyInTrackThread];
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.hyperlink ?: @"", protobuf.hyperlink);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingBaseBuilder *builder = GrowingHybridViewElementEvent.builder.setEventType(GrowingEventTypeViewClick);
        [builder readPropertyInTrackThread];
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.hyperlink ?: @"", protobuf.hyperlink);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (void)testEventConvertToPB_ViewChange {
    // GrowingViewElementEvent
    {
        GrowingBaseBuilder *builder = GrowingViewElementEvent.builder.setEventType(GrowingEventTypeViewChange)
            .setPath(@"path")
            .setTextValue(@"textvalue")
            .setXpath(@"xpath")
            .setIndex(1);
        [builder readPropertyInTrackThread];
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }
    {
        GrowingBaseBuilder *builder = GrowingViewElementEvent.builder.setEventType(GrowingEventTypeViewChange);
        [builder readPropertyInTrackThread];
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }

    // GrowingHybridViewElementEvent
    {
        GrowingBaseBuilder *builder = GrowingHybridViewElementEvent.builder
            .setEventType(GrowingEventTypeViewChange)
            .setPath(@"path")
            .setTextValue(@"textvalue")
            .setXpath(@"xpath")
            .setIndex(1)
            .setHyperlink(@"hyperlink")
            .setQuery(@"query");
        [builder readPropertyInTrackThread];
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.hyperlink ?: @"", protobuf.hyperlink);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingBaseBuilder *builder = GrowingHybridViewElementEvent.builder.setEventType(GrowingEventTypeViewChange);
        [builder readPropertyInTrackThread];
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.hyperlink ?: @"", protobuf.hyperlink);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (GrowingPBEventV3Dto *)protobufFromEvent:(GrowingBaseEvent *)event {
    GrowingEventProtobufPersistence *p =
        [GrowingEventProtobufPersistence persistenceEventWithEvent:event uuid:[NSUUID UUID].UUIDString];
    return [GrowingPBEventV3Dto parseFromData:p.data error:nil];
}

- (void)contrastOfDefaultParamter:(GrowingBaseEvent *)event protobuf:(GrowingPBEventV3Dto *)protobuf {
    XCTAssertEqualObjects(event.platform ?: @"", protobuf.platform);
    XCTAssertEqualObjects(event.platformVersion ?: @"", protobuf.platformVersion);
    XCTAssertEqualObjects(event.deviceId ?: @"", protobuf.deviceId);
    XCTAssertEqualObjects(event.userId ?: @"", protobuf.userId);
    XCTAssertEqualObjects(event.sessionId ?: @"", protobuf.sessionId);
    XCTAssertEqual(event.timestamp, protobuf.timestamp);
    XCTAssertEqualObjects(event.domain ?: @"", protobuf.domain);
    XCTAssertEqualObjects(event.urlScheme ?: @"", protobuf.URLScheme);
    XCTAssertEqualObjects((event.appState == GrowingAppStateForeground ? @"FOREGROUND" : @"BACKGROUND"),
                          protobuf.appState);
    XCTAssertEqual(event.eventSequenceId, protobuf.eventSequenceId);
    // 3.2.0
    XCTAssertEqualObjects(event.networkState ?: @"", protobuf.networkState);
    XCTAssertEqualObjects(event.appChannel ?: @"", protobuf.appChannel);
    XCTAssertEqual(event.screenHeight, protobuf.screenHeight);
    XCTAssertEqual(event.screenWidth, protobuf.screenWidth);
    XCTAssertEqualObjects(event.deviceBrand ?: @"", protobuf.deviceBrand);
    XCTAssertEqualObjects(event.deviceModel ?: @"", protobuf.deviceModel);
    XCTAssertEqualObjects(event.deviceType ?: @"", protobuf.deviceType);
    XCTAssertEqualObjects(event.appVersion ?: @"", protobuf.appVersion);
    XCTAssertEqualObjects(event.appName ?: @"", protobuf.appName);
    XCTAssertEqualObjects(event.language ?: @"", protobuf.language);
    XCTAssertEqual(event.latitude, protobuf.latitude);
    XCTAssertEqual(event.longitude, protobuf.longitude);
    XCTAssertEqualObjects(event.sdkVersion ?: @"", protobuf.sdkVersion);
    // 3.3.0
    XCTAssertEqualObjects(event.userKey ?: @"", protobuf.userKey);
    // 4.0.0
    XCTAssertEqualObjects(event.timezoneOffset ?: @"", protobuf.timezoneOffset);
}

@end
