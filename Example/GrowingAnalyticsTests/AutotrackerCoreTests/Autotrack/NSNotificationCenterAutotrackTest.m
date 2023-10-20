//
//  NotificationCenterAutotrackTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/21.
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

#import "GrowingAutotrackerCore/Autotrack/NSNotificationCenter+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingEventDatabaseService.h"
#import "GrowingServiceManager.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "InvocationHelper.h"
#import "MockEventQueue.h"
#import "Services/Protobuf/GrowingEventProtobufDatabase.h"

// 可配置growingNodeDonotTrack，从而配置可否生成VIEW_CHANGE，以供测试
#define AutotrackXCTestClassDefine(cls)                                                  \
    @interface Autotrack                                                                 \
    ##cls##_XCTest : cls @property(nonatomic, assign) BOOL growingNodeDonotTrack_XCTest; \
    @end                                                                                 \
    @implementation Autotrack                                                            \
    ##cls##_XCTest @end                                                                  \
    @implementation Autotrack                                                            \
    ##cls##_XCTest(DonotTrack) - (BOOL)growingNodeDonotTrack {                           \
        return self.growingNodeDonotTrack_XCTest;                                        \
    }                                                                                    \
    @end

AutotrackXCTestClassDefine(UITextField) AutotrackXCTestClassDefine(UITextView)

    @interface NSNotificationCenterAutotrackTest : XCTestCase

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation NSNotificationCenterAutotrackTest

+ (void)setUp {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithAccountId:@"test"];
    // 避免不执行readPropertyInTrackThread
    config.dataCollectionEnabled = YES;
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;

    // 避免insertEventToDatabase异常
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingPBEventDatabaseService)
                                                implClass:GrowingEventProtobufDatabase.class];
    // 初始化sessionId
    [GrowingSession startSession];
}

- (void)setUp {
    // dispatch_once
    [GrowingRealAutotracker.new safePerformSelector:@selector(addAutoTrackSwizzles)];
    [MockEventQueue.sharedQueue cleanQueue];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNSNotificationCenterAutotrack {
    AutotrackUITextField_XCTest *textField = AutotrackUITextField_XCTest.new;
    textField.growingNodeDonotTrack_XCTest = NO;
    textField.text = @"newText";
    [textField safePerformSelector:@selector(setGrowingHookOldText:) arguments:@"oldText", nil];
    {
        // 正常改变text，发送VIEW_CHANGE
        [MockEventQueue.sharedQueue cleanQueue];
        [NSNotificationCenter.defaultCenter postNotificationName:UITextFieldTextDidEndEditingNotification
                                                          object:textField
                                                        userInfo:@{}];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 1);
    }

    {
        // secureTextEntry为YES，不发送VIEW_CHANGE
        textField.secureTextEntry = YES;

        [MockEventQueue.sharedQueue cleanQueue];
        [NSNotificationCenter.defaultCenter postNotificationName:UITextFieldTextDidEndEditingNotification
                                                          object:textField
                                                        userInfo:@{}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 0);

        textField.secureTextEntry = NO;
    }

    {
        // growingNodeDonotTrack为YES，不发送VIEW_CHANGE
        textField.growingNodeDonotTrack_XCTest = YES;

        [MockEventQueue.sharedQueue cleanQueue];
        [NSNotificationCenter.defaultCenter postNotificationName:UITextFieldTextDidEndEditingNotification
                                                          object:textField
                                                        userInfo:@{}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 0);
    }

    AutotrackUITextView_XCTest *textView = AutotrackUITextView_XCTest.new;
    textView.text = @"newText";
    [textView safePerformSelector:@selector(setGrowingHookOldText:) arguments:@"oldText", nil];
    {
        // 正常改变text，发送VIEW_CHANGE
        [MockEventQueue.sharedQueue cleanQueue];
        [NSNotificationCenter.defaultCenter postNotificationName:UITextFieldTextDidEndEditingNotification
                                                          object:textView
                                                        userInfo:@{}];

        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 1);
    }

    {
        // secureTextEntry为YES，不发送VIEW_CHANGE
        textView.secureTextEntry = YES;

        [MockEventQueue.sharedQueue cleanQueue];
        [NSNotificationCenter.defaultCenter postNotificationName:UITextFieldTextDidEndEditingNotification
                                                          object:textView
                                                        userInfo:@{}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 0);

        textView.secureTextEntry = NO;
    }

    {
        // growingNodeDonotTrack为YES，不发送VIEW_CHANGE
        textView.growingNodeDonotTrack_XCTest = YES;

        [MockEventQueue.sharedQueue cleanQueue];
        [NSNotificationCenter.defaultCenter postNotificationName:UITextFieldTextDidEndEditingNotification
                                                          object:textView
                                                        userInfo:@{}];
        NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewChange];
        XCTAssertEqual(events.count, 0);
    }
}

@end

#pragma clang diagnostic pop
