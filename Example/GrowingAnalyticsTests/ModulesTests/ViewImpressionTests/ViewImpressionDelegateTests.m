//
//  ViewImpressionDelegateTests.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2026/9/21.
//  Copyright (C) 2026 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "Modules/ViewImpression/Public/GrowingViewImpression.h"
#import "Modules/ViewImpression/Public/UIView+GrowingViewImpression.h"
#import "ViewImpressionTestCase.h"

@interface ViewImpressionTestDelegate : NSObject <GrowingImpressionDelegate>

@property (nonatomic, assign) BOOL shouldTrack;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *dynamicAttributes;
@property (nonatomic, copy, nullable) NSString *didTrackEventName;
@property (nonatomic, copy, nullable) NSString *didTrackIdentifier;
@property (nonatomic, assign) NSUInteger didTrackCount;
@property (nonatomic, weak, nullable) UIView *didTrackView;

@end

@implementation ViewImpressionTestDelegate

- (instancetype)init {
    if (self = [super init]) {
        _shouldTrack = YES;
    }
    return self;
}

- (BOOL)growingViewImpressionShouldTrack:(UIView *)view eventName:(NSString *)eventName identifier:(NSString *)identifier {
    return self.shouldTrack;
}

- (NSDictionary<NSString *, id> *)growingViewImpressionDynamicAttributes:(UIView *)view
                                                           eventName:(NSString *)eventName
                                                          identifier:(NSString *)identifier {
    return self.dynamicAttributes;
}

- (void)growingViewImpressionDidTrack:(UIView *)view eventName:(NSString *)eventName identifier:(NSString *)identifier {
    self.didTrackCount += 1;
    self.didTrackEventName = eventName;
    self.didTrackIdentifier = identifier;
    self.didTrackView = view;
}

@end

@interface ViewImpressionDelegateTests : ViewImpressionTestCase

@property (nonatomic, strong) ViewImpressionTestDelegate *delegate;

@end

@implementation ViewImpressionDelegateTests

- (void)setUp {
    [super setUp];
    self.delegate = [[ViewImpressionTestDelegate alloc] init];
    [[GrowingViewImpression sharedInstance] addViewImpressionDelegate:self.delegate];
}

- (void)tearDown {
    [[GrowingViewImpression sharedInstance] removeViewImpressionDelegate:self.delegate];
    self.delegate = nil;
    [super tearDown];
}

- (void)testShouldTrackReturningNoSuppressesEvent {
    self.delegate.shouldTrack = NO;
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackViewImpression:@"imp_veto"];

    [self assertNoMoreCustomEventsWithin:0.5];
    XCTAssertEqual(self.delegate.didTrackCount, 0);
}

- (void)testVetoIsReevaluatedAfterReentry {
    self.delegate.shouldTrack = NO;
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackViewImpression:@"imp_veto_reentry"];
    [self assertNoMoreCustomEventsWithin:0.3];

    self.delegate.shouldTrack = YES;
    view.frame = CGRectMake(0, 700, 375, 100);
    [self pumpRunLoopFor:0.3];
    view.frame = CGRectMake(0, 0, 375, 100);

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
}

- (void)testDynamicAttributesAreMergedOverStaticOnes {
    self.delegate.dynamicAttributes = @{@"shared": @"dynamic", @"only_dynamic": @"1"};
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackViewImpression:@"imp_dynamic" attributes:@{@"shared": @"static", @"only_static": @"1"}];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    NSDictionary *attributes = self.lastCustomEvent.attributes;
    XCTAssertEqualObjects(attributes[@"shared"], @"dynamic");
    XCTAssertEqualObjects(attributes[@"only_dynamic"], @"1");
    XCTAssertEqualObjects(attributes[@"only_static"], @"1");
}

- (void)testDidTrackCarriesViewAndIdentifier {
    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackViewImpression:@"imp_did_track" attributes:nil identifier:@"slot_1" config:nil];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqual(self.delegate.didTrackCount, 1);
    XCTAssertEqualObjects(self.delegate.didTrackEventName, @"imp_did_track");
    XCTAssertEqualObjects(self.delegate.didTrackIdentifier, @"slot_1");
    XCTAssertEqualObjects(self.delegate.didTrackView, view);
}

- (void)testRemovedDelegateIsNotCalled {
    [[GrowingViewImpression sharedInstance] removeViewImpressionDelegate:self.delegate];

    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackViewImpression:@"imp_removed_delegate"];

    XCTAssertTrue([self waitForCustomEventCount:1 timeout:2.0]);
    XCTAssertEqual(self.delegate.didTrackCount, 0);
}

- (void)testAnyDelegateVetoSuppressesEvent {
    ViewImpressionTestDelegate *another = [[ViewImpressionTestDelegate alloc] init];
    another.shouldTrack = NO;
    [[GrowingViewImpression sharedInstance] addViewImpressionDelegate:another];

    UIView *view = [self addViewWithFrame:CGRectMake(0, 0, 375, 100)];
    [view growingTrackViewImpression:@"imp_multi_veto"];

    [self assertNoMoreCustomEventsWithin:0.5];

    [[GrowingViewImpression sharedInstance] removeViewImpressionDelegate:another];
}

@end
