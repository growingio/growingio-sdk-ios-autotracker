//
//  GrowingAppLifeCycleTest.m
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

#import "GrowingAppLifecycle.h"
#import "InvocationHelper.h"

@interface GrowingAppLifeCycleTest : XCTestCase <GrowingAppLifecycleDelegate>

@end

@implementation GrowingAppLifeCycleTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingAppLifeCycle {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    GrowingAppLifecycle *sharedInstance = GrowingAppLifecycle.sharedInstance;
    XCTAssertNotNil(sharedInstance);
    XCTAssertNoThrow([sharedInstance safePerformSelector:@selector(setupAppStateNotification)]);
    XCTAssertNoThrow([sharedInstance safePerformSelector:@selector(addSceneNotification)]);
    
    XCTAssertNoThrow([sharedInstance addAppLifecycleDelegate:self]);
    
    [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationDidFinishLaunchingNotification object:UIApplication.sharedApplication];
    [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationWillTerminateNotification object:UIApplication.sharedApplication];
    [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationDidBecomeActiveNotification object:UIApplication.sharedApplication];
    [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationWillEnterForegroundNotification object:UIApplication.sharedApplication];
    [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationWillResignActiveNotification object:UIApplication.sharedApplication];
    [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:UIApplication.sharedApplication];

    XCTAssertNoThrow([sharedInstance removeAppLifecycleDelegate:self]);
    sharedInstance = nil;
#pragma clang diagnostic pop
}

#pragma mark - GrowingAppLifecycleDelegate

- (void)applicationDidFinishLaunching:(NSDictionary *)userInfo {
    
}

- (void)applicationWillTerminate {
    
}

- (void)applicationDidBecomeActive {
    
}

- (void)applicationWillResignActive {
    
}

- (void)applicationDidEnterBackground {
    
}

- (void)applicationWillEnterForeground {
    
}

@end
