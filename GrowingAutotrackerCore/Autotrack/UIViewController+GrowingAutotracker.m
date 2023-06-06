//
//  UIViewController+GrowingAutoTrack.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/23.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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

#import <objc/runtime.h>
#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/GrowingPropertyDefine.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Page/GrowingPageGroup.h"
#import "GrowingAutotrackerCore/Public/GrowingAutotrackConfiguration.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingULViewControllerLifecycle.h"

static char kGrowingPageAutotrackEnabledKey;
static char kGrowingPageObjectKey;
static char kGrowingPageAttributesKey;

@implementation UIViewController (GrowingAutotracker)

- (NSString *)growingPageName {
    NSString *pageName = nil;
    NSString *growingAttributesPageName = [self growingPageAlias];
    if (growingAttributesPageName.length > 0) {
        pageName = growingAttributesPageName;
    } else {
        pageName = NSStringFromClass(self.class);
    }
    return pageName;
}

- (nullable NSString *)growingPageTitle {
    NSString *currentPageName = self.title;
    if (!currentPageName.length) {
        currentPageName = self.navigationItem.title;
    }
    if (!currentPageName.length) {
        currentPageName = self.tabBarItem.title;
    }
    return currentPageName;
}

- (BOOL)growingHookIsCustomAddVC {
    return !self.growingul_didAppear && self.parentViewController == nil &&
           [UIApplication sharedApplication].keyWindow.rootViewController != self;
}

- (void)setGrowingPageObject:(GrowingPageGroup *)page {
    objc_setAssociatedObject(self, &kGrowingPageObjectKey, page, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingPageGroup *)growingPageObject {
    return objc_getAssociatedObject(self, &kGrowingPageObjectKey);
}

GrowingSafeStringPropertyImplementation(growingPageAlias, setGrowingPageAlias)

    - (void)setGrowingPageAttributes : (NSDictionary<NSString *, NSString *> *)attributes {
    [GrowingDispatchManager
                 trackApiSel:_cmd
        dispatchInMainThread:^{
            if (!attributes || ([attributes isKindOfClass:NSDictionary.class] && attributes.count == 0)) {
                objc_setAssociatedObject(self, &kGrowingPageAttributesKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
            } else {
                if ([GrowingArgumentChecker isIllegalAttributes:attributes]) {
                    return;
                }
                objc_setAssociatedObject(self, &kGrowingPageAttributesKey, attributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
            }
        }];
}

- (NSDictionary<NSString *, NSString *> *)growingPageAttributes {
    return [objc_getAssociatedObject(self, &kGrowingPageAttributesKey) copy];
}

- (void)setGrowingAutotrackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self,
                             &kGrowingPageAutotrackEnabledKey,
                             @(enabled),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)growingAutotrackEnabled {
    id enabled = objc_getAssociatedObject(self, &kGrowingPageAutotrackEnabledKey);
    if ([enabled isKindOfClass:NSNumber.class]) {
        return ((NSNumber *)enabled).boolValue;
    }
    
    return NO;
}

//- (BOOL)growingPageDidIgnore {
//    return NO;
//}
//    // judge self firstly
//    GrowingIgnorePolicy selfPolicy = self.growingPageIgnorePolicy;
//    if (GrowingIgnoreAll == selfPolicy || GrowingIgnoreSelf == selfPolicy) {
//        return YES;
//    }
//
//    // judge parent
//    UIViewController *current = self;
//    while (current.parentViewController) {
//        UIViewController *parent = current.parentViewController;
//        GrowingIgnorePolicy parentPolicy = parent.growingPageIgnorePolicy;
//
//        if (GrowingIgnoreChildren == parentPolicy || GrowingIgnoreAll == parentPolicy) {
//            return YES;
//        }
//
//        current = parent;
//    }
//
//    return NO;
//}

@end
