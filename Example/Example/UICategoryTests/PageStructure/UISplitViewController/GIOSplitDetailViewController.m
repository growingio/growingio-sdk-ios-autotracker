//
// GIOSplitDetailViewController.m
// Example
//
//  Created by sheng on 2020/9/17.
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


#import "GIOSplitDetailViewController.h"

@interface GIOSplitDetailViewController ()

@end

@implementation GIOSplitDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _detailDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    [self.view addSubview:_detailDescriptionLabel];
    _detailDescriptionLabel.center = self.view.center;
    
    [self setDetailItem:[NSDate date]];
    
}

- (void)setDetailItem:(id)detailItem {
    _detailItem = detailItem;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *stringFromDate = [formatter stringFromDate:detailItem];
    self.detailDescriptionLabel.text = stringFromDate;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
  willHideViewController:(UIViewController *)viewController withBarButtonItem:
  (UIBarButtonItem *)barButtonItem forPopoverController:
  (UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
//    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
  willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view,
    //invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
//    self.masterPopoverController = nil;
}

@end
