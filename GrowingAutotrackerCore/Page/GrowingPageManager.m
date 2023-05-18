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
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/Autotrack/GrowingPageEvent.h"
#import "GrowingAutotrackerCore/Page/GrowingPage.h"
#import "GrowingAutotrackerCore/Page/GrowingPageGroup.h"
#import "GrowingAutotrackerCore/Private/GrowingPrivateCategory.h"
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIViewController+GrowingNode.h"
#import "GrowingAutotrackerCore/Page/UIViewController+GrowingPageHelper.h"
#import "GrowingULViewControllerLifecycle.h"
#import "GrowingULAppLifecycle.h"

@interface GrowingPageManager () <GrowingULViewControllerLifecycleDelegate>

@property (nonatomic, strong) NSHashTable *visiableControllersTable;
@property (nonatomic, strong) NSPointerArray *visiableControllersArray;

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
    if (![self isPrivateViewControllerIgnored:controller]) {
        [self createdViewControllerPage:controller];
        [self addDidAppearController:controller];
    }
}

- (void)viewControllerDidDisappear:(UIViewController *)controller {
    if (![self isPrivateViewControllerIgnored:controller]) {
        [self removeDidDisappearController:controller];
    }
}

- (void)createdViewControllerPage:(UIViewController *)viewController {
    GrowingPageGroup *page = [viewController growingPageHelper_getPageObject];
    if (page == nil) {
        page = [self createdPage:viewController];
    } else {
        [page refreshShowTimestamp];
    }

    if (!page.isIgnored) {
        //发送page事件
        [self sendPageEventWithPage:page];
    } else {
        GIOLogDebug(@"createdViewControllerPage: path = %@ is ignored", page.path);
    }
}


- (void)sendPageEventWithPage:(GrowingPage *)page {
    GrowingBaseBuilder *builder = GrowingPageEvent.builder
                                                  .setTitle(page.title)
                                                  .setPath(page.path)
                                                  .setTimestamp(page.showTimestamp)
                                                  .setAttributes([page.carrier growingPageAttributes]);
    [[GrowingEventManager sharedInstance] postEventBuilder:builder];
}

- (void)addPageAlias:(GrowingPage *)page {
    NSString *alias = [page.carrier growingPageAlias];
    if (![NSString growingHelper_isBlankString:alias]) {
        page.alias = alias;
    }
}

- (GrowingPageGroup *)createdPage:(UIViewController *)viewController {
    GrowingPageGroup *page = [GrowingPageGroup pageWithCarrier:viewController];
    page.parent = [self findParentPage:viewController];
    if (page.parent != nil) {
        [page.parent addChildrenPage:page];
    }
    [self addPageAlias:page];
    [viewController growingPageHelper_setPageObject:page];
    return page;
}

- (GrowingPageGroup *)findParentPage:(UIViewController *)carrier {
    UIViewController *parentVC = nil;

    if ([carrier isKindOfClass:UIAlertController.class]) {
        parentVC = [self currentViewController];
    } else {
        parentVC = carrier.parentViewController;
    }

    if (parentVC == nil) {
        return nil;
    } else {
        GrowingPageGroup *page = [parentVC growingPageHelper_getPageObject];
        if (page == nil) {
            page = [self createdPage:parentVC];
        }
        return page;
    }
}

#pragma mark Visiable ViewController

- (void)addDidAppearController:(UIViewController *)appearVc {
    if ([self isPrivateViewControllerIgnored:appearVc]) {
        return;
    }
    if (!self.visiableControllersTable) {
        self.visiableControllersTable = [NSHashTable weakObjectsHashTable];
    }

    if (!self.visiableControllersArray) {
        self.visiableControllersArray = [NSPointerArray weakObjectsPointerArray];
    }

    [self.visiableControllersTable addObject:appearVc];
    if (![self.visiableControllersArray.allObjects containsObject:appearVc]) {
        [self.visiableControllersArray addPointer:(__bridge void *)appearVc];
    }
}

- (void)removeDidDisappearController:(UIViewController *)disappearVc {
    if ([self isPrivateViewControllerIgnored:disappearVc]) {
        return;
    }
    [self.visiableControllersTable removeObject:disappearVc];
    [self.visiableControllersArray.allObjects
        enumerateObjectsWithOptions:NSEnumerationReverse
                         usingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *_Nonnull stop) {
                             if (disappearVc == vc) {
                                 [self.visiableControllersArray removePointerAtIndex:idx];
                             }
                         }];
}

- (UIViewController *)currentViewController {
    return self.allDidAppearViewControllers.lastObject;
}

- (UIViewController *)rootViewController {
    UIViewController *vc = self.allDidAppearViewControllers.lastObject;
    while (vc.parentViewController) {
        vc = vc.parentViewController;
    }
    return vc;
}

- (NSArray<UIViewController *> *)allDidAppearViewControllers {
    return self.visiableControllersArray.allObjects;
}

- (BOOL)isDidAppearController:(UIViewController *)vc {
    return [self.visiableControllersTable containsObject:vc];
}

- (BOOL)isPrivateViewControllerIgnored:(UIViewController *)viewController {
    if (viewController == nil) {
        return NO;
    }
    NSString *vcName = NSStringFromClass([viewController class]);
    if (self.ignoredPrivateControllers.count > 0 && [self.ignoredPrivateControllers containsObject:vcName]) {
        return YES;
    }

    return NO;
}
- (GrowingPageGroup *)findPageByViewController:(UIViewController *)current {
    GrowingPageGroup *page = nil;
    UIViewController *last = nil;
    while (current) {
        last = current;
        if ([[GrowingPageManager sharedInstance] isPrivateViewControllerIgnored:current]) {
            current = (UIViewController*)current.growingNodeParent;
        } else {
            page = [current growingPageHelper_getPageObject];
            if (page == nil) {
                page = [self createdPage:current];
            }
            if (page.isIgnored) {
                current = (UIViewController*)current.growingNodeParent;
            } else {
                break;
            }
        }
    }
    if (!page && last) {
        page = [last growingPageHelper_getPageObject];
    }
    return page;
}

- (GrowingPageGroup *)findPageByView:(UIView *)view {
    UIViewController *current = [view growingHelper_viewController];
    if (!current) {
        current = self.currentViewController;
    }
    return [self findPageByViewController:current];
}

- (GrowingPageGroup *)currentPage {
    UIViewController *parent = [self currentViewController];
    GrowingPageGroup *page = [parent growingPageHelper_getPageObject];
    return page;
}

#pragma mark Lazy Load

- (NSMutableArray *)ignoredPrivateControllers {
    if (!_ignoredPrivateControllers) {
        _ignoredPrivateControllers = [NSMutableArray arrayWithArray:@[
            @"UIInputWindowController", @"UIActivityGroupViewController", @"UIKeyboardHiddenViewController",
            @"UICompatibilityInputViewController", @"UISystemInputAssistantViewController",
            @"UIPredictionViewController", @"GrowingWindowViewController", @"UIApplicationRotationFollowingController",
            @"UIAlertController", @"_UIAlertControllerTextFieldViewController",
            @"UICandidateViewController", @"UISystemKeyboardDockController",
            @"UIKeyboardCameraViewController", @"UIKeyboardCameraRemoteViewController",
        ]];
    }
    return _ignoredPrivateControllers;
}

@end
