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

+ (void)deactivateAppForDuration:(NSTimeInterval)duration {
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    [tester waitForTimeInterval:duration];
}

+ (void)reactivateApp {
    [self isOpenApp:@"GrowingIO.GrowingIOTest"];
    [tester waitForTimeInterval:1];
}

// iOS11可用
+ (BOOL)isOpenApp:(NSString*)appIdentifierName {
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    BOOL isOpenApp = [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:appIdentifierName];
    return isOpenApp;
}

@end
