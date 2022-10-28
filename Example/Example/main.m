//
//  main.m
//  GrowingExample
//
//  Created by GrowingIO on 08/04/2020.
//  Copyright (c) 2020 GrowingIO. All rights reserved.
//

@import UIKit;
#import "AppDelegate.h"
#import "GrowingAPMModule.h"

int main(int argc, char * argv[])
{
    [GrowingAPM setupMonitors:GrowingAPMMonitorsCrash | GrowingAPMMonitorsUserInterface
             appDelegateClass:[AppDelegate class]];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
