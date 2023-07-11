//
//  GIOFirstViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 02/04/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOFirstViewController.h"

@interface GIOFirstViewController ()

@end

@implementation GIOFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
    [[GrowingAutotracker sharedInstance] autotrackPage:self alias:@"子页面1"];
#endif
#endif
}

@end
