//
// SomeEventsTest.m
// ExampleTests
//
//  Created by GrowingIO on 11/25/20.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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


#import "SomeEventsTest.h"
#import "GrowingTestHelper.h"
#import "GrowingAutotracker.h"
#import "MockEventQueue.h"
#import "NoburPoMeaProCheck.h"
//#import "HTTPStubsHelper.h"

@implementation SomeEventsTest

- (void)beforeEach {
    //设置userid,确保cs1字段不空
    [[GrowingAutotracker sharedInstance] setLoginUserId:@"test"];
    [[viewTester usingLabel:@"UI界面"] tap];

}
- (void)afterEach {
    //[GrowingTestHelper ExiteApp];
}

- (void)test1Event{
    
    
}
@end
