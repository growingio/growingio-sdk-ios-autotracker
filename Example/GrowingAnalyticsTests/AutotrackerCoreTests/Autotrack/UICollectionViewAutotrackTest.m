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

@interface AutotrackUICollectionView_Delegate_XCTest : NSObject <UICollectionViewDelegate>

@end

@interface UICollectionViewAutotrackTest : XCTestCase <UICollectionViewDelegate>

@property (nonatomic, strong) AutotrackUICollectionView_Delegate_XCTest *delegate;

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

- (void)test02UICollectionViewRealDelegate {
    AutotrackUICollectionView_XCTest *collectionView = [[AutotrackUICollectionView_XCTest alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                                          collectionViewLayout:UICollectionViewLayout.new];
    self.delegate = [AutotrackUICollectionView_Delegate_XCTest new];
    collectionView.delegate = self.delegate;
    
    [collectionView.delegate collectionView:collectionView
                   didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    NSArray<GrowingBaseEvent *> *events = [MockEventQueue.sharedQueue eventsFor:GrowingEventTypeViewClick];
    XCTAssertEqual(events.count, 1);
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end

#pragma clang diagnostic pop

@implementation AutotrackUICollectionView_Delegate_XCTest

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (Class)class {
    return UICollectionViewController.class;
}

@end
