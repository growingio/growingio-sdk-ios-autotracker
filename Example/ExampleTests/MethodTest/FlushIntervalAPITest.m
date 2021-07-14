//
//  FlushIntervalAPITest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/19.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "FlushIntervalAPITest.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"
#import "GrowingAutotracker.h"

@implementation FlushIntervalAPITest

-(void)test1GetFlushInterVal{
    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"testProjectId"];
    NSLog(@"流量上传间隔 %lu", (unsigned long)configuration.dataUploadInterval);
    XCTAssertEqual((unsigned long)configuration.dataUploadInterval, 15);
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
}

-(void)test2SetFlushInterVal{
//    GrowingAutotrackConfiguration *configuration = [GrowingAutotrackConfiguration configurationWithProjectId:@"testProjectId2"];
//    configuration.dataUploadInterval =10;
//    NSLog(@"流量上传间隔 %lu", (unsigned long)configuration.dataUploadInterval);
//    XCTAssertEqual((unsigned long)configuration.dataUploadInterval, 10);
//    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
}
@end
