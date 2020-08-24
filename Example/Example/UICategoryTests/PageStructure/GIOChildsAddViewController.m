//
//  GIOChildsAddViewController.m
//  Example
//
//  Created by sheng on 2020/8/14.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOChildsAddViewController.h"
#import "GIOBaseViewController.h"
@interface GIOChildsAddViewController ()

@end

@implementation GIOChildsAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    GIOBaseViewController *A = [[GIOBaseViewController alloc] init];
    A.view.frame = CGRectMake(0, 0, width, height - 200);
    A.view.backgroundColor = [UIColor greenColor];
    
    GIOBaseViewController *B = [[GIOBaseViewController alloc] init];
    B.view.frame = CGRectMake(0, height - 200, width,200);
    B.view.backgroundColor = [UIColor redColor];
    
    [self addChildViewController:A];
    [self addChildViewController:B];
    
    [self.view addSubview:A.view];
    [self.view addSubview:B.view];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
