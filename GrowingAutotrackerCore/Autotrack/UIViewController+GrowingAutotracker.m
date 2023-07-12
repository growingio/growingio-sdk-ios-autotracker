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
#import "GrowingAutotrackerCore/Autotrack/GrowingPropertyDefine.h"
#import "GrowingAutotrackerCore/Page/GrowingPage.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingULViewControllerLifecycle.h"

static char kGrowingPageObjectKey;
static char kGrowingPageAttributesKey;

@implementation UIViewController (GrowingAutotracker)

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

- (void)setGrowingPageObject:(GrowingPage *)page {
    objc_setAssociatedObject(self, &kGrowingPageObjectKey, page, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingPage *)growingPageObject {
    return objc_getAssociatedObject(self, &kGrowingPageObjectKey);
}

GrowingSafeStringPropertyImplementation(growingPageAlias, setGrowingPageAlias)

- (void)setGrowingPageAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
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

@end
