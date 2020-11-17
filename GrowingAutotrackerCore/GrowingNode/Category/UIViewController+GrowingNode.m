//
//  UIViewController+GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/8/31.
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


#import "GrowingPropertyDefine.h"
#import "GrowingPageManager.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSObject+GrowingIvarHelper.h"
#import "UIImage+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "UIView+GrowingNode.h"
#import "UIViewController+GrowingAutotracker.h"
#import "UIViewController+GrowingNode.h"
#import "UIViewController+GrowingPageHelper.h"
#import "GrowingPageGroup.h"
#import "UIWindow+GrowingNode.h"
#import "GrowingDispatchManager.h"
#import "UIApplication+GrowingNode.h"

@implementation UIViewController (GrowingNode)

- (UIImage *)growingNodeScreenShot:(UIImage *)fullScreenImage {
    return [fullScreenImage growingHelper_getSubImage:[self.view growingNodeFrame]];
}

- (UIImage *)growingNodeScreenShotWithScale:(CGFloat)maxScale {
    return [self.view growingHelper_screenshot:maxScale];
}

- (CGRect)growingNodeFrame {
    CGRect rect = self.view.growingNodeFrame;
    //是否全屏显示
    //当ViewController全屏显示时，如果被NavigationController包裹,其frame大小高度应减去导航栏的高度
    BOOL isFullScreenShow = CGPointEqualToPoint(rect.origin, CGPointMake(0, 0)) && CGSizeEqualToSize(rect.size, [UIApplication sharedApplication].growingMainWindow.bounds.size);
    if (isFullScreenShow) {
        UIViewController *parentVC = self.parentViewController;
        while (parentVC) {
            if ([parentVC isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navi = (UINavigationController*)parentVC;
                if (!navi.navigationBar.window || navi.navigationBar.hidden || navi.navigationBar.alpha < 0.001 || !navi.navigationBar.superview) {
                    break;;
                }
                rect.origin.y += (navi.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
                rect.size.height -= (navi.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
            }
            
            if ([parentVC isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabbarvc = (UITabBarController*)parentVC;
                if (!tabbarvc.tabBar.window || tabbarvc.tabBar.hidden || tabbarvc.tabBar.alpha < 0.001 || !tabbarvc.tabBar.superview) {
                    break;;
                }
                rect.size.height -= tabbarvc.tabBar.frame.size.height;
            }
            parentVC = parentVC.parentViewController;
        }
    }
    return rect;
}

- (id<GrowingNode>)growingNodeParent {
    if (![self isViewLoaded]) {
        return nil;
    }
    //UIResponder关系为 UIApplication/UIWindowScene/_UIAlertControllerShimPresenterWindow/UITransitionView/UIAlertController/AlertView
    //UIAlertController的presentingViewController 为 UIApplicationRotationFollowingController
    //取最上层的视图控制器，则无法使用上面两种方式。
    if ([self isKindOfClass:UIAlertController.class]) {
        return [[GrowingPageManager sharedInstance] currentViewController];
    } else {
        return self.parentViewController;
    }
}

- (BOOL)growingAppearStateCanTrack {
    if ([[GrowingPageManager sharedInstance] isDidAppearController:self]) {
        return YES;
    }
    //此处判断意义在于避免没有使用addChildViewController方法的childVC没有调用didappear
    //造成checknode失败 页面元素无法收集
    if ([self growingHookIsCustomAddVC]) {
        return YES;
    }
    return NO;
}

#define DonotrackCheck(theCode) \
    if (theCode) {              \
        return YES;             \
    }

- (BOOL)growingNodeDonotTrack {
    DonotrackCheck(![self isViewLoaded]) DonotrackCheck(!self.view.window)
    DonotrackCheck(self.view.window.growingNodeIsBadNode)
    DonotrackCheck(self.growingNodeIsBadNode)
    DonotrackCheck(![self growingAppearStateCanTrack]) return NO;
}

- (BOOL)growingNodeDonotCircle {
    return NO;
}

- (BOOL)growingNodeUserInteraction {
    return NO;
}

- (NSString *)growingNodeName {
    return @"页面";
}

- (NSString *)growingNodeContent {
    return self.accessibilityLabel;
}

- (NSDictionary *)growingNodeDataDict {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"pageName"] = ([self growingPageHelper_getPageObject].name ?: self.growingPageName);
    return dict;
}

- (UIWindow *)growingNodeWindow {
    return self.view.window;
}

- (NSString *)growingNodeUniqueTag {
    return self.growingPageAlias;
}


#pragma mark - xpath
- (NSInteger)growingNodeKeyIndex {
    NSString *classString = NSStringFromClass(self.class);
    NSArray *subResponder =
    [(UIViewController *)self parentViewController].childViewControllers;
    
    NSInteger count = 0;
    NSInteger index = -1;
    for (UIResponder *res in subResponder) {
        if ([classString isEqualToString:NSStringFromClass(res.class)]) {
            count++;
        }
        if (res == self) {
            index = count - 1;
        }
    }
    // 单个 UIViewController 拼接路径，不需要序号
    if (![self isKindOfClass:UIAlertController.class] && count == 1) {
        index = -1;
    }
    return index;
}

- (NSString *)growingNodeSubPath {
    NSInteger index = [self growingNodeKeyIndex];
    NSString *className = NSStringFromClass(self.class);
    return index < 0 ? className : [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

- (NSString *)growingNodeSubSimilarPath {
    return [self growingNodeSubPath];
}

- (NSIndexPath *)growingNodeIndexPath {
    return nil;
}

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    NSMutableArray *childs = [NSMutableArray array];

    if (self.presentedViewController) {
        [childs addObject:self.presentedViewController];
        return childs;
    }
    // ViewController中childViewController.view与self.view.subviews中重复，去除重复元素
    // 这里仅去除self.view上的重复,self.view.view的重复暂不考虑
    UIView *currentView = self.view;
    if (currentView && self.isViewLoaded && currentView.growingImpNodeIsVisible) {
        
        [childs addObjectsFromArray:self.view.subviews];
        if (self.childViewControllers.count > 0 && ![self isKindOfClass:UIAlertController.class]) {
            // 是否包含全屏视图
            __block BOOL isContainFullScreen = NO;
            
            NSArray <UIViewController *> *childViewControllers = self.childViewControllers;
            [childViewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.isViewLoaded) {
                    UIView *objSuperview = obj.view;
                    for (long i = (long)(childs.count - 1); i >= 0; i--) {
                        UIView *childview = childs[i];
                        //如果childview包含或者等于objsuperview
                        if ([objSuperview isDescendantOfView:childview]) {
                            // xib拖拽的viewController会被一个自定义的view包裹，判断其subviews数量是否为1
                            if ([childview isEqual:objSuperview] || (childview.subviews.count == 1 && [childview.subviews.lastObject isEqual:objSuperview])) {
                                //                            NSInteger index = [childs indexOfObject:objSuperview];
                                if ([objSuperview growingImpNodeIsVisible] && !isContainFullScreen) {
                                    [childs replaceObjectAtIndex:i withObject:obj];
                                } else {
                                    [childs removeObject:childview];
                                }
                            }
                        }
                    }
                    
                    CGRect rect = [obj.view convertRect:obj.view.bounds toView:nil];
                    // 是否全屏
                    BOOL isFullScreenShow = CGPointEqualToPoint(rect.origin, CGPointMake(0, 0)) && CGSizeEqualToSize(rect.size, [UIApplication sharedApplication].growingMainWindow.bounds.size);
                    // 正在全屏显示
                    if (isFullScreenShow && [obj.view growingImpNodeIsVisible]) {
                        isContainFullScreen = YES;
                    }
                }
            }];
        }
        
        [childs addObject:currentView];
        return childs;
    }
    
    
    
    if ([self isKindOfClass:UIPageViewController.class]) {
        UIPageViewController *pageViewController = (UIPageViewController *)self;
        [childs addObject:pageViewController.viewControllers];
    }
    
    
    return childs;
}

- (NSTimeInterval)growingTimeIntervalForLastClick {
    return 0;
}

@end

@implementation UIViewController (GrowingAttributes)

static char kGrowingPageIgnorePolicyKey;
static char kGrowingPageAttributesKey;

GrowingSafeStringPropertyImplementation(growingPageAlias,
                                        setGrowingPageAlias)

- (void)mergeGrowingAttributesPvar:(NSDictionary<NSString *, NSObject *> *)growingAttributesPvar {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:growingAttributesPvar];
    //为GrowingMobileDebugger缓存用户设置 - pvar
    if (growingAttributesPvar.count != 0 ) {
        //TODO: mobiledebuger需要缓存？
//        [[GrowingMobileDebugger shareDebugger] cacheValue:growingAttributesPvar
//                                                   ofType:NSStringFromClass([self class])];
    }
}

- (void)removeGrowingAttributesPvar:(NSString *)key {
    [self.growingAttributesMutablePvar removeGrowingAttributesVar:key];
}

- (NSMutableDictionary<NSString *, NSObject *> *)growingAttributesMutablePvar {
    NSMutableDictionary<NSString *, NSObject *> * pvar = objc_getAssociatedObject(self, &kGrowingPageAttributesKey);
    if (pvar == nil) {
        pvar = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self,
                                 &kGrowingPageAttributesKey,
                                 pvar,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return pvar;
}

- (void)setGrowingPageAttributes:(NSDictionary<NSString *,NSString *> *)growingPageAttributes {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
        
        if (!growingPageAttributes || ([growingPageAttributes isKindOfClass:NSDictionary.class]
                                       && growingPageAttributes.count == 0)) {
            
            [self removeGrowingAttributesPvar:nil]; // remove all
            
        } else {
            if (![growingPageAttributes isValidDictVariable]) {
                return ;
            }
            [self mergeGrowingAttributesPvar:growingPageAttributes];
        }
    }];
}

- (NSDictionary<NSString *,NSString *> *)growingPageAttributes {
    return [[self growingAttributesMutablePvar] copy];
}

- (void)setGrowingPageIgnorePolicy:(GrowingIgnorePolicy)growingPageIgnorePolicy {
    objc_setAssociatedObject(self,
                             &kGrowingPageIgnorePolicyKey,
                             [NSNumber numberWithUnsignedInteger:growingPageIgnorePolicy],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingIgnorePolicy)growingPageIgnorePolicy {
    id policyObjc = objc_getAssociatedObject(self, &kGrowingPageIgnorePolicyKey);
    if (!policyObjc) {
        return GrowingIgnoreNone;
    }
    
    if ([policyObjc isKindOfClass:NSNumber.class]) {
        NSNumber *policyNum = (NSNumber *)policyObjc;
        return policyNum.unsignedIntegerValue;
    }
    
    return GrowingIgnoreNone;
}

@end
