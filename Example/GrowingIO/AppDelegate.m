//
//  AppDelegate.m
//  GrowingIOTest
//
//  Created by GIO-baitianyu on 14/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>
#import "GIODataProcessOperation.h"
#import <UserNotifications/UserNotifications.h>
//使用md5加密
#import <CommonCrypto/CommonDigest.h>
#import <GrowingAutoTracker.h>

static NSString * const kProjectIdForGrowingIO = @"0a1b4118dd954ec3bcc69da5138bdb96";

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Growing registerDeeplinkHandler:^(NSDictionary *params, NSTimeInterval processTime, NSError *error) {
        NSString *paramsString = [GIODataProcessOperation convertToJsonStringFromJSON:params];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"deeplink" message:paramsString delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        NSLog(@"deepLink params = %@", params);
    }];
    
    [Bugly startWithAppId:@"93004a21ca"];
    
    // Config GrowingIO
    GrowingConfiguration *configuration = [[GrowingConfiguration alloc] initWithProjectId:kProjectIdForGrowingIO
                                                                            launchOptions:launchOptions];
    [configuration setLogEnabled:YES];
    configuration.samplingRate = 1.0;
    configuration.urlScheme = @"hello_url_scheme";
    
    // 自定义相关host设置
//    [configuration setDataCollectionHost:@"http://k8s-mobile-www.growingio.com"];
//    [configuration setWebSocketHost:@"ws://k8s-mobile-gta.growingio.com"];
//    [configuration setAdvertisementHost:@"http://k8s-mobile-www.growingio.com"];
    
    [Growing startWithConfiguration:configuration];
    [Growing addAutoTrackSwizzles];
    
    // Deep link
    /*
    [Growing doDeeplinkByUrl:[NSURL URLWithString:@"https://datayi.cn/v8adidvJy?a=b&b=c"] callback:^(NSDictionary *params, NSTimeInterval processTime, NSError *error) {
        NSString *paramsString = [params growingHelper_jsonString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"do deeplink" message:paramsString delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        NSLog(@"deepLink params = %@", params);
    }];
    */
    
    
//    //DeepLink回调参数
//    [Growing registerDeeplinkHandler:^(NSDictionary *params, NSError *error) {
//        NSLog(@"==> %@", params);
//        //NSDictionary转NSString
//        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *strhh = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        //弹出信息
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DeepLink回调信息"
//                                                        message:strhh
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil, nil];
//
//        [alert show];
//
//    }];
    
    
    NSString *trackSdkVersion = [Growing getTrackVersion];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"GIO SDK当前版本号：%@;\n 当前手机系统的版本号：%@", trackSdkVersion, systemVersion);

    [self registerRemoteNotification];
    
    return YES;
   
}

/** 注册 APNs */
- (void)registerRemoteNotification {
    if (@available(iOS 10,*)) {
        //  10以后的注册方式
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        //监听回调事件
        //iOS 10 使用以下方法注册，才能得到授权，注册通知以后，会自动注册 deviceToken，如果获取不到 deviceToken，Xcode8下要注意开启 Capability->Push Notification。
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound )
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (granted) {
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          [[UIApplication sharedApplication] registerForRemoteNotifications];
                                      });
                                  }
                              }];
        
    } else if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSInteger count = deviceToken.length;
    for (NSInteger i = 0; i < count; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i] & 0xff];
    }

    NSLog(@"推送Token 字符串：%@", deviceTokenString);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知" message:@"点击一下呗" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知1" message:@"点击一下呗" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([Growing handleURL:url]) {
        return YES;
    }
    return NO;
}

//universal Link执行
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    [Growing handleURL:userActivity.webpageURL];
    return YES;
}


#pragma mark - 生命周期
//xcode11 以后 AppDelegate.m文件没有了APP的生命周期,为了自动化测试用例添加
- (void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@"状态** 将要进入前台");
}
- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"状态** 已经活跃");
}
- (void)applicationWillResignActive:(UIApplication *)application{
    NSLog(@"状态** 将要进入后台");
}
- (void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@"状态** 已经进入后台");
}
- (void)applicationWillTerminate:(UIApplication *)application{
    NSLog(@"状态** 将要退出程序");
}
@end
