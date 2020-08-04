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
#import "GrowingGlobal.h"
#import "GrowingManualTrackEvent.h"
#import "GrowingMobileDebugger.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSObject+GrowingIvarHelper.h"
#import "UIImage+GrowingHelper.h"
#import "UIView+GrowingHelper.h"
#import "UIView+GrowingNode.h"
#import "UIViewController+GrowingAutoTrack.h"
#import "UIViewController+GrowingNode.h"
#import "UIWindow+GrowingNode.h"
#import "GrowingDispatchManager.h"
#import "GrowingPvarEvent.h"

@implementation UIViewController (GrowingNode)

- (id)growingNodeAttribute:(NSString *)attrbute forChild:(id<GrowingNode>)node {
    return nil;
}

- (id)growingNodeAttribute:(NSString *)attrbute {
    return nil;
}

- (UIImage *)growingNodeScreenShot:(UIImage *)fullScreenImage {
    return [fullScreenImage growingHelper_getSubImage:[self.view growingNodeFrame]];
}

- (UIImage *)growingNodeScreenShotWithScale:(CGFloat)maxScale {
    return [self.view growingHelper_screenshot:maxScale];
}

- (CGRect)growingNodeFrame {
    return CGRectZero;
}

- (id<GrowingNode>)growingNodeParent {
    if (![self isViewLoaded]) {
        return nil;
    }
    return self.parentViewController;
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
    dict[@"p"] = (self.growingPageName ?: nil);
    return dict;
}

- (UIWindow *)growingNodeWindow {
    return self.view.window;
}

- (id<GrowingNodeAsyncNativeHandler>)growingNodeAsyncNativeHandler {
    return nil;
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
    NSInteger index = [self growingNodeKeyIndex];
    NSString *className = NSStringFromClass(self.class);
    return index < 0 ? className : [NSString stringWithFormat:@"%@[-]", className];
}

- (NSIndexPath *)growingNodeIndexPath {
    return nil;
}

- (NSArray<id<GrowingNode>>*)growingNodeChilds {
    NSMutableArray *childs = [NSMutableArray array];
    NSArray *vcs = [[GrowingPageManager sharedInstance] allDidAppearViewControllers];
    
    __block NSInteger index = NSNotFound;
    [vcs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == self) {
            index = idx;
            *stop = YES;
        }
    }];
    // 1.如果present了alertVC，则childs为alertVC
    // 2.否则为self.view
    if (vcs.count && index >= 0 && index < vcs.count - 1) {
        id<GrowingNode> node = vcs[index + 1];
        [childs addObject:node];
    } else {
        [childs addObject:self.view];
    }
    return childs;
}

@end

@implementation UIViewController (GrowingAttributes)

static char kGrowingPageIgnorePolicyKey;
static char kGrowingPageAttributesKey;

GrowingSafeStringPropertyImplementation(growingPageAlias,
                                        setGrowingPageAlias)

- (void)mergeGrowingAttributesPvar:(NSDictionary<NSString *, NSObject *> *)growingAttributesPvar {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:growingAttributesPvar];
    if (dict.count > 100 || dict.count == 0) {
        NSLog(parameterValueErrorLog);
        return ;
    }
    //为GrowingMobileDebugger缓存用户设置 - pvar
    if (growingAttributesPvar.count != 0 ) {
        [[GrowingMobileDebugger shareDebugger] cacheValue:growingAttributesPvar
                                                   ofType:NSStringFromClass([self class])];
    }
    
    [self.growingAttributesMutablePvar mergeGrowingAttributesVar:growingAttributesPvar];
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
            if (![growingPageAttributes isKindOfClass:NSDictionary.class]) {
                NSLog(parameterValueErrorLog);
                return ;
            }
            if (![growingPageAttributes isValidDicVar]) {
                return ;
            }
            [self mergeGrowingAttributesPvar:growingPageAttributes];
        }
    }];
}

- (NSDictionary<NSString *,NSString *> *)growingPageAttributes {
    return [[self growingAttributesMutablePvar] copy];
}

- (void)setGrowingPageIgonrePolicy:(GrowingIgnorePolicy)growingPageIgonrePolicy {
    objc_setAssociatedObject(self,
                             &kGrowingPageIgnorePolicyKey,
                             [NSNumber numberWithUnsignedInteger:growingPageIgonrePolicy],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingIgnorePolicy)growingPageIgonrePolicy {
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
