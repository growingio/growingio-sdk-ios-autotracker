//
//  AppDelegate.m
//  GrowingExample
//
//  Created by GrowingIO on 14/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

#if __has_include(<GrowingToolsKit/GrowingToolsKit.h>)
#import <GrowingToolsKit/GrowingToolsKit.h>
#else
#import "GrowingToolsKit.h"
#endif

//#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DELAY_INITIALIZED
#if defined(SDKAPM)
    [GrowingAPM didFinishLaunching];
#endif
#endif
    
    [GrowingToolsKit start];
    
#if !DELAY_INITIALIZED
    [self SDK3rdStart];
#endif
    
//    [Bugly startWithAppId:@"93004a21ca"];
    
    return YES;
}

- (void)SDK3rdStart {
    GrowingSDKConfiguration *configuration = [GrowingSDKConfiguration configurationWithAccountId:@"0a1b4118dd954ec3bcc69da5138bdb96"];
    configuration.debugEnabled = YES;
    configuration.idMappingEnabled = YES;
    configuration.dataSourceId = @"ab555003531e0fd1";
    
#if defined(SDKADSMODULE)
    configuration.ASAEnabled = YES;
    configuration.deepLinkHost = @"https://link.growingio.com";
    configuration.deepLinkCallback = ^(NSDictionary * _Nullable params, NSTimeInterval processTime, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error = %@", error);
            return;
        }
        NSLog(@"deepLinkCallback params = %@, processTime = %f", params, processTime);
    };
#endif
    
#if defined(SDKAPMMODULE)
    GrowingAPMConfig *config = GrowingAPMConfig.config;
    config.monitors = GrowingAPMMonitorsCrash | GrowingAPMMonitorsUserInterface;
    configuration.APMConfig = config;
#endif
    
#if defined(SDKABTESTINGMODULE)
    configuration.abTestingServerHost = @"https://ab.growingio.com";
    configuration.abTestingRequestInterval = 5;
#endif
    
#if defined(SDKHybridMODULE)
    GrowingHybridModule.sharedInstance.autoJsSdkInject = YES;
#endif
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [GrowingSDK startWithConfiguration:configuration launchOptions:nil];
#pragma clang diagnostic pop
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Application - applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Application - applicationDidBecomeActive");

#if DELAY_INITIALIZED
    // 如若您需要使用IDFA作为访问用户ID，参考如下代码
    // 调用AppTrackingTransparency相关实现请在ApplicationDidBecomeActive之后，适配iOS 15
    // 参考: https:developer.apple.com/forums/thread/690607?answerId=688798022#688798022
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            // 初始化SDK
            dispatch_async(dispatch_get_main_queue(), ^{
                [self SDK3rdStart];
            });
        }];
    } else {
        // 初始化SDK
        dispatch_async(dispatch_get_main_queue(), ^{
            [self SDK3rdStart];
        });
    }
#endif
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
