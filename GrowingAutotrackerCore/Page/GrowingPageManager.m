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
#import "GrowingAutotrackConfiguration.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIViewController+GrowingNode.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingTrackerCore/Event/GrowingCustomEvent.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingULAppLifecycle.h"
#import "GrowingULViewControllerLifecycle.h"

@interface GrowingPageManager () <GrowingULViewControllerLifecycleDelegate, GrowingEventInterceptor>

@property (nonatomic, copy) NSString *lastPagePath;
@property (nonatomic, assign) long long lastPageTimestamp;
@property (nonatomic, strong) NSPointerArray *visiblePages;
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
        GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if (configuration.customEventWithPath) {
            [[GrowingEventManager sharedInstance] addInterceptor:self];
        }
        [GrowingULViewControllerLifecycle.sharedInstance addViewControllerLifecycleDelegate:self];
    });
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder *_Nullable)builder {
    if (builder) {
        if ([builder isMemberOfClass:[GrowingCustomBuilder class]]) {
            // Hybrid触发的HybridCustomEvent将在生成时携带path，不走此处的逻辑
            // Flutter触发的CustomEvent与原生相同，在此处判断后携带path
            if (self.lastPagePath && self.lastPagePath.length > 0) {
                ((GrowingCustomBuilder *)builder).setPath(self.lastPagePath.copy);
            }
        } else if ([builder isMemberOfClass:[GrowingPageBuilder class]]) {
            // 原生或Flutter生成PAGE事件
            GrowingPageBuilder *pageBuilder = (GrowingPageBuilder *)builder;
            self.lastPagePath = pageBuilder.path;
            self.lastPageTimestamp = pageBuilder.timestamp;
        }
    }
}

#pragma mark - GrowingULViewControllerLifecycleDelegate

- (void)viewControllerDidLoad:(UIViewController *)controller {
    if (controller.growingPageAlias == nil /* !page.isAutotrack */) {
        // 首次进入该controller，获取初始化autotrackPage配置
        GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
        if ([configuration isKindOfClass:[GrowingAutotrackConfiguration class]]) {
            GrowingAutotrackConfiguration *autotrackConfiguration = (GrowingAutotrackConfiguration *)configuration;
            NSString *controllerClass = NSStringFromClass([controller class]);
            if (autotrackConfiguration.autotrackAllPages) {
                controller.growingPageAlias = controllerClass;
            } else if (autotrackConfiguration.autotrackPagesWhiteList != nil) {
                controller.growingPageAlias = autotrackConfiguration.autotrackPagesWhiteList[controllerClass];
            }
        }
    }
}

- (void)viewControllerDidAppear:(UIViewController *)controller {
    if (![self isPrivateViewController:controller]) {
        GrowingPage *page = [self createdViewControllerPage:controller];

        if (!self.visiblePages) {
            self.visiblePages = [NSPointerArray weakObjectsPointerArray];
        }

        if (![self.visiblePages.allObjects containsObject:page]) {
            [self.visiblePages addPointer:(__bridge void *)page];
        }
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
                                      .setPath([NSString stringWithFormat:@"/%@", page.alias])
                                      .setTimestamp(page.showTimestamp)
                                      .setAttributes(page.attributes);

    // 发送事件前才去获取页面来源，避免造成额外耗时
    GrowingPage *referralPage = [self findProbableReferralPage:page];
    if (referralPage && referralPage.alias && referralPage.alias.length > 0) {
        ((GrowingPageBuilder *)builder).setReferralPage([NSString stringWithFormat:@"/%@", referralPage.alias]);
    }

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

- (GrowingPage *)findProbableReferralPage:(GrowingPage *)page {
    [self.visiblePages compact];
    NSArray<GrowingPage *> *visiblePages = [[[self.visiblePages allObjects]
        filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GrowingPage *obj, NSDictionary *_) {
            return obj != nil && obj != page && ![NSStringFromClass(obj.carrier.class) hasPrefix:@"GrowingTK"];
        }]] sortedArrayUsingComparator:^NSComparisonResult(GrowingPage *a, GrowingPage *b) {
        return a.showTimestamp > b.showTimestamp ? NSOrderedDescending : NSOrderedAscending;
    }];
    if (visiblePages.count == 0) {
        return nil;
    }

    // 从最近的几个可见页面开始倒序遍历（最多向前追溯3个）
    NSInteger start = MAX(0, (NSInteger)visiblePages.count - 3);
    for (NSInteger i = visiblePages.count - 1; i >= start; i--) {
        GrowingPage *lastPage = visiblePages[i];
        GrowingPage *lastPageParent = lastPage.parent;
        if (!lastPageParent) {
            continue;
        }

        // 逐级向上比较父节点，判断两者是否有共同父页面
        GrowingPage *pageParent = page.parent;
        while (lastPageParent) {
            if (lastPageParent == pageParent) {
                return lastPage;
            }
            lastPageParent = lastPageParent.parent;
        }
    }

    return [visiblePages lastObject];
}

#pragma mark Visible ViewController

- (NSArray<GrowingPage *> *)allDidAppearPages {
    [self.visiblePages compact];
    return self.visiblePages.allObjects;
}

- (BOOL)isPrivateViewController:(UIViewController *)viewController {
    NSString *vcName = NSStringFromClass([viewController class]);
    return [self.ignoredPrivateControllers containsObject:vcName];
}

- (void)autotrackPage:(UIViewController *)controller
                alias:(NSString *)alias
           attributes:(NSDictionary<NSString *, NSString *> *_Nullable)attributes {
    if (controller == nil) {
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
    while (current && [self isPrivateViewController:current]) {
        current = (UIViewController *)current.growingNodeParent;
    }
    if (!current) {
        return self.currentPage;
    }

    GrowingPage *page = current.growingPageObject;
    if (!page) {
        // 执行到此，执行流程大概是view -> findPageByView
        // view所在viewController必定到了viewDidAppear生命周期
        // 一般来说，page对象在viewDidAppear时就已创建，此处兼容page对象未生成的特殊情况，比如：
        // 用户未在自定义的ViewController viewDidAppear中调用super viewDidAppear
        // 或者，SDK的初始化在ViewController的生命周期之后
        page = [self createdPage:current];
    }
    return page;
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
    [self.visiblePages compact];
    return self.visiblePages.allObjects.lastObject;
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
