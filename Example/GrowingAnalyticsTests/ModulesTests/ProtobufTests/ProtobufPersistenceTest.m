//
//  ProtobufPersistenceTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2021/12/7.
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
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingVisitEvent.h"
#import "Services/Protobuf/Catagory/GrowingBaseEvent+Protobuf.h"
#import "Services/Protobuf/GrowingEventProtobufPersistence.h"
#import "Services/Protobuf/Proto/GrowingEvent.pbobjc.h"

@interface ProtobufPersistenceTest : XCTestCase

@property (nonatomic, strong) GrowingCustomEvent *event;

@end

@implementation ProtobufPersistenceTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.event = (GrowingCustomEvent
                      *)(GrowingCustomEvent.builder.setEventName(@"custom").setAttributes(@{@"key": @"value"}).build);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPersistenceInit {
    NSString *uuid = [NSUUID UUID].UUIDString;
    GrowingPBEventV3Dto *protobuf = self.event.toProtobuf;
    GrowingEventProtobufPersistence *p = [[GrowingEventProtobufPersistence alloc] initWithUUID:uuid
                                                                                     eventType:self.event.eventType
                                                                                          data:protobuf.data
                                                                                        policy:self.event.sendPolicy
                                                                                    sdkVersion:self.event.sdkVersion];
    XCTAssertNotNil(p);
    XCTAssertEqualObjects(p.eventUUID, uuid);
    XCTAssertEqualObjects(p.eventType, self.event.eventType);
    XCTAssertEqual(p.policy, self.event.sendPolicy);
    XCTAssertEqualObjects(p.data, protobuf.data);
}

- (void)testPersistenceWithEvent {
    NSString *uuid = [NSUUID UUID].UUIDString;
    GrowingEventProtobufPersistence *p = [GrowingEventProtobufPersistence persistenceEventWithEvent:self.event
                                                                                               uuid:uuid];
    XCTAssertNotNil(p);
    XCTAssertEqualObjects(p.eventUUID, uuid);
    XCTAssertEqualObjects(p.eventType, self.event.eventType);
    XCTAssertEqual(p.policy, self.event.sendPolicy);
    XCTAssertEqualObjects(p.data, self.event.toProtobuf.data);
}

- (void)testBuildRawEventsFromEvents {
    GrowingEventProtobufPersistence *p1 =
        [GrowingEventProtobufPersistence persistenceEventWithEvent:self.event uuid:[NSUUID UUID].UUIDString];
    GrowingEventProtobufPersistence *p2 =
        [GrowingEventProtobufPersistence persistenceEventWithEvent:self.event uuid:[NSUUID UUID].UUIDString];
    GrowingEventProtobufPersistence *p3 =
        [GrowingEventProtobufPersistence persistenceEventWithEvent:self.event uuid:[NSUUID UUID].UUIDString];
    NSData *data = [GrowingEventProtobufPersistence buildRawEventsFromEvents:@[p1, p2, p3]];
    XCTAssertNotNil(data);
    GrowingPBEventV3List *list = [GrowingPBEventV3List parseFromData:data error:nil];
    XCTAssertNotNil(list);
    XCTAssertEqual(list.valuesArray_Count, 3);
    XCTAssertEqualObjects(list.valuesArray[0].class, GrowingPBEventV3Dto.class);
    GrowingPBEventV3Dto *protobuf = list.valuesArray[0];
    XCTAssertEqualObjects(protobuf.eventName, self.event.eventName);
    XCTAssertEqualObjects(protobuf.attributes, self.event.attributes);
}

- (void)testPersistenceToJSONObject {
    GrowingEventProtobufPersistence *p =
        [GrowingEventProtobufPersistence persistenceEventWithEvent:self.event uuid:[NSUUID UUID].UUIDString];
    XCTAssertNotNil(p);
    id jsonObject = p.toJSONObject;
    XCTAssertNotNil(jsonObject);
    XCTAssertEqual([NSJSONSerialization isValidJSONObject:jsonObject], YES);
}

- (void)testPersistenceByReplacingDeviceIdPreservesFields {
    GrowingBaseBuilder *builder = GrowingVisitEvent.builder.setExtraSdk(@{@"key": @"value"})
                                      .setDeviceId(@"generated-device")
                                      .setSessionId(@"test-session");
    GrowingVisitEvent *event = (GrowingVisitEvent *)builder.build;
    GrowingEventProtobufPersistence *p =
        [GrowingEventProtobufPersistence persistenceEventWithEvent:event uuid:[NSUUID UUID].UUIDString];
    GrowingEventProtobufPersistence *replaced =
        (GrowingEventProtobufPersistence *)[p persistenceByReplacingDeviceId:@"visitor-id"];

    GrowingPBEventV3Dto *originalDto = [GrowingPBEventV3Dto parseFromData:p.data error:nil];
    GrowingPBEventV3Dto *replacedDto = [GrowingPBEventV3Dto parseFromData:replaced.data error:nil];
    XCTAssertEqualObjects(originalDto.deviceId, @"generated-device");
    XCTAssertEqualObjects(replacedDto.deviceId, @"visitor-id");
    XCTAssertEqualObjects(originalDto.extraSdk, @{@"key": @"value"});
    XCTAssertEqualObjects(replacedDto.extraSdk, originalDto.extraSdk);
    XCTAssertEqualObjects(replacedDto.sessionId, originalDto.sessionId);
    XCTAssertEqualObjects(replaced.eventUUID, p.eventUUID);
    XCTAssertEqual(replaced.policy, p.policy);
}

@end
