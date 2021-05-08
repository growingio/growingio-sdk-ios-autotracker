//
//  AppDelegate.m
//  GrowingExample
//
//  Created by GrowingIO on 14/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "AppDelegate.h"

//#import <Bugly/Bugly.h>
#import <UserNotifications/UserNotifications.h>

#import "GIODataProcessOperation.h"
//使用md5加密
#import <CommonCrypto/CommonDigest.h>
#import "GrowingAutotracker.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import <CoreServices/CoreServices.h>
static NSString *const kGrowingProjectId = @"91eaf9b283361032";

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [Bugly startWithAppId:@"93004a21ca"];
    // Config GrowingIO
    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithProjectId:kGrowingProjectId];
    configuration.debugEnabled = YES;
//    configuration.impressionScale = 1.0;
    
    // 暂时设置host为mocky链接，防止请求404，实际是没有上传到服务器的，正式使用请去掉，或设置正确的host
//    configuration.dataCollectionServerHost = @"https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306";

    [GrowingAutotracker startWithConfiguration:configuration launchOptions:launchOptions];
//    [GrowingTracker startWithConfiguration:configuration launchOptions:launchOptions];
    [[GrowingAutotracker sharedInstance] setLocation:[@30.11 doubleValue] longitude:[@32.22 doubleValue]];
    // 自动化测试会有授权弹窗
 //   [self registerRemoteNotification];

    return YES;
}

/** 注册 APNs */
- (void)registerRemoteNotification {
    if (@available(iOS 10, *)) {
        //  10以后的注册方式
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        //监听回调事件
        // iOS 10 使用以下方法注册，才能得到授权，注册通知以后，会自动注册 deviceToken，如果获取不到
        // deviceToken，Xcode8下要注意开启 Capability->Push Notification。
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                  if (granted) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [[UIApplication sharedApplication] registerForRemoteNotifications];
                                      });
                                  }
                              }];

    } else if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =
                UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

/** 远程通知注册成功委托 */
- (void)                             application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSInteger count = deviceToken.length;
    for (NSInteger i = 0; i < count; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i] & 0xff];
    }

    NSLog(@"推送Token 字符串：%@", deviceTokenString);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知"
                                                                   message:@"点击一下呗"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知1"
                                                                   message:@"点击一下呗"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];
}
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
//    return NO;
//}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return NO;
//}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
////    if ([Growing handleURL:url]) {
////        return YES;
////    }
//    return NO;
//}

// universal Link执行
- (BOOL) application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
  restorationHandler:(void (^)(NSArray<id <UIUserActivityRestoring>> *_Nullable))restorationHandler {
//    [Growing handleURL:userActivity.webpageURL];
    restorationHandler(nil);
    return YES;
}

#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    UISceneConfiguration *config = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//    return config;
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    return NO;
}
#pragma mark - 生命周期

// xcode11 以后 AppDelegate.m文件没有了APP的生命周期,为了自动化测试用例添加
- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"状态** 将要进入前台");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"状态** 已经活跃");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"状态** 将要进入后台");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"状态** 已经进入后台");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"状态** 将要退出程序");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    return NO;
}


@end
