//
//  TrackViewTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/8/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "TrackViewTest.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"

@implementation TrackViewTest

-(void) test1TackviewTrue{
    /**
     function:测试enableAllWebViews
     **/
    [[GrowingTracker sharedInstance] setDataCollectionEnabled:YES];

}


-(void) test2TackviewFalse{
    /**
     function:测试enableAllWebViews
     **/

    [[GrowingTracker sharedInstance] setDataCollectionEnabled:NO];
}

@end
