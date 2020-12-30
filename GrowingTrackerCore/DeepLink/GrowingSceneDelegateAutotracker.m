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


#import "GrowingSceneDelegateAutotracker.h"
#import <GrowingDeepLinkHandler.h>

#import "GrowingCocoaLumberjack.h"
#import "GrowingASLLoggerFormat.h"


#import <objc/runtime.h>
#import <objc/message.h>

@implementation GrowingSceneDelegateAutotracker

+ (void)track:(Class)delegateClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            //url scheme 跳转
            SEL sel = @selector(scene:openURLContexts:);
            class_getInstanceMethod(delegateClass, sel);
            Method method = class_getInstanceMethod(delegateClass,sel);
            if (method) {
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,UIScene *scene,NSSet<UIOpenURLContext *> *URLContexts) {
                    NSURL *url = URLContexts.allObjects.firstObject.URL;
                    if (url) {
                        [GrowingDeepLinkHandler handlerUrl:url];
                    }
                    
                    void (*tempImp)(id obj, SEL sel,UIScene *scene,NSSet<UIOpenURLContext *> *URLContexts) = (void*)originImp;
                    tempImp(target,sel,scene,URLContexts);
                }));
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"在iOS13以上，请在%@实例中实现scene:openURLContexts:以适配UrlScheme",NSStringFromClass(delegateClass)] userInfo:nil];
            }
            //hook deeplink method
            sel = @selector(scene:continueUserActivity:);
            class_getInstanceMethod(delegateClass, sel);
            method = class_getInstanceMethod(delegateClass,sel);
            if (method) {
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,UIScene *scene,NSUserActivity *userActivity) {
                    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
                        NSURL *url = userActivity.webpageURL;
                        if (url) {
                            [GrowingDeepLinkHandler handlerUrl:url];
                        }
                    }
                    void (*tempImp)(id obj, SEL sel,UIScene *scene,NSUserActivity *userActivity) = (void*)originImp;
                    tempImp(target,sel,scene,userActivity);
                }));
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"在iOS13以上，请在%@实例中实现scene:continueUserActivity:以适配DeepLink",NSStringFromClass(delegateClass)] userInfo:nil];
            }
        }
    });
}

@end
