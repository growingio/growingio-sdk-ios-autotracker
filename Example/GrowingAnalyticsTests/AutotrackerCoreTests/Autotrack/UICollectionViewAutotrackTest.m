//
//  UICollectionViewAutotrackTest.m
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

#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Manager/GrowingSession.h"
#import "GrowingServiceManager.h"
#import "GrowingEventDatabaseService.h"
#import "Services/Database/GrowingEventFMDatabase.h"
#import "GrowingAutotrackerCore/Autotrack/UICollectionView+GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingViewElementEvent.h"
#import "InvocationHelper.h"
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"

// 可配置growingNodeDonotTrack，从而配置可否生成VIEW_CLICK，以供测试
// -------------------------------------------------------------------------------
// UICollectionViewCell
@interface AutotrackUICollectionViewCell_XCTest : UICollectionViewCell

@property(nonatomic, assign) BOOL growingNodeDonotTrack_XCTest;

@end

@implementation AutotrackUICollectionViewCell_XCTest

@end

@implementation AutotrackUICollectionViewCell_XCTest (DonotTrack)

- (BOOL)growingNodeDonotTrack {
    return self.growingNodeDonotTrack_XCTest;
}

@end

// UICollectionView
@interface AutotrackUICollectionView_XCTest : UICollectionView

@property(nonatomic, assign) BOOL growingNodeDonotTrack_XCTest;

@end

@implementation AutotrackUICollectionView_XCTest

@end

@implementation AutotrackUICollectionView_XCTest (DonotTrack)

- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AutotrackUICollectionViewCell_XCTest *cell = AutotrackUICollectionViewCell_XCTest.new;
    cell.growingNodeDonotTrack_XCTest = NO;
    return cell;
}

@end
// -------------------------------------------------------------------------------

@interface AutotrackUICollectionView_Delegate_XCTest : NSObject <UICollectionViewDelegate>

@end

@interface AutotrackUICollectionView_Delegate_2_XCTest : NSObject <UICollectionViewDelegate>

@property (nonatomic, weak) id <UICollectionViewDelegate> target;

- (instancetype)initWithTarget:(id <UICollectionViewDelegate>)target;

@end

@interface UICollectionViewAutotrackTest : XCTestCase <UICollectionViewDelegate>

@property (nonatomic, strong) id <UICollectionViewDelegate> delegate;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation UICollectionViewAutotrackTest

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

- (void)test01UICollectionViewAutotrack {
    AutotrackUICollectionView_XCTest *collectionView = [[AutotrackUICollectionView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                                          collectionViewLayout:UICollectionViewLayout.new];
    collectionView.delegate = self;
    
    [collectionView.delegate collectionView:collectionView
                   didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);
}

static BOOL kDelegateDidCalled = NO;
static BOOL kRealDelegateDidCalled = NO;
- (void)test02UICollectionViewRealDelegate {
    // 普通 delegate 对象，仅实现了 UICollectionViewDelegate 方法
    AutotrackUICollectionView_XCTest *collectionView = [[AutotrackUICollectionView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                                          collectionViewLayout:UICollectionViewLayout.new];
    self.delegate = [[AutotrackUICollectionView_Delegate_XCTest alloc] init];
    collectionView.delegate = self.delegate;
    
    kDelegateDidCalled = NO;
    kRealDelegateDidCalled = NO;
    [collectionView.delegate collectionView:collectionView
                   didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    // 触发了无埋点点击事件
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);
    
    // 触发了 AutotrackUICollectionView_Delegate_XCTest didSelectItemAtIndexPath
    XCTAssertTrue(kRealDelegateDidCalled);
}

- (void)test03UICollectionViewRealDelegate_2 {
    // 特殊 delegate 对象，实现了 UICollectionViewDelegate 方法，并重写了 class 方法
    // 模拟动态子类
    AutotrackUICollectionView_XCTest *collectionView = [[AutotrackUICollectionView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                                          collectionViewLayout:UICollectionViewLayout.new];
    self.delegate = [[AutotrackUICollectionView_Delegate_2_XCTest alloc] initWithTarget:self];
    collectionView.delegate = self.delegate;
    
    kDelegateDidCalled = NO;
    kRealDelegateDidCalled = NO;
    [collectionView.delegate collectionView:collectionView
                   didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    // 触发了无埋点点击事件
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    // 因为上面 test01UICollectionViewAutotrack 也对 self 进行了 hook，所以如果一起执行这里会等于 2
    XCTAssertGreaterThanOrEqual(events.count, 1);
    
    // 触发了 UICollectionViewAutotrackTest didSelectItemAtIndexPath
    XCTAssertTrue(kDelegateDidCalled);
    
    // 触发了 AutotrackUICollectionView_Delegate_2_XCTest didSelectItemAtIndexPath
    XCTAssertTrue(kRealDelegateDidCalled);
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    kDelegateDidCalled = YES;
    NSLog(@"UICollectionViewAutotrackTest didSelectItemAtIndexPath");
}

@end

#pragma clang diagnostic pop

@implementation AutotrackUICollectionView_Delegate_XCTest

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    kRealDelegateDidCalled = YES;
    NSLog(@"AutotrackUICollectionView_Delegate_XCTest didSelectItemAtIndexPath");
}

@end

@implementation AutotrackUICollectionView_Delegate_2_XCTest

- (instancetype)initWithTarget:(id <UICollectionViewDelegate>)target {
    if (self = [super init]) {
        _target = target;
    }
    return self;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.target && [self.target respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.target collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
    
    kRealDelegateDidCalled = YES;
    NSLog(@"AutotrackUICollectionView_Delegate_XCTest didSelectItemAtIndexPath");
}

- (Class)class {
    // 重写了 class，则必须在 @selector(collectionView:didSelectItemAtIndexPath:) 中调用其对应方法
    // 模拟动态子类的实现
    return UICollectionViewAutotrackTest.class;
}

@end
