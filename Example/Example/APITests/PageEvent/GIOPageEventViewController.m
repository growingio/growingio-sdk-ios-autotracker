//
//  GIOPageEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 02/04/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOPageEventViewController.h"

#import "ContainerViewController.h"

@interface GIOPageEventViewController ()

@end

@implementation GIOPageEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//参考：https://onevcat.com/2012/02/uiviewcontroller/
- (IBAction)toViewControllerWhichContainTwoChildControllers:(id)sender {
    ContainerViewController *container = [ContainerViewController new];
    [self.navigationController pushViewController:container animated:YES];
}


@end
