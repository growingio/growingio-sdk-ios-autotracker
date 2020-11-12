//
// Created by xiangyang on 2020/4/26.
// Copyright (c) 2020 GrowingIO. All rights reserved.
//

#import "GIOMultiViewController.h"

@implementation GIOMultiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.title = @"Multi ViewController";
    
//    self.growingPageIgnorePolicy = GrowingIgnoreAll;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"xxx GIOMultiViewController: viewDidAppear");
}
@end

