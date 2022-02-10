//
//  JSONPersistenceTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/18.
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

#import "GrowingEventJSONPersistence.h"
#import "GrowingCustomEvent.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSString+GrowingHelper.h"

@interface JSONPersistenceTest : XCTestCase

@property (nonatomic, strong) GrowingCustomEvent *event;

@end

@implementation JSONPersistenceTest

- (void)setUp {
    self.event = (GrowingCustomEvent
                      *)(GrowingCustomEvent.builder.setEventName(@"custom").setAttributes(@{@"key": @"value"}).build);
}

- (void)testPersistenceInit {
    NSString *uuid = [NSUUID UUID].UUIDString;
    GrowingEventJSONPersistence *p =
        [[GrowingEventJSONPersistence alloc] initWithUUID:uuid
                                                eventType:self.event.eventType
                                               jsonString:self.event.toDictionary.growingHelper_jsonString
                                                   policy:self.event.sendPolicy];
    XCTAssertNotNil(p);
    XCTAssertEqualObjects(p.eventUUID, uuid);
    XCTAssertEqualObjects(p.eventType, self.event.eventType);
    XCTAssertEqual(p.policy, self.event.sendPolicy);
    XCTAssertEqualObjects(p.rawJsonString, self.event.toDictionary.growingHelper_jsonString);
}

- (void)testPersistenceWithEvent {
    NSString *uuid = [NSUUID UUID].UUIDString;
    GrowingEventJSONPersistence *p = [GrowingEventJSONPersistence persistenceEventWithEvent:self.event uuid:uuid];
    XCTAssertNotNil(p);
    XCTAssertEqualObjects(p.eventUUID, uuid);
    XCTAssertEqualObjects(p.eventType, self.event.eventType);
    XCTAssertEqual(p.policy, self.event.sendPolicy);
    XCTAssertEqualObjects(p.rawJsonString, self.event.toDictionary.growingHelper_jsonString);
}

- (void)testBuildRawEventsFromEvents {
    GrowingEventJSONPersistence *p1 = [GrowingEventJSONPersistence persistenceEventWithEvent:self.event
                                                                                        uuid:[NSUUID UUID].UUIDString];
    GrowingEventJSONPersistence *p2 = [GrowingEventJSONPersistence persistenceEventWithEvent:self.event
                                                                                        uuid:[NSUUID UUID].UUIDString];
    GrowingEventJSONPersistence *p3 = [GrowingEventJSONPersistence persistenceEventWithEvent:self.event
                                                                                        uuid:[NSUUID UUID].UUIDString];
    NSData *data = [GrowingEventJSONPersistence buildRawEventsFromEvents:@[p1, p2, p3]];
    XCTAssertNotNil(data);
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(jsonString);
    NSArray *raws = jsonString.growingHelper_jsonObject;
    XCTAssertEqual(raws.count, 3);
    NSDictionary *jsonObject = raws[0];
    XCTAssertEqualObjects(jsonObject[@"eventName"], self.event.eventName);
    XCTAssertEqualObjects(jsonObject[@"attributes"], self.event.attributes);
}

- (void)testPersistenceToJSONObject {
    GrowingEventJSONPersistence *p = [GrowingEventJSONPersistence persistenceEventWithEvent:self.event
                                                                                       uuid:[NSUUID UUID].UUIDString];
    XCTAssertNotNil(p);
    id jsonObject = p.toJSONObject;
    XCTAssertNotNil(jsonObject);
    XCTAssertEqual([NSJSONSerialization isValidJSONObject:jsonObject], YES);
}

@end
