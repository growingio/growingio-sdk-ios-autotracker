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
#import "GrowingEventProtobufPersistence.h"
#import "GrowingEvent.pbobjc.h"
#import "GrowingVisitEvent.h"
#import "GrowingCustomEvent.h"
#import "GrowingPageCustomEvent.h"
#import "GrowingHybridCustomEvent.h"
#import "GrowingVisitorAttributesEvent.h"
#import "GrowingLoginUserAttributesEvent.h"
#import "GrowingConversionVariableEvent.h"
#import "GrowingAppCloseEvent.h"
#import "GrowingPageEvent.h"
#import "GrowingHybridPageEvent.h"
#import "GrowingPageAttributesEvent.h"
#import "GrowingHybridPageAttributesEvent.h"
#import "GrowingViewElementEvent.h"
#import "GrowingHybridViewElementEvent.h"
#import "GrowingHybridEventType.h"

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
        GrowingVisitEvent *event = (GrowingVisitEvent *)(GrowingVisitEvent.builder
                                                         .setIdfa(@"idfa")
                                                         .setIdfv(@"idfv")
                                                         .setExtraSdk(@{@"key": @"value"})
                                                         .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeVisit, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Visit, protobuf.eventType);
        XCTAssertEqualObjects(event.idfa ?: @"", protobuf.idfa);
        XCTAssertEqualObjects(event.idfv ?: @"", protobuf.idfv);
        XCTAssertEqualObjects(event.extraSdk ?: @{}, protobuf.extraSdk);
    }
    {
        GrowingVisitEvent *event = (GrowingVisitEvent *)(GrowingVisitEvent.builder.build);
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
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(GrowingHybridViewElementEvent.builder
                                                                                 .setEventType(GrowingEventTypeVisit)
                                                                                 .setPath(@"path")
                                                                                 .setPageShowTimestamp(1638857558209)
                                                                                 .setXpath(@"xpath")
                                                                                 .setIndex(1)
                                                                                 .setQuery(@"query")
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeVisit, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Visit, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (void)testEventConvertToPB_Custom {
    // GrowingCustomEvent
    {
        GrowingCustomEvent *event = (GrowingCustomEvent *)(GrowingCustomEvent.builder
                                                           .setEventName(@"custom")
                                                           .setAttributes(@{@"key": @"value"})
                                                           .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingCustomEvent *event = (GrowingCustomEvent *)(GrowingCustomEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }

    // GrowingPageCustomEvent
    {
        GrowingPageCustomEvent *event = (GrowingPageCustomEvent *)(GrowingPageCustomEvent.builder
                                                                   .setEventName(@"custom")
                                                                   .setPath(@"path")
                                                                   .setPageShowTimestamp(1638857558209)
                                                                   .setAttributes(@{@"key": @"value"})
                                                                   .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingPageCustomEvent *event = (GrowingPageCustomEvent *)(GrowingPageCustomEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }

    // GrowingHybridCustomEvent
    {
        GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)(GrowingHybridCustomEvent.builder
                                                                       .setEventName(@"custom")
                                                                       .setPath(@"path")
                                                                       .setPageShowTimestamp(1638857558209)
                                                                       .setAttributes(@{@"key": @"value"})
                                                                       .setQuery(@"query")
                                                                       .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingHybridCustomEvent *event = (GrowingHybridCustomEvent *)(GrowingHybridCustomEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeCustom, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Custom, protobuf.eventType);
        XCTAssertEqualObjects(event.eventName ?: @"", protobuf.eventName);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (void)testEventConvertToPB_VisitorAttributes {
    // GrowingVisitorAttributesEvent
    {
        GrowingVisitorAttributesEvent *event = (GrowingVisitorAttributesEvent *)(GrowingVisitorAttributesEvent.builder
                                                                                 .setAttributes(@{@"key": @"value"})
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeVisitorAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_VisitorAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingVisitorAttributesEvent *event = (GrowingVisitorAttributesEvent *)(GrowingVisitorAttributesEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeVisitorAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_VisitorAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
}

- (void)testEventConvertToPB_LoginUserAttributes {
    // GrowingLoginUserAttributesEvent
    {
        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)(GrowingLoginUserAttributesEvent.builder
                                                                                     .setAttributes(@{@"key": @"value"})
                                                                                     .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeLoginUserAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_LoginUserAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingLoginUserAttributesEvent *event = (GrowingLoginUserAttributesEvent *)(GrowingLoginUserAttributesEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeLoginUserAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_LoginUserAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
}

- (void)testEventConvertToPB_ConversionVariable {
    // GrowingConversionVariableEvent
    {
        GrowingConversionVariableEvent *event = (GrowingConversionVariableEvent *)(GrowingConversionVariableEvent.builder
                                                                                   .setAttributes(@{@"key": @"value"})
                                                                                   .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeConversionVariables, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ConversionVariables, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingConversionVariableEvent *event = (GrowingConversionVariableEvent *)(GrowingConversionVariableEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeConversionVariables, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ConversionVariables, protobuf.eventType);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
}

- (void)testEventConvertToPB_AppClose {
    // GrowingAppCloseEvent
    {
        GrowingAppCloseEvent *event = (GrowingAppCloseEvent *)(GrowingAppCloseEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        XCTAssertEqualObjects(GrowingEventTypeAppClosed, event.eventType);
        XCTAssertEqual(GrowingPBEventType_AppClosed, protobuf.eventType);
        [self contrastOfDefaultParamter:event protobuf:protobuf];
    }
}

- (void)testEventConvertToPB_Page {
    // GrowingPageEvent
    {
        GrowingPageEvent *event = (GrowingPageEvent *)(GrowingPageEvent.builder
                                                       .setPath(@"path")
                                                       .setOrientation(@"PORTRAIT")
                                                       .setTitle(@"title")
                                                       .setReferralPage(@"referralPage")
                                                       .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.pageName ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
    }
    {
        GrowingPageEvent *event = (GrowingPageEvent *)(GrowingPageEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.pageName ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
    }

    // GrowingHybridPageEvent
    {
        GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)(GrowingHybridPageEvent.builder
                                                                   .setPath(@"path")
                                                                   .setOrientation(@"PORTRAIT")
                                                                   .setTitle(@"title")
                                                                   .setReferralPage(@"referralPage")
                                                                   .setQuery(@"query")
                                                                   .setProtocolType(@"https")
                                                                   .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.pageName ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
        XCTAssertEqualObjects(event.protocolType ?: @"", protobuf.protocolType);
    }
    {
        GrowingHybridPageEvent *event = (GrowingHybridPageEvent *)(GrowingHybridPageEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePage, event.eventType);
        XCTAssertEqual(GrowingPBEventType_Page, protobuf.eventType);
        XCTAssertEqualObjects(event.pageName ?: @"", protobuf.path);
        XCTAssertEqualObjects(event.orientation ?: @"", protobuf.orientation);
        XCTAssertEqualObjects(event.title ?: @"", protobuf.title);
        XCTAssertEqualObjects(event.referralPage ?: @"", protobuf.referralPage);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
        XCTAssertEqualObjects(event.protocolType ?: @"", protobuf.protocolType);
    }
}

- (void)testEventConvertToPB_PageAttributes {
    // GrowingPageAttributesEvent
    {
        GrowingPageAttributesEvent *event = (GrowingPageAttributesEvent *)(GrowingPageAttributesEvent.builder
                                                                           .setPath(@"path")
                                                                           .setPageShowTimestamp(1638857558209)
                                                                           .setAttributes(@{@"key": @"value"})
                                                                           .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePageAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_PageAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }
    {
        GrowingPageAttributesEvent *event = (GrowingPageAttributesEvent *)(GrowingPageAttributesEvent.builder.build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePageAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_PageAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
    }

    // GrowingHybridPageAttributesEvent
    {
        GrowingHybridPageAttributesEvent *event = (GrowingHybridPageAttributesEvent *)(GrowingHybridPageAttributesEvent.builder
                                                                                       .setQuery(@"query")
                                                                                       .setPath(@"path")
                                                                                       .setPageShowTimestamp(1638857558209)
                                                                                       .setAttributes(@{@"key": @"value"})
                                                                                       .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePageAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_PageAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingHybridPageAttributesEvent *event = (GrowingHybridPageAttributesEvent *)(GrowingHybridPageAttributesEvent.builder
                                                                                       .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypePageAttributes, event.eventType);
        XCTAssertEqual(GrowingPBEventType_PageAttributes, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.attributes ?: @{}, protobuf.attributes);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (void)testEventConvertToPB_ViewClick {
    // GrowingViewElementEvent
    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(GrowingViewElementEvent.builder
                                                                     .setEventType(GrowingEventTypeViewClick)
                                                                     .setPath(@"path")
                                                                     .setPageShowTimestamp(1638857558209)
                                                                     .setTextValue(@"textvalue")
                                                                     .setXpath(@"xpath")
                                                                     .setIndex(1)
                                                                     .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }
    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(GrowingViewElementEvent.builder
                                                                     .setEventType(GrowingEventTypeViewClick)
                                                                     .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }

    // GrowingHybridViewElementEvent
    {
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(GrowingHybridViewElementEvent.builder
                                                                                 .setEventType(GrowingEventTypeViewClick)
                                                                                 .setPath(@"path")
                                                                                 .setPageShowTimestamp(1638857558209)
                                                                                 .setTextValue(@"textvalue")
                                                                                 .setXpath(@"xpath")
                                                                                 .setIndex(1)
                                                                                 .setHyperlink(@"hyperlink")
                                                                                 .setQuery(@"query")
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.hyperlink ?: @"", protobuf.hyperlink);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(GrowingHybridViewElementEvent.builder
                                                                                 .setEventType(GrowingEventTypeViewClick)
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewClick, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewClick, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
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
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(GrowingViewElementEvent.builder
                                                                     .setEventType(GrowingEventTypeViewChange)
                                                                     .setPath(@"path")
                                                                     .setPageShowTimestamp(1638857558209)
                                                                     .setTextValue(@"textvalue")
                                                                     .setXpath(@"xpath")
                                                                     .setIndex(1)
                                                                     .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }
    {
        GrowingViewElementEvent *event = (GrowingViewElementEvent *)(GrowingViewElementEvent.builder
                                                                     .setEventType(GrowingEventTypeViewChange)
                                                                     .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
    }

    // GrowingHybridViewElementEvent
    {
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(GrowingHybridViewElementEvent.builder
                                                                                 .setEventType(GrowingEventTypeViewChange)
                                                                                 .setPath(@"path")
                                                                                 .setPageShowTimestamp(1638857558209)
                                                                                 .setTextValue(@"textvalue")
                                                                                 .setXpath(@"xpath")
                                                                                 .setIndex(1)
                                                                                 .setHyperlink(@"hyperlink")
                                                                                 .setQuery(@"query")
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.hyperlink ?: @"", protobuf.hyperlink);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(GrowingHybridViewElementEvent.builder
                                                                                 .setEventType(GrowingEventTypeViewChange)
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeViewChange, event.eventType);
        XCTAssertEqual(GrowingPBEventType_ViewChange, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.textValue ?: @"", protobuf.textValue);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.hyperlink ?: @"", protobuf.hyperlink);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (void)testEventConvertToPB_FormSubmit {
    // GrowingHybridViewElementEvent
    {
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(GrowingHybridViewElementEvent.builder
                                                                                 .setEventType(GrowingEventTypeFormSubmit)
                                                                                 .setPath(@"path")
                                                                                 .setPageShowTimestamp(1638857558209)
                                                                                 .setXpath(@"xpath")
                                                                                 .setIndex(1)
                                                                                 .setQuery(@"query")
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeFormSubmit, event.eventType);
        XCTAssertEqual(GrowingPBEventType_FormSubmit, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
    {
        GrowingHybridViewElementEvent *event = (GrowingHybridViewElementEvent *)(GrowingHybridViewElementEvent.builder
                                                                                 .setEventType(GrowingEventTypeFormSubmit)
                                                                                 .build);
        GrowingPBEventV3Dto *protobuf = [self protobufFromEvent:event];
        [self contrastOfDefaultParamter:event protobuf:protobuf];
        XCTAssertEqualObjects(GrowingEventTypeFormSubmit, event.eventType);
        XCTAssertEqual(GrowingPBEventType_FormSubmit, protobuf.eventType);
        XCTAssertEqualObjects(event.path ?: @"", protobuf.path);
        XCTAssertEqual(event.pageShowTimestamp, protobuf.pageShowTimestamp);
        XCTAssertEqualObjects(event.xpath ?: @"", protobuf.xpath);
        XCTAssertEqual(event.index, protobuf.index);
        XCTAssertEqualObjects(event.query ?: @"", protobuf.query);
    }
}

- (GrowingPBEventV3Dto *)protobufFromEvent:(GrowingBaseEvent *)event {
    GrowingEventProtobufPersistence *p = [GrowingEventProtobufPersistence persistenceEventWithEvent:event
                                                                                               uuid:[NSUUID UUID].UUIDString];
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
    XCTAssertEqualObjects((event.appState == GrowingAppStateForeground ? @"FOREGROUND" : @"BACKGROUND"), protobuf.appState);
    XCTAssertEqual(event.globalSequenceId, protobuf.globalSequenceId);
    XCTAssertEqual(event.eventSequenceId, protobuf.eventSequenceId);
    XCTAssertEqualObjects(event.extraParams[@"dataSourceId"] ?: @"", protobuf.dataSourceId);
    XCTAssertEqualObjects(event.extraParams[@"gioId"] ?: @"", protobuf.gioId);
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
}

@end
