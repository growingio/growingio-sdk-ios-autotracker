//
// HybirdTests.m
// ExampleTests
//
//  Created by GrowingIO on 9/11/20.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
#import "GrowingTracker.h"
#import <KIF/KIF.h>
//#import "GrowingWebCircle.h"
//#import "GrowingSRWebSocket.h"


@interface HybirdTests : KIFTestCase

@end

@implementation HybirdTests

- (void)setUp {
    [[GrowingTracker sharedInstance] setLoginUserId:@"test"];
    [[viewTester usingLabel:@"UI界面"] tap];
    [viewTester waitForTimeInterval:3];
    [[viewTester usingLabel:@"UI界面"] tap];
    
}

- (void)tearDown {
    [[viewTester usingLabel:@"UI界面"] tap];
    
}

- (void)testHybrid {
    [MockEventQueue.sharedQueue cleanQueue];
    [[viewTester usingLabel:@"Hybrid"] tap];
    [viewTester waitForTimeInterval:3];
    [[viewTester usingLabel:@"返回"] tap];
    
    
}

-(void)testCollectionView{
    [[viewTester usingLabel:@"CollectionView"] tap];
    [[viewTester usingLabel:@"UI界面"] tap];
    
}

-(void)testPageStucture{
    [[viewTester usingLabel:@"Page Structure"] tap];
    [viewTester waitForTimeInterval:1];
    [[viewTester usingLabel:@"Multi ViewController"] tap];
    [[viewTester usingLabel:@"UI界面"] tap];
    
}
-(void)testActionSheets{
    [[viewTester usingLabel:@"Action Sheets"] tap];
    [viewTester waitForTimeInterval:1];
    [[viewTester usingLabel:@"GrowingAlertMenuThree"] tap];
    [viewTester waitForTimeInterval:1];
    [[viewTester usingLabel:@"Three"] tap];
    
}
-(void)testCloseEvent{
    
//    [GrowingCloseEvent sendWithLastPage:@"closepage"];

}
-(void)testWebCircle{
//    [GrowingWebCircle isRunning];
//    [GrowingWebCircle stop];
//    [GrowingWebCircle setNeedUpdateScreen];
//    [GrowingWebCircle impressScale];
    
}

-(void)testGrowingSRWebSocket{
//    NSURL *url = [NSURL URLWithString:@"https://www.growingio.com"];
//    GrowingSRWebSocket *webSocket = [[GrowingSRWebSocket alloc]initWithURL:url];
//    [webSocket open];
//    [webSocket close];
}

@end
