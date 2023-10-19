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

#import "GrowingAutotrackerCore/Autotrack/UITableView+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingEventDatabaseService.h"
#import "GrowingServiceManager.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "InvocationHelper.h"
#import "MockEventQueue.h"
#import "Services/Protobuf/GrowingEventProtobufDatabase.h"

// 可配置growingNodeDonotTrack，从而配置可否生成VIEW_CLICK，以供测试
// -------------------------------------------------------------------------------
// UITableViewCell
@interface AutotrackUITableViewCell_XCTest : UITableViewCell

@property (nonatomic, assign) BOOL growingNodeDonotTrack_XCTest;

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

@property (nonatomic, assign) BOOL growingNodeDonotTrack_XCTest;

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
// -------------------------------------------------------------------------------

@interface AutotrackUITableView_Delegate_XCTest : NSObject <UITableViewDelegate>

@end

@interface AutotrackUITableView_Delegate_2_XCTest : NSObject <UITableViewDelegate>

@property (nonatomic, weak) id<UITableViewDelegate> target;

- (instancetype)initWithTarget:(id<UITableViewDelegate>)target;

@end

@interface UITableViewAutotrackTest : XCTestCase <UITableViewDelegate>

@property (nonatomic, strong) id<UITableViewDelegate> delegate;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation UITableViewAutotrackTest

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

- (void)test01UITableViewAutotrack {
    AutotrackUITableView_XCTest *tableView =
        [[AutotrackUITableView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    tableView.delegate = self;

    [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]];

    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);
}

static BOOL kDelegateDidCalled = NO;
static BOOL kRealDelegateDidCalled = NO;
- (void)test02UITableViewRealDelegate {
    // 普通 delegate 对象，仅实现了 UITableViewDelegate 方法
    AutotrackUITableView_XCTest *tableView =
        [[AutotrackUITableView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.delegate = [AutotrackUITableView_Delegate_XCTest new];
    tableView.delegate = self.delegate;

    kDelegateDidCalled = NO;
    kRealDelegateDidCalled = NO;
    [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]];

    // 触发了无埋点点击事件
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);

    // 触发了 AutotrackUITableView_Delegate_XCTest didSelectRowAtIndexPath
    XCTAssertTrue(kRealDelegateDidCalled);
}

- (void)test03UITableViewRealDelegate_2 {
    // 特殊 delegate 对象，实现了 UITableViewDelegate 方法，并重写了 class 方法
    // 模拟动态子类
    AutotrackUITableView_XCTest *tableView =
        [[AutotrackUITableView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.delegate = [[AutotrackUITableView_Delegate_2_XCTest alloc] initWithTarget:self];
    tableView.delegate = self.delegate;

    kDelegateDidCalled = NO;
    kRealDelegateDidCalled = NO;
    [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]];

    // 触发了无埋点点击事件
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    // 因为上面 test01UITableViewAutotrack 也对 self 进行了 hook，所以如果一起执行这里会等于 2
    XCTAssertGreaterThanOrEqual(events.count, 1);

    // 触发了 UITableViewAutotrackTest didSelectRowAtIndexPath
    XCTAssertTrue(kDelegateDidCalled);

    // 触发了 AutotrackUITableView_Delegate_2_XCTest didSelectRowAtIndexPath
    XCTAssertTrue(kRealDelegateDidCalled);
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    kDelegateDidCalled = YES;
    NSLog(@"UITableViewAutotrackTest didSelectRowAtIndexPath");
}

@end

#pragma clang diagnostic pop

@implementation AutotrackUITableView_Delegate_XCTest

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    kRealDelegateDidCalled = YES;
    NSLog(@"AutotrackUITableView_Delegate_XCTest didSelectRowAtIndexPath");
}

@end

@implementation AutotrackUITableView_Delegate_2_XCTest

- (instancetype)initWithTarget:(id<UITableViewDelegate>)target {
    if (self = [super init]) {
        _target = target;
    }
    return self;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.target && [self.target respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.target tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    kRealDelegateDidCalled = YES;
    NSLog(@"AutotrackUITableView_Delegate_2_XCTest didSelectRowAtIndexPath");
}

- (Class)class {
    // 重写了 class，则必须在 @selector(tableView:didSelectRowAtIndexPath:) 中调用其对应方法
    // 模拟动态子类的实现
    return UITableViewAutotrackTest.class;
}

@end
