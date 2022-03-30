//
// GrowingStatusTracker.m
// GrowingAnalytics
//
//  Created by sheng on 2020/12/28.
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

#import "Modules/WebCircle/GrowingStatusBarAutotracker.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "GrowingTrackerCore/Manager/GrowingStatusBarEventManager.h"

@implementation GrowingStatusBarAutotracker

+ (void)track {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            SEL sel = @selector(handleTapAction:);
            Method method = class_getInstanceMethod(NSClassFromString(@"UIStatusBarManager"),sel);
            if (method) {
                IMP originImp = method_getImplementation(method);
                method_setImplementation(method, imp_implementationWithBlock(^(id target,id obj) {
                    void (*tempImp)(id,SEL,id) = (void*)originImp;
                    tempImp(target,sel,obj);
                    [[GrowingStatusBarEventManager sharedInstance] dispatchTapStatusBar:obj];
                }));
            }
#pragma clang diagnostic pop
        }
        
    });
}

@end
