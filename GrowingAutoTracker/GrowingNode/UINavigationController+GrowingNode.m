//
//  UINavigationController+GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/9/10.
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


#import "UINavigationController+GrowingNode.h"
#import "NSObject+GrowingIvarHelper.h"
#import <objc/runtime.h>
#import "UIView+GrowingNode.h"
#import "UIApplication+GrowingNode.h"

@implementation UINavigationController (GrowingNode)
- (CGRect)growingNodeFrame {
    CGRect rect = self.view.growingNodeFrame;
    BOOL isFullScreenShow = CGPointEqualToPoint(rect.origin, CGPointMake(0, 0)) && CGSizeEqualToSize(rect.size, [UIApplication sharedApplication].growingMainWindow.bounds.size);
    if (isFullScreenShow && self.parentViewController && [self.parentViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarvc = (UITabBarController*)self.parentViewController;
        rect.size.height -= tabbarvc.tabBar.frame.size.height;
    }
    
    return rect;
}
- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    NSMutableArray *childs = [NSMutableArray array];
    if (self.presentedViewController) {
        [childs addObject:self.presentedViewController];
        return childs;
    }
    
    [childs addObject:self.topViewController];
    
    if (self.isViewLoaded && [self.navigationBar growingImpNodeIsVisible]) {
        [childs addObject:self.navigationBar];
    }
    
    return childs;
}


@end

@implementation UINavigationBar (GrowingNode)

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    NSMutableArray *childs = [NSMutableArray array];
    UIView *view = nil;
    NSArray *views = nil;
    if ([self growingHelper_getIvar:"_titleView" outObj:&view] && view) {
        [childs addObject:view];
        view = nil;
    }
    view = self.growing_backButtonView;
    if (view) {
        [childs addObject:view];
    }
    if ([self growingHelper_getIvar:"_leftViews" outObj:&views] && views.count) {
        [childs addObjectsFromArray:views];
    }
    
    if ([self growingHelper_getIvar:"_rightViews" outObj:&views] && views.count) {
        [childs addObjectsFromArray:views];
        views = nil;
    }
    return childs;
}

- (UIView*)growing_backButtonView
{
    if (!self.backItem)
    {
        return nil;
    }
    NSString *selName = [[NSString alloc] initWithFormat:@"back%@View",@"Button"];
    SEL sel = NSSelectorFromString(selName);
    id backView = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.backItem respondsToSelector:sel])
    {
        backView = [self.backItem performSelector:sel];
    }
#pragma clang diagnostic pop
    return backView;
}

@end


@implementation GrowingNavigationBarBackButton

//+ (void)load {
//    unsigned int count = 0;
//    Method *methods = class_copyMethodList(self, &count);
//    NSMutableArray *classes = [[NSMutableArray alloc] init];
//    Class clazz = NSClassFromString([NSString stringWithFormat:@"_UI%@Item%@View",@"Navigation",@"Button"]);
//    if (clazz) {
//        [classes addObject:clazz];
//    }
//    for (unsigned int i = 0 ; i < count ; i++) {
//        Method method = methods[i];
//        for (Class clazz in classes) {
//            class_addMethod(clazz,
//                            method_getName(method),
//                            method_getImplementation(method),
//                            method_getTypeEncoding(method));
//        }
//    }
//    free(methods);
//}
//
//- (BOOL)growingNodeUserInteraction {
//    return YES;
//}
//
//- (NSString*)growingNodeName {
//    return @"返回按钮";
//}

@end
