//
//  GrowingPageManager.m
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/4/27.
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

#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIViewController+GrowingNode.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingULAppLifecycle.h"
#import "GrowingULViewControllerLifecycle.h"

@interface GrowingPageManager () <GrowingULViewControllerLifecycleDelegate>

@property (nonatomic, strong) NSPointerArray *visiablePages;
@property (nonatomic, strong) NSMutableArray<NSString *> *ignoredPrivateControllers;

@end

@implementation GrowingPageManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)start {
    static dispatch_once_t startOnceToken;
    dispatch_once(&startOnceToken, ^{
        [GrowingULViewControllerLifecycle.sharedInstance addViewControllerLifecycleDelegate:self];
    });
}

- (void)viewControllerDidAppear:(UIViewController *)controller {
    if (![self isPrivateViewController:controller]) {
        GrowingPage *page = [self createdViewControllerPage:controller];

        if (!self.visiablePages) {
            self.visiablePages = [NSPointerArray weakObjectsPointerArray];
        }

        if (![self.visiablePages.allObjects containsObject:page]) {
            [self.visiablePages addPointer:(__bridge void *)page];
        }
    }
}

- (void)viewControllerDidDisappear:(UIViewController *)controller {
    if (![self isPrivateViewController:controller]) {
        [self.visiablePages.allObjects
            enumerateObjectsWithOptions:NSEnumerationReverse
                             usingBlock:^(GrowingPage *page, NSUInteger idx, BOOL *_Nonnull stop) {
                                 if (page.carrier == controller) {
                                     if (page.parent != nil) {
                                         [page.parent removeChildrenPage:page];
                                     }
                                     [self.visiablePages removePointerAtIndex:idx];
                                 }
                             }];
    }
}

- (GrowingPage *)createdViewControllerPage:(UIViewController *)controller {
    GrowingPage *page = [controller growingPageObject];
    if (!page) {
        page = [self createdPage:controller];
    } else {
        [page refreshShowTimestamp];
    }

    if (page.isAutotrack) {
        // 发送PAGE事件
        [self sendPageEventWithPage:page];
    }
    return page;
}

- (void)sendPageEventWithPage:(GrowingPage *)page {
    GrowingBaseBuilder *builder = GrowingPageEvent.builder.setTitle(page.title)
                                      .setPath(page.alias)
                                      .setTimestamp(page.showTimestamp)
                                      .setAttributes(page.attributes);
    [[GrowingEventManager sharedInstance] postEventBuilder:builder];
}

- (GrowingPage *)createdPage:(UIViewController *)viewController {
    GrowingPage *page = [GrowingPage pageWithCarrier:viewController];
    page.parent = [self findParentPage:viewController];
    if (page.parent != nil) {
        [page.parent addChildrenPage:page];
    }
    [viewController setGrowingPageObject:page];
    return page;
}

- (GrowingPage *)findParentPage:(UIViewController *)carrier {
    UIViewController *controller = (UIViewController *)carrier.growingNodeParent;
    if (!controller) {
        return nil;
    }

    GrowingPage *page = [controller growingPageObject];
    if (!page) {
        // 一般来说，page对象在viewDidAppear时就已创建
        // 此处兼容viewDidAppear未执行的特殊情况，比如：
        // 用户未在自定义的ViewController viewDidAppear中调用super viewDidAppear
        page = [self createdPage:controller];
    }
    return page;
}

#pragma mark Visiable ViewController

- (NSArray<GrowingPage *> *)allDidAppearPages {
    return self.visiablePages.allObjects;
}

- (BOOL)isDidAppearController:(UIViewController *)vc {
    for (GrowingPage *page in self.visiablePages) {
        if (page.carrier == vc) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isPrivateViewController:(UIViewController *)viewController {
    if (!viewController) {
        return NO;
    }
    NSString *vcName = NSStringFromClass([viewController class]);
    return [self.ignoredPrivateControllers containsObject:vcName];
}

- (GrowingPage *)findPageByViewController:(UIViewController *)controller {
    while ([self isPrivateViewController:controller]) {
        controller = (UIViewController *)controller.growingNodeParent;
    }

    if (!controller) {
        return self.currentPage;
    }

    GrowingPage *page = controller.growingPageObject;
    if (!page) {
        // 执行到此，执行流程大概是view -> findPageByView -> findPageByViewController
        // view所在viewcontroller必定到了viewDidAppear生命周期
        // 一般来说，page对象在viewDidAppear时就已创建，此处兼容page对象未生成的特殊情况，比如：
        // 用户未在自定义的ViewController viewDidAppear中调用super viewDidAppear
        page = [self createdPage:controller];
    }
    return page;
}

- (void)autotrackPage:(UIViewController *)controller
                alias:(NSString *)alias
           attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes {
    if (controller == nil) {
        return;
    }
    if ([NSString growingHelper_isBlankString:alias]) {
        return;
    }
    if (attributes != nil && [GrowingArgumentChecker isIllegalAttributes:attributes]) {
        return;
    }

    BOOL needAutotrackPage = NO;
    GrowingPage *page = controller.growingPageObject;
    if (!page) {
        // 如果没有page对象，那么可能是(1)controller还未执行到viewDidAppear；
        // (2)controller到了viewDidAppear但未生成page对象，这里兼容(2)
        if (controller.isViewLoaded && controller.view.window) {
            page = [self createdPage:controller];
        }
    }
    if (page && !page.isAutotrack) {
        // 当前页面已经进入viewDidAppear，但未发送过PAGE事件，需要补发
        needAutotrackPage = YES;
    }

    controller.growingPageAlias = alias;
    controller.growingPageAttributes = attributes;
    if (needAutotrackPage) {
        [self sendPageEventWithPage:page];
    }
}

- (GrowingPage *)findPageByView:(UIView *)view {
    UIViewController *current = [view growingHelper_viewController];
    if (!current) {
        return self.currentPage;
    }
    return [self findPageByViewController:current];
}

- (GrowingPage *)findAutotrackPageByPage:(GrowingPage *)page {
    while (page) {
        if (page.isAutotrack) {
            return page;
        }
        page = page.parent;
    }
    return nil;
}

- (GrowingPage *)currentPage {
    return self.visiablePages.allObjects.lastObject;
}

#pragma mark Lazy Load

- (NSMutableArray *)ignoredPrivateControllers {
    if (!_ignoredPrivateControllers) {
        _ignoredPrivateControllers = [NSMutableArray arrayWithArray:@[
            @"UIInputWindowController",
            @"UIActivityGroupViewController",
            @"UIKeyboardHiddenViewController",
            @"UICompatibilityInputViewController",
            @"UISystemInputAssistantViewController",
            @"UIPredictionViewController",
            @"GrowingWindowViewController",
            @"UIApplicationRotationFollowingController",
            @"UIAlertController",
            @"_UIAlertControllerTextFieldViewController",
            @"UICandidateViewController",
            @"UISystemKeyboardDockController",
            @"UIKeyboardCameraViewController",
            @"UIKeyboardCameraRemoteViewController",
        ]];
    }
    return _ignoredPrivateControllers;
}

@end
