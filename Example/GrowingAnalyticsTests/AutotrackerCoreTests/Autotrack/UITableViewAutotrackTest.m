//
//  UITableViewAutotrackTest.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2022/1/25.
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

#import "GrowingConfigurationManager.h"
#import "GrowingSession.h"
#import "GrowingServiceManager.h"
#import "GrowingEventDatabaseService.h"
#import "GrowingEventFMDatabase.h"
#import "UITableView+GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "GrowingViewElementEvent.h"
#import "InvocationHelper.h"
#import "GrowingRealAutotracker.h"

// 可配置growingNodeDonotTrack，从而配置可否生成VIEW_CLICK，以供测试

// UITableViewCell
@interface AutotrackUITableViewCell_XCTest : UITableViewCell

@property(nonatomic, assign) BOOL growingNodeDonotTrack_XCTest;

@end

@implementation AutotrackUITableViewCell_XCTest

@end

@implementation AutotrackUITableViewCell_XCTest (DonotTrack)

- (BOOL)growingNodeDonotTrack {
    return self.growingNodeDonotTrack_XCTest;
}

@end

// UITableView
@interface AutotrackUITableView_XCTest : UITableView

@property(nonatomic, assign) BOOL growingNodeDonotTrack_XCTest;

@end

@implementation AutotrackUITableView_XCTest

@end

@implementation AutotrackUITableView_XCTest (DonotTrack)

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutotrackUITableViewCell_XCTest *cell = AutotrackUITableViewCell_XCTest.new;
    cell.growingNodeDonotTrack_XCTest = NO;
    return cell;
}

@end

@interface UITableViewAutotrackTest : XCTestCase <UITableViewDelegate>

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation UITableViewAutotrackTest

+ (void)setUp {
    GrowingTrackConfiguration *config = [GrowingTrackConfiguration configurationWithProjectId:@"test"];
    // 避免不执行readPropertyInTrackThread
    config.dataCollectionEnabled = YES;
    GrowingConfigurationManager.sharedInstance.trackConfiguration = config;
    
    // 避免insertEventToDatabase异常
    [GrowingServiceManager.sharedInstance registerService:@protocol(GrowingEventDatabaseService)
                                                implClass:GrowingEventFMDatabase.class];
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

- (void)testUITableViewAutotrack {
    AutotrackUITableView_XCTest *tableView = [[AutotrackUITableView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    tableView.delegate = self;
    
    [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
}

@end

#pragma clang diagnostic pop
