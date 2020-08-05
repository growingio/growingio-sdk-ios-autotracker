//
//  GrowingTestHelper.m
//  GrowingSDKTest
//
//  Created by apple on 2017/9/28.
//  Copyright © 2017年 GrowingIO. All rights reserved.
//

#import "GrowingTestHelper.h"
#import <KIF/KIF.h>
#import <objc/runtime.h>

@implementation GrowingTestHelper

+ (void)deactivateAppForDuration:(NSTimeInterval)duration
{
    //如果kif框架此方法支持了iOS11可以去掉此判断,执行kif的方法
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
//        UIApplication *application = [UIApplication sharedApplication];
//        [application.delegate applicationWillResignActive:application];
//        [application.delegate applicationDidEnterBackground:application];
//        [tester waitForTimeInterval:duration];
//        [application.delegate applicationWillEnterForeground:application];
//        [application.delegate applicationDidBecomeActive:application];
//    } else {
//        [system deactivateAppForDuration:duration];
//    }
    
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    [tester waitForTimeInterval:duration];
}

+ (void)reactivateApp {
    [self isOpenApp:@"GrowingIO.GrowingIOTest"];
    [tester waitForTimeInterval:1];
}

// 暴力打开某个APP  = 。=   如果可以打开。直接打开不解释
// iOS11可用
+ (BOOL)isOpenApp:(NSString*)appIdentifierName {
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    BOOL isOpenApp = [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:appIdentifierName];
    return isOpenApp;
}

@end
