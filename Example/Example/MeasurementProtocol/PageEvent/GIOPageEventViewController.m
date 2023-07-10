//
//  GIOPageEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 02/04/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "GIOPageEventViewController.h"
#import "GIOContainerViewController.h"
#import "GrowingAutotrackPageViewController.h"

@interface GIOPageEventViewController ()

@end

@implementation GIOPageEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            GrowingAutotrackPageViewController *controller = [[GrowingAutotrackPageViewController alloc] init];
            controller.type = GrowingDemoAutotrackPageTypeDefault;
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 1: {
            GrowingAutotrackPageViewController *controller = [[GrowingAutotrackPageViewController alloc] init];
            controller.type = GrowingDemoAutotrackPageTypeDelay;
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 2: {
            GrowingAutotrackPageViewController *controller = [[GrowingAutotrackPageViewController alloc] init];
            controller.type = GrowingDemoAutotrackPageTypeNotViewDidAppear;
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 3: {
            GrowingAutotrackPageViewController *controller = [[GrowingAutotrackPageViewController alloc] init];
            controller.type = GrowingDemoAutotrackPageTypeDelayNotViewDidAppear;
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 4: {
            // 参考：https://onevcat.com/2012/02/uiviewcontroller/
            GIOContainerViewController *container = [GIOContainerViewController new];
            [self.navigationController pushViewController:container animated:YES];
        } break;
        default:
            break;
    }
}

@end
