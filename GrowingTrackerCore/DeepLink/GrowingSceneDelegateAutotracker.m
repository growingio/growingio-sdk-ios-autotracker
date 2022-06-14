//
// GrowingSceneDelegateAutotracker.m
// GrowingAnalytics
//
//  Created by sheng on 2020/11/30.
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

#import <UIKit/UIKit.h>
#import "GrowingTrackerCore/DeepLink/GrowingSceneDelegateAutotracker.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/LogFormat/GrowingASLLoggerFormat.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation GrowingSceneDelegateAutotracker

+ (void)track:(Class)delegateClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            // URL Scheme
            SEL sel = @selector(scene:openURLContexts:);
            class_getInstanceMethod(delegateClass, sel);
            Method method = class_getInstanceMethod(delegateClass,sel);
            if (method) {
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,
                                                                               UIScene *scene,
                                                                               NSSet<UIOpenURLContext *> *URLContexts) {
                    NSURL *url = URLContexts.allObjects.firstObject.URL;
                    if (url) {
                        [GrowingDeepLinkHandler handlerUrl:url];
                    }
                    
                    void (*tempImp)(id, SEL, UIScene *, NSSet<UIOpenURLContext *> *) = (void*)originImp;
                    tempImp(target, sel, scene, URLContexts);
                }));
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"在iOS13以上，请在%@实例中实现scene:openURLContexts:以适配UrlScheme",
                                                       NSStringFromClass(delegateClass)]
                                             userInfo:nil];
            }
            // DeepLink
            sel = @selector(scene:continueUserActivity:);
            class_getInstanceMethod(delegateClass, sel);
            method = class_getInstanceMethod(delegateClass,sel);
            if (method) {
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,
                                                                               UIScene *scene,
                                                                               NSUserActivity *userActivity) {
                    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
                        NSURL *url = userActivity.webpageURL;
                        if (url) {
                            [GrowingDeepLinkHandler handlerUrl:url];
                        }
                    }
                    void (*tempImp)(id, SEL, UIScene *, NSUserActivity *) = (void*)originImp;
                    tempImp(target, sel, scene, userActivity);
                }));
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"在iOS13以上，请在%@实例中实现scene:continueUserActivity:以适配DeepLink",
                                                       NSStringFromClass(delegateClass)]
                                             userInfo:nil];
            }
            // 冷启动
            sel = @selector(scene:willConnectToSession:options:);
            class_getInstanceMethod(delegateClass, sel);
            method = class_getInstanceMethod(delegateClass,sel);
            if (method) {
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,
                                                                               UIScene *scene,
                                                                               UISceneSession *session,
                                                                               UISceneConnectionOptions *connectionOptions) {
                    /*
                     
                     If your app has opted into Scenes, and your app is not running, the system delivers the
                     URL to the scene(_:willConnectTo:options:) delegate method after launch, and to
                     scene(_:openURLContexts:) when your app opens a URL while running or suspended in memory.
                     link: https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app
                     
                     If your app has opted into Scenes, and your app is not running, the system delivers the
                     universal link to the scene(_:willConnectTo:options:) delegate method after launch, and
                     to scene(_:continue:) when the universal link is tapped while your app is running or
                     suspended in memory.
                     link: https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app
                     
                     */
                    NSURL *url = nil;
                    NSUserActivity *userActivity = connectionOptions.userActivities.allObjects.firstObject;
                    if (userActivity) {
                        if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
                            url = userActivity.webpageURL;
                        }
                    } else {
                        url = connectionOptions.URLContexts.allObjects.firstObject.URL;
                    }
                    
                    if (url) {
                        [GrowingDeepLinkHandler handlerUrl:url];
                    }
                    
                    void (*tempImp)(id, SEL, UIScene *, UISceneSession *, UISceneConnectionOptions *) = (void*)originImp;
                    tempImp(target, sel, scene, session, connectionOptions);
                }));
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"在iOS13以上，请在%@实例中实现scene:willConnectToSession:options:以适配冷启动圈选、冷启动DeepLink等场景",
                                                       NSStringFromClass(delegateClass)]
                                             userInfo:nil];
            }
        }
    });
}

@end
