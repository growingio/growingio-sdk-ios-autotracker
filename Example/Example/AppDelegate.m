//
//  AppDelegate.m
//  GrowingExample
//
//  Created by GrowingIO on 14/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <GrowingToolsKit/GrowingToolsKit.h>
//@import FirebaseCore;
//@import FirebaseAnalytics;

//#import <GoogleAnalytics/GAI.h>
//#import <GoogleAnalytics/GAIDictionaryBuilder.h>

static NSString *const kGrowingProjectId = @"bc675c65b3b0290e";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GrowingToolsKit start];
    
    // Config GrowingIO
    GrowingSDKConfiguration *configuration = [GrowingSDKConfiguration configurationWithProjectId:kGrowingProjectId];
    configuration.debugEnabled = YES;
    configuration.idMappingEnabled = YES;
    // configuration.dataSourceIds = @{@"UA-XXXX-Y" : @"1244578"};

    // 暂时设置host为mocky链接，防止请求404，实际是没有上传到服务器的，正式使用请去掉，或设置正确的host
    configuration.dataCollectionServerHost = @"https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306";

    [GrowingSDK startWithConfiguration:configuration launchOptions:launchOptions];

    // 1. 前往 https://console.firebase.google.com/u/0/project/ga-adapter-e9417/settings/general 下载GoogleService-Info.plist
    // 2. 将GoogleService-Info.plist添加到项目
    // 3. 反注释下面这一行代码，启动FirebaseAnalytics
//    [FIRApp configure];
    
//    GAI *gai = [GAI sharedInstance];
//    id<GAITracker> tracker = [gai trackerWithName:@"GA3Tracker" trackingId:@"UA-XXXX-Y"];
//    gai.logger.logLevel = kGAILogLevelVerbose;
//    [tracker send:@{@"key" : @"value"}];
    
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
