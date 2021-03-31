//
// GrowingDeepLinkTrack.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/27.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "GrowingAppDelegateAutotracker.h"
#import "GrowingSceneDelegateAutotracker.h"
#import "GrowingDeepLinkHandler.h"
#import "GrowingSwizzle.h"

#import "GrowingCocoaLumberjack.h"
#import "GrowingASLLoggerFormat.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

@implementation GrowingAppDelegateAutotracker

+ (BOOL)isUseScene {
    NSDictionary *sceneManifest = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIApplicationSceneManifest"];
    NSArray *rols = [[sceneManifest objectForKey:@"UISceneConfigurations"] objectForKey:@"UIWindowSceneSessionRoleApplication"];
    if (rols.count == 0) {
        return NO;
    }
    for (NSDictionary *dic in rols) {
        NSString *class = [dic objectForKey:@"UISceneDelegateClassName"];
        if (class) {
            return YES;
        }
    }
    return NO;
}

+ (void)track {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSObject* delegate = [UIApplication sharedApplication].delegate;
        BOOL useUIScene = NO;
        if (@available(iOS 13.0, *)) {
            useUIScene = [self isUseScene];
        }
        
        if (!useUIScene) {
            //url scheme 跳转
            if ([delegate respondsToSelector:@selector(application:openURL:options:)]) {
                SEL sel = @selector(application:openURL:options:);
                Method method = class_getInstanceMethod(delegate.class,sel);
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,UIApplication *application,NSURL *url,NSDictionary<UIApplicationOpenURLOptionsKey, id> * options) {
                    [GrowingDeepLinkHandler handlerUrl:url];
                    BOOL (*tempImp)(id obj, SEL sel,UIApplication *application,NSURL *url,NSDictionary<UIApplicationOpenURLOptionsKey, id> * options) = (void*)originImp;
                    return tempImp(target,sel,application,url,options);
                }));
            }else if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
                SEL sel = @selector(application:openURL:sourceApplication:annotation:);
                Method method = class_getInstanceMethod(delegate.class,sel);
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,UIApplication *application,NSURL *url,NSString* sourceApplication,id annotation) {
                    [GrowingDeepLinkHandler handlerUrl:url];
                    BOOL (*tempImp)(id obj, SEL sel,UIApplication *application,NSURL *url,NSString* sourceApplication,id annotation) = (void*)originImp;
                    return tempImp(target,sel,application,url,sourceApplication,annotation);
                }));
            } else if ([delegate respondsToSelector:@selector(application:handleOpenURL:)]) {
                SEL sel = @selector(application:handleOpenURL:);
                Method method = class_getInstanceMethod(delegate.class,sel);
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,UIApplication *application,NSURL *url) {
                    [GrowingDeepLinkHandler handlerUrl:url];
                    BOOL (*tempImp)(id obj, SEL sel,UIApplication *application,NSURL *url) = (void*)originImp;
                    return tempImp(target,sel,application,url);
                }));
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"请在%@实例中实现application:openURL:options:以适配UrlScheme跳转",NSStringFromClass(delegate.class)] userInfo:nil];
                //no more anyone imp exist
                // TODO:add method: application:openURL:options:
                // 时序在UIApplicationMain之后，无法干预urlscheme跳转问题
            }
            
            //deeplink
            if ([delegate respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
                SEL sel = @selector(application:continueUserActivity:restorationHandler:);
                Method method = class_getInstanceMethod(delegate.class,sel);
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,UIApplication *application,NSUserActivity *userActivity,void (^restorationHandler)(NSArray<id <UIUserActivityRestoring>> *)) {
                    [GrowingDeepLinkHandler handlerUrl:userActivity.webpageURL];
                    BOOL (*tempImp)(id obj, SEL sel,UIApplication *application,NSUserActivity *userActivity,void (^restorationHandler)(NSArray<id <UIUserActivityRestoring>> *)) = (void*)originImp;
                    return tempImp(target,sel,application,userActivity,restorationHandler);
                }));
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"请在%@实例中实现application:continueUserActivity:restorationHandler:以适配DeepLink跳转",NSStringFromClass(delegate.class)] userInfo:nil];
            }
            
        } else {
            //为什么不hook方法 application:configurationForConnectingSceneSession:options:
            //https://stackoverflow.com/questions/63520008/why-is-uiapplicationdelegate-method-application-configurationforconnectingop
            if (@available(iOS 13.0, *)) {
                NSDictionary *sceneManifest = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIApplicationSceneManifest"];
                NSArray *rols = [[sceneManifest objectForKey:@"UISceneConfigurations"] objectForKey:@"UIWindowSceneSessionRoleApplication"];
                if (rols.count == 0) {
                    return;
                }
                for (NSDictionary *dic in rols) {
                    NSString *classname = [dic objectForKey:@"UISceneDelegateClassName"];
                    if (classname) {
                        Class cls = NSClassFromString(classname);
                        [GrowingSceneDelegateAutotracker track:cls];
                    }
                }

            }
        }
    });
}




@end
