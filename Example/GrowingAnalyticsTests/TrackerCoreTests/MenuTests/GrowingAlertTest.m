//
//  GrowingAlertTest.m
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

#import "GrowingTrackerCore/Menu/GrowingAlert.h"

@interface GrowingAlertTest : XCTestCase

@end

@implementation GrowingAlertTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGrowingAlert {
    GrowingAlert *alert = [GrowingAlert createAlertWithStyle:UIAlertControllerStyleAlert
                                                       title:@"XCTest"
                                                     message:@"test"];
    [alert addActionWithTitle:@"Default"
                        style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction *_Nonnull action, NSArray<UITextField *> *_Nonnull textFields){

                      }];
    [alert addOkWithTitle:@"OK"
                  handler:^(UIAlertAction *_Nonnull action, NSArray<UITextField *> *_Nonnull textFields){

                  }];
    [alert addCancelWithTitle:@"Cancel"
                      handler:^(UIAlertAction *_Nonnull action, NSArray<UITextField *> *_Nonnull textFields){

                      }];
    [alert addDestructiveWithTitle:@"Destructive"
                           handler:^(UIAlertAction *_Nonnull action, NSArray<UITextField *> *_Nonnull textFields){

                           }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField){

    }];

    [alert showAlertAnimated:YES];
}

@end
