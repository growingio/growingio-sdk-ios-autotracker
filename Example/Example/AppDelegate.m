//
//  AppDelegate.m
//  GrowingExample
//
//  Created by GrowingIO on 14/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

static NSString *const kGrowingProjectId = @"bc675c65b3b0290e";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Config GrowingIO
    GrowingSDKConfiguration *configuration = [GrowingSDKConfiguration configurationWithProjectId:kGrowingProjectId];
    configuration.debugEnabled = YES;
    configuration.idMappingEnabled = YES;

    // 暂时设置host为mocky链接，防止请求404，实际是没有上传到服务器的，正式使用请去掉，或设置正确的host
    configuration.dataCollectionServerHost = @"https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306";

    [GrowingSDK startWithConfiguration:configuration launchOptions:launchOptions];
    [[GrowingSDK sharedInstance] setLocation:[@30.11 doubleValue] longitude:[@32.22 doubleValue]];
    return YES;
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Application - applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Application - applicationDidBecomeActive");

    // 如若您需要使用IDFA作为访问用户ID，参考如下代码
    /**
     // 调用AppTrackingTransparency相关实现请在ApplicationDidBecomeActive之后，适配iOS 15
     // 参考: https:developer.apple.com/forums/thread/690607?answerId=688798022#688798022
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            // 初始化SDK
        }];
    } else {
        // 初始化SDK
    }
     */
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"Application - applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Application - applicationDidEnterBackground");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application - applicationWillTerminate");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return YES;
}

// Universal Link
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    restorationHandler(nil);
    return YES;
}

@end
