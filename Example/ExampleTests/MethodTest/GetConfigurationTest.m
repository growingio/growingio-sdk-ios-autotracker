//
//  GetConfigurationTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 7/24/20.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "MockEventQueue.h"
#import "GrowingAutotracker.h"

@interface GetConfigurationTest : KIFTestCase

@end

@implementation GetConfigurationTest

-(void)test1GetConfigurationTest{
    /*
     Function:测试Configuration
     */
    [MockEventQueue.sharedQueue cleanQueue];

    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithProjectId:@"aaaa"];
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:nil];
     
    XCTAssertEqual(configuration.debugEnabled, NO);
    XCTAssertEqual(configuration.dataUploadInterval, 15);
    XCTAssertEqual(configuration.sessionInterval, 30);
    XCTAssertEqual(configuration.cellularDataLimit,10);
    XCTAssertEqual(configuration.uploadExceptionEnable,YES);
        NSLog(@"测试配置通过---passed");
 
//    GrowingConfiguration *configuration = [[GrowingConfiguration alloc] initWithProjectId:@"aaa"
//                                                                            launchOptions:nil];
//    if(configuration.logEnabled == NO && configuration.dataUploadInterval == 15  && configuration.sessionInterval == 30 && configuration.cellularDataLimit == 10 * 1024 && configuration.uploadExceptionEnable == YES && configuration.samplingRate == 1.0)
//    {
//        XCTAssertEqual(1, 1);
//        NSLog(@"测试配置通过---passed");
//    }
//    else
//    {
//        NSLog(@"测试配置不通过");
//        XCTAssertEqual(1, 0);
//    }
     
}


-(void)testGetTrackVersion{
    /*
        Function:测试getTrackVersion
    */
//    [[GrowingAutotracker sharedInstance] getVersion];
}
-(void)testGetDeviceId{
    /*
        Function:测试getDeviceId
    */
    [[GrowingAutotracker sharedInstance] getDeviceId];
}

@end
