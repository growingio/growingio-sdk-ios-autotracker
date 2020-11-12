//
//  GIOChildsAddViewController.m
//  Example
//
//  Created by sheng on 2020/8/14.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOChildsAddViewController.h"


@implementation GIOIgnoreBaseViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.growingPageIgnorePolicy = GrowingIgnoreSelf;
}

@end

@interface GIOChildsAddViewController ()

@end

@implementation GIOChildsAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIViewController *parent = self.parentViewController;
    while (parent.parentViewController) {
        parent = parent.parentViewController;
    }
//    parent.growingPageIgnorePolicy = GrowingIgnoreAll;
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    GIOBaseViewController *A = [[GIOBaseViewController alloc] init];
    A.view.frame = CGRectMake(0, 0, width, height - 200);
    A.view.layer.borderWidth = 4;
    A.view.layer.borderColor = [UIColor greenColor].CGColor;
    
    GIOIgnoreBaseViewController *B = [[GIOIgnoreBaseViewController alloc] init];
    B.view.frame = CGRectMake(0, height - 200, width, 200);
    B.view.layer.borderWidth = 4;
    B.view.layer.borderColor = [UIColor redColor].CGColor;
    [self addChildViewController:A];
    [self addChildViewController:B];

    [self.view addSubview:A.view];
    [self.view addSubview:B.view];
    
    UIButton *clickBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 60, 30)];
    clickBtn.backgroundColor = [UIColor blueColor];
    [clickBtn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [B.view addSubview:clickBtn];
}

- (void)clickAction {
    NSLog(@"click action");
}

@end
