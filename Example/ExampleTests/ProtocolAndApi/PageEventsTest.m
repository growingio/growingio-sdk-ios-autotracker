//
//  PageEventsTest.m
//  GIOAutoTests
//
//  Created by GrowingIO on 31/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import <KIF/KIF.h>
#import "MockEventQueue.h"
#import "GrowingTestHelper.h"

static NSString *pageType = @"PAGE";

@interface PageEventsTest : KIFTestCase

@end

@implementation PageEventsTest


- (void)beforeEach {

}

- (void)afterEach {
    
}


- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

//统计 tl 为 title 的event个数
- (NSInteger)calculateEventsCountWithTitle:(NSString *)title fromEventsArray:(NSArray *)array {
    NSInteger eventsCount = 0;
    for (NSDictionary *dic in array) {
        if ([dic[@"tl"] isEqualToString:title]) {
            eventsCount += 1;
        }
    }
    return eventsCount;
}

@end
