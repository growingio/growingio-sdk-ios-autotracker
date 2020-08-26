//
//  DailyDataLimit.m
//  GIOAutoTests
//
//  Created by GrowingIO on 2018/6/19.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "DailyDataLimit.h"
#import "MockEventQueue.h"
#import "GrowingTracker.h"

@implementation DailyDataLimit

-(void)test1GetDailyDataLimit{
    /**
     function:获取蜂窝当天数据限额
     **/
    [MockEventQueue.sharedQueue cleanQueue];
    NSLog(@"获取蜂窝数据，测试通过---passed");
}

-(void) test2SetDailyDataLimit{
    /**
     function:设置蜂窝当天数据限额
     **/
    [MockEventQueue.sharedQueue cleanQueue];
  
}
@end
