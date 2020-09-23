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


#import "UIViewController+GrowingAutoTrack.h"
#import "GrowingEventManager.h"
#import "GrowingPropertyDefine.h"
#import "GrowingInstance.h"
#import "GrowingBroadcaster.h"
#import "UIViewController+GrowingNode.h"
#import "GrowingPageManager.h"
#import "GrowingPage.h"
#import "GrowingPageEvent.h"
#import "GrowingPageManager.h"

GrowingPropertyDefine(UIViewController, NSNumber*, growingHook_hasDidAppear, setGrowingHook_hasDidAppear)

@implementation UIViewController (GrowingAutoTrack)

- (void)growing_viewDidAppear:(BOOL)animated {
    //处理viewDidAppear
    [self handleViewDidAppear];
    //调用系统默认的viewDidAppear实现
    [self growing_viewDidAppear:animated];
}

- (void)handleViewDidAppear {
    //判断是否过滤
    if ([[GrowingPageManager sharedInstance] isViewControllerIgnored:self]) {
        return;
    }
    //创建page对象，并发送Event
    [[GrowingPageManager sharedInstance] createdViewControllerPage:self];
    //给绑定的属性变量赋值
    [self setGrowingHook_hasDidAppear:@YES];
    //加入弱引用集合Set中
    [[GrowingPageManager sharedInstance] addDidAppearController:self];
    //生命周期相关
    [self sendViewControllerLifecycleChanged:GrowingVCLifecycleDidAppear];
}

- (void)growing_viewDidDisappear:(BOOL)animated {
    [self handleViewDidDisappear];
    
    [self growing_viewDidDisappear:animated];
}

- (void)handleViewDidDisappear {
    
    if ([[GrowingPageManager sharedInstance] isViewControllerIgnored:self]) {
        return;
    }
    
    [[GrowingPageManager sharedInstance] removeDidDisappearController:self];
}

- (void)sendViewControllerLifecycleChanged:(GrowingVCLifecycle)lifecycle {
    [[GrowingBroadcaster sharedInstance] notifyEvent:@protocol(GrowingViewControlerLifecycleMessage)
                                          usingBlock:^(id<GrowingMessageProtocol>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(viewControllerLifecycleDidChanged:)]) {
            id<GrowingViewControlerLifecycleMessage> message = (id<GrowingViewControlerLifecycleMessage>)obj;
            [message viewControllerLifecycleDidChanged:lifecycle];
        }
    }];
}

#pragma mark pageName
- (NSString *)growingPageName {
    NSString * pageName = nil;
    NSString * growingAttributesPageName = [self growingPageAlias];
    if (growingAttributesPageName.length > 0) {
        pageName = growingAttributesPageName;
    } else {
        pageName = NSStringFromClass(self.class);
    }
    return pageName;
}

- (NSString *)growingPageTitle {
    NSString * currentPageName = self.title;
    if (!currentPageName.length) {
        currentPageName = self.navigationItem.title;
    }
    if (!currentPageName.length) {
        currentPageName = self.tabBarItem.title;
    }
    return currentPageName;
}

- (NSString *)growingNodeName {
    return @"页面";
}

- (void)growingOutOfLifetimeShow {
    [[GrowingPageManager sharedInstance] createdViewControllerPage:self];
}

- (BOOL)growingHookIsCustomAddVC {
    return !self.growingHook_hasDidAppear.boolValue
            && self.parentViewController == nil
            && [UIApplication sharedApplication].keyWindow.rootViewController != self;
}

- (BOOL)growingCanResendPage {
    return !self.view.window.growingNodeIsBadNode;
}

- (NSTimeInterval)growingTimeIntervalForLastClick {
    return 0;
}

@end
