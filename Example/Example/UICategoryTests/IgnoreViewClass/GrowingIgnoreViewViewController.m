//
//  GrowingIgnoreViewViewController.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/7/14.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingIgnoreViewViewController.h"
#import "GrowingIgnoreButton1.h"
#import "GrowingIgnoreButton2.h"
#import "GrowingIgnoreButton3.h"
#import "GrowingNotIgnoreButton4.h"

@interface GrowingIgnoreViewViewController ()

@end

@implementation GrowingIgnoreViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    id autotracker = [GrowingAutotracker sharedInstance];
    if ([autotracker respondsToSelector:@selector(ignoreViewClasses)]) {
        NSMutableSet *ignoreViewClasses = [autotracker performSelector:@selector(ignoreViewClasses)];
        [ignoreViewClasses removeAllObjects];
    }
#pragma clang diagnostic pop
    
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
    if (self.type == GrowingDemoIgnoreViewTypeSingle) {
        [[GrowingAutotracker sharedInstance] ignoreViewClass:GrowingIgnoreButton1.class];
    } else if (self.type == GrowingDemoIgnoreViewTypeMutiple) {
        [[GrowingAutotracker sharedInstance] ignoreViewClasses:@[GrowingIgnoreButton1.class, GrowingIgnoreButton2.class, GrowingIgnoreButton3.class]];
    }
#endif
#endif
}

- (IBAction)buttonAction:(id)sender {
}

@end
