//
//  GIOSecondViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 02/04/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOSecondViewController.h"

@interface GIOSecondViewController ()

@end

@implementation GIOSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
    [[GrowingAutotracker sharedInstance] autotrackPage:self alias:@"子页面2"];
#endif
#endif
}

@end
