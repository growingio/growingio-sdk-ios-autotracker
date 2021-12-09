//
// GIODataCollectionEnabledViewController.m
// Example
//
//  Created by YoloMao on 2021/8/26.
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


#import "GIODataCollectionEnabledViewController.h"

@interface GIODataCollectionEnabledViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *dataCollectionSwitch;

@end

@implementation GIODataCollectionEnabledViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataCollectionSwitch.on = self.dataCollectionEnabled;
}

#pragma mark - Action

- (IBAction)dataCollectionSwitchChange:(UISwitch *)sender {
#if Autotracker
    [[GrowingAutotracker sharedInstance] setDataCollectionEnabled:sender.isOn];
#endif
}

#pragma mark - Getter & Setter

- (BOOL)dataCollectionEnabled {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class class = NSClassFromString(@"GrowingConfigurationManager");
    SEL selector = NSSelectorFromString(@"sharedInstance");
    if (class && [class respondsToSelector:selector]) {
        id manager = [class performSelector:selector];
        SEL configurationSelector = NSSelectorFromString(@"trackConfiguration");
        if (manager && [manager respondsToSelector:configurationSelector]) {
            NSObject *configuration = [manager performSelector:configurationSelector];
            if (configuration) {
                return ((NSNumber *)[configuration valueForKey:@"dataCollectionEnabled"]).boolValue;
            }
        }
    }
#pragma clang diagnostic pop
    return YES;
}

@end
