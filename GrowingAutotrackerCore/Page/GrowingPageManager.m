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

#import "GrowingPageManager.h"

#import <UIKit/UIKit.h>

#import "GrowingAppLifecycle.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingEventManager.h"
#import "GrowingPage.h"
#import "GrowingPageAttributesEvent.h"
#import "GrowingPageEvent.h"
#import "GrowingPageGroup.h"
#import "GrowingPrivateCategory.h"
#import "GrowingViewControllerLifecycle.h"
#import "NSString+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "UIViewController+GrowingAutotracker.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingPageHelper.h"

@interface GrowingPageManager () <GrowingViewControllerLifecycleDelegate>

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
        [GrowingViewControllerLifecycle.sharedInstance addViewControllerLifecycleDelegate:self];
    });
}

- (void)viewControllerDidAppear:(UIViewController *)controller {
    if (![self isPrivateViewControllerIgnored:controller]) {
        [self createdViewControllerPage:controller];
        [self addDidAppearController:controller];
    }
}

- (void)viewControllerDidDisappear:(UIViewController *)controller {
    [self removeDidDisappearController:controller];
}

- (void)createdViewControllerPage:(UIViewController *)viewController {
    GrowingPageGroup *page = [viewController growingPageHelper_getPageObject];
    if (page == nil) {
        page = [GrowingPageGroup pageWithCarrier:viewController];
        page.parent = [self findParentPage:viewController];
        if (page.parent != nil) {
            [page.parent addChildrenPage:page];
        }
        [self addPageAlias:page];
        [viewController growingPageHelper_setPageObject:page];
    } else {
        [page refreshShowTimestamp];
    }

    if (!page.isIgnored) {
        //发送page事件
        [self sendPageEventWithPage:page];
    } else {
        GIOLogDebug(@"createdViewControllerPage: path = %@ is ignored", page.path);
    }
    [self reissuePageVariable:page];
}

- (void)sendPageEventWithPage:(GrowingPage *)page {
    GrowingBaseBuilder *builder =
        GrowingPageEvent.builder.setTitle(page.title).setPath(page.path).setTimestamp(page.showTimestamp);
    [[GrowingEventManager shareInstance] postEventBuidler:builder];
}

- (void)sendPageAttributesEventWithPage:(GrowingPage *)page {
    GrowingBaseBuilder *builder = GrowingPageAttributesEvent.builder.setPath(page.path)
                                      .setTimestamp(page.showTimestamp)
                                      .setAttributes(page.variables);
    [[GrowingEventManager shareInstance] postEventBuidler:builder];
}

- (void)addPageAlias:(GrowingPage *)page {
    NSString *alias = [page.carrier growingPageAlias];
    if (![NSString growingHelper_isBlankString:alias]) {
        page.alias = alias;
    }
}

- (void)reissuePageVariable:(GrowingPageGroup *)pageGroup {
    NSDictionary<NSString *, NSString *> *var = [pageGroup.carrier growingPageAttributes];
    if (var.count > 0) {
        [self setPage:pageGroup variable:var];
        return;
    }

    var = pageGroup.variables;
    if (var.count > 0) {
        [self setPage:pageGroup variable:var];
        return;
    }

    if (pageGroup.parent != nil) {
        var = pageGroup.parent.variables;
        if (var.count > 0) {
            [self setPage:pageGroup variable:var];
        }
    }
}

- (GrowingPageGroup *)findParentPage:(UIViewController *)carrier {
    UIViewController *parentVC = nil;

    if ([carrier isKindOfClass:UIAlertController.class]) {
        parentVC = [self currentViewController];
    } else {
        parentVC = carrier.parentViewController;
    }

    if (parentVC == nil) {
        GIOLogError(@"%@ you want find parentVC is nil", carrier);
        return nil;
    } else {
        GrowingPageGroup *page = [parentVC growingPageHelper_getPageObject];
        if (page == nil) {
            [self.ignoredPrivateControllers addObject:NSStringFromClass(carrier.class)];
            GIOLogError(@"UIViewController: %@ associated page object is nil", carrier);
        }
        return page;
    }
}

- (void)setPage:(GrowingPage *)page variable:(NSDictionary<NSString *, NSString *> *)variable {
    page.variables = variable;

    if (!page.isIgnored) {
        // 发送pvar事件
        [self sendPageAttributesEventWithPage:page];
    }
    if ([page isKindOfClass:GrowingPageGroup.class]) {
        GrowingPageGroup *pageGroup = (GrowingPageGroup *)page;
        if (!pageGroup.childPages) {
            return;
        }

        for (GrowingPage *child in pageGroup.childPages) {
            if (child.showTimestamp >= pageGroup.showTimestamp) {
                [self setPage:child variable:variable];
            }
        }
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
            current = current.growingNodeParent;
        } else {
            page = [current growingPageHelper_getPageObject];
            if (page.isIgnored) {
                current = current.growingNodeParent;
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
            @"UIAlertController"
        ]];
    }
    return _ignoredPrivateControllers;
}

@end
