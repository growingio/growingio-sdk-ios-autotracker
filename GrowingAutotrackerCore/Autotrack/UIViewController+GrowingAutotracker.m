//
//  UIViewController+GrowingAutoTrack.m
//  GrowingAutoTracker
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

#import "GrowingEventManager.h"
#import "GrowingPage.h"
#import "GrowingPageEvent.h"
#import "GrowingPageManager.h"
#import "GrowingPrivateCategory.h"
#import "GrowingPropertyDefine.h"
#import "GrowingViewControllerLifecycle.h"
#import "UIViewController+GrowingAutotracker.h"
#import "UIViewController+GrowingNode.h"

GrowingPropertyDefine(UIViewController, NSNumber *, growingHook_hasDidAppear, setGrowingHook_hasDidAppear)

    @implementation UIViewController(GrowingAutotracker)

- (void)growing_viewDidAppear:(BOOL)animated {
    [self setGrowingHook_hasDidAppear:@YES];
    [GrowingViewControllerLifecycle.sharedInstance dispatchViewControllerDidAppear:self];

    [self growing_viewDidAppear:animated];
}

- (void)growing_viewDidDisappear:(BOOL)animated {
    [GrowingViewControllerLifecycle.sharedInstance dispatchViewControllerDidDisappear:self];
    [self growing_viewDidDisappear:animated];
}

#pragma mark pageName

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

- (NSString *)growingPageTitle {
    NSString *currentPageName = self.title;
    if (!currentPageName.length) {
        currentPageName = self.navigationItem.title;
    }
    if (!currentPageName.length) {
        currentPageName = self.tabBarItem.title;
    }
    return currentPageName;
}

//- (NSString *)growingNodeName {
//    return @"页面";
//}

- (BOOL)growingHookIsCustomAddVC {
    return !self.growingHook_hasDidAppear.boolValue && self.parentViewController == nil &&
           [UIApplication sharedApplication].keyWindow.rootViewController != self;
}

@end
