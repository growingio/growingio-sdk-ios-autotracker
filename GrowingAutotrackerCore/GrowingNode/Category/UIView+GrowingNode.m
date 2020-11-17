//
//  UIView+GrowingNode.m
//  GrowingTracker
//
//  Created by GrowingIO on 15/8/27.
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
#import "UITapGestureRecognizer+GrowingAutotracker.h"
#import "UIImage+GrowingHelper.h"
#import "GrowingBaseEvent.h"
#import "GrowingPageManager.h"
#import "NSObject+GrowingIvarHelper.h"
#import "UIApplication+GrowingNode.h"
#import "UIImage+GrowingHelper.h"
#import "UITableView+GrowingAutotracker.h"
#import "UIView+GrowingHelper.h"
#import "UIView+GrowingNode.h"
#import "GrowingIMPTrack.h"
#import "GrowingConfigurationManager.h"

@interface GrowingMaskView : UIImageView
@end

@implementation GrowingMaskView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self) ? nil : hit;
}

@end

GrowingPropertyDefine(UIView, GrowingMaskView*, growingHighlightView, setGrowingHighlightView)

@implementation UIView(GrowingNode)

- (UIImage *)growingNodeScreenShot:(UIImage *)fullScreenImage {
    return [fullScreenImage growingHelper_getSubImage:[self growingNodeFrame]];
}

- (UIImage *)growingNodeScreenShotWithScale:(CGFloat)maxScale {
    return [self growingHelper_screenshot:maxScale];
}

#pragma mark - xpath



- (NSIndexPath *)growingNodeIndexPath {
    return nil;
}

- (NSInteger)growingNodeKeyIndex {
    NSString *classString = NSStringFromClass(self.class);
    NSArray *subResponder = nil;
    UIResponder *next = [self nextResponder];
    if ([next isKindOfClass:UISegmentedControl.class]) {
        [next growingHelper_getIvar:"_segments" outObj:&subResponder];
    } else if ([next isKindOfClass:UIView.class]) {
        subResponder = [(UIView *)next subviews];
    }

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
    return index;
}

- (NSString *)growingNodeSubPath {
    /* 忽略路径
     UITableViewWrapperView 为 iOS11 以下 UITableView 与 cell 之间的 view
     */
    if ([NSStringFromClass(self.class) isEqualToString:@"UITableViewWrapperView"]) {
        return @"";
    }
    
    NSInteger index = [self growingNodeKeyIndex];
    NSString *className = NSStringFromClass(self.class);
    return index < 0
               ? className
               : [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

- (NSString *)growingNodeSubSimilarPath {
    return [self growingNodeSubPath];
}

- (NSArray<id<GrowingNode>> *)growingNodeChilds {
    //由于WKWebView具有内容视图，不再对其子元素进行遍历
    if ([self isKindOfClass:NSClassFromString(@"WKWebView")]) {
        return nil;
    }
    return self.subviews;
}

#pragma mark -

- (CGRect)growingNodeFrame {
    UIWindow *mainWindow = [[UIApplication sharedApplication] growingMainWindow];
    UIWindow *parentWindow = self.window;

    CGRect frame = [self convertRect:self.bounds toView:parentWindow];
    if (mainWindow == parentWindow) {
        return frame;
    } else {
        return [parentWindow convertRect:frame toWindow:mainWindow];
    }
}

- (id<GrowingNode>)growingNodeParent {
    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        return (id)self.nextResponder;
    } else {
        // UIWindow 也在里面
        return (id)self.superview;
    }
}

- (BOOL)growingViewNodeIsInvisiable {
    // 这个应该放在controller代码里 放这里可以提升效率
    // 逻辑冗余
    return (self.hidden || self.alpha < 0.001 ||
            !self.superview || self.growingNodeIsBadNode || !self.window);
}

- (BOOL)growingImpNodeIsVisible {
    if (!self.window || self.hidden || self.alpha < 0.001 || !self.superview) {
        return NO;
    }
    
    CGRect rect = [self growingNodeFrame];
    CGRect intersectionRect = CGRectIntersection([UIScreen mainScreen].bounds, rect);
    
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return NO;
    }
    
    BOOL isInScreen;
    double impScale = GrowingConfigurationManager.sharedInstance.trackConfiguration.impressionScale;
    
    if (impScale == 0.0) {
        isInScreen = YES;
    } else {
        if (intersectionRect.size.width * intersectionRect.size.height >=
            self.bounds.size.width * self.bounds.size.height * impScale) {
            isInScreen = YES;
        } else {
            isInScreen = NO;
        }
    }

    if (isInScreen) {
        UIResponder *curNode = self.nextResponder;
        while (curNode) {
            if (!curNode.isProxy &&
                [curNode isKindOfClass:[UIView class]]) {
                if (((UIView *)curNode).hidden == YES ||
                    ((UIView *)curNode).alpha < 0.001) {
                    return NO;
                }
            }
            curNode = curNode.nextResponder;
        }
        return YES;
    }
    
    return NO;
}

// 关系
- (BOOL)growingNodeDonotTrack {
    if ([self isKindOfClass:NSClassFromString(@"_UINavigationItemButtonView")]) {
        return NO;
    }
    return [self growingViewNodeIsInvisiable] || [self growingViewDontTrack];
}

- (BOOL)growingViewDontTrack {
    
    // judge self firstly
    GrowingIgnorePolicy selfPolicy = self.growingViewIgnorePolicy;
    if (GrowingIgnoreAll == selfPolicy || GrowingIgnoreSelf == selfPolicy) {
        return YES;
    }
    
    // judge parent
    UIView *current = self;
    while (current.superview) {
        UIView *parent = current.superview;
        GrowingIgnorePolicy parentPolicy = parent.growingViewIgnorePolicy;
        
        if (GrowingIgnoreChildren == parentPolicy || GrowingIgnoreAll == parentPolicy) {
            return YES;
        }
        
        current = parent;
    }
    
    return NO;
}

- (BOOL)growingNodeDonotCircle {
    if ([self isKindOfClass:NSClassFromString(@"_UINavigationItemButtonView")]) {
        return NO;
    }
    return [self growingViewNodeIsInvisiable];
}

// 值
- (NSString *)growingNodeName {
    if ([self isKindOfClass:NSClassFromString(@"_UINavigationItemButtonView")]) {
        return @"返回按钮";
    }
    return NSStringFromClass(self.class);
}

- (NSString *)growingViewContent {
    // apple在11.1.2的部分机型上很小概率对于class为UIPickerTableView的对象调用accessibilityLabel可能会崩溃
    // 此为apple bug
    NSString *className = NSStringFromClass(self.class);
    NSString *prefixString = @"UIPicke";
    NSString *suffixString = @"rTableView";
    if ([className hasPrefix:prefixString] &&
        [className hasSuffix:suffixString] &&
        className.length == (prefixString.length + suffixString.length)) {
        return nil;
    } else {
        // https://growingio.atlassian.net/browse/PI-839 美图IOS崩溃
        // 目前无法预知什么情况下还会有类似crash, 不再对控件类名做判断,
        // 直接try/catch处理
        NSString *accessibilityLabel = nil;
        @try {
            accessibilityLabel = self.accessibilityLabel;
        } @catch (NSException *exception) {
            accessibilityLabel = nil;
        } @finally {
            // do nothing
        }
        return accessibilityLabel;
    }
}

#pragma mark - GrowingNodeProtocol

- (NSString *)growingNodeContent {
    NSString *attrContent = self.growingViewCustomContent;
    if ([attrContent isKindOfClass:[NSString class]] && attrContent.length) {
        return attrContent;
    }

    NSString *viewContent = self.growingViewContent;
    if ([viewContent isKindOfClass:[NSString class]] && viewContent.length) {
        return viewContent;
    }

    return nil;
}

- (BOOL)growingNodeUserInteraction {
    if ([self isKindOfClass:NSClassFromString(@"_UINavigationItemButtonView")]) {
        return YES;
    }
    
    return self.userInteractionEnabled &&
           ([self growingViewUserInteraction] ||
            [UITapGestureRecognizer growingGestureRecognizerCanHandleView:self]);
}

#pragma mark - Public Method

- (BOOL)growingViewUserInteraction {
    return NO;
}

- (NSDictionary *)growingNodeDataDict {
    return nil;
}

- (UIWindow *)growingNodeWindow {
    return self.window;
}

- (NSString *)growingNodeUniqueTag {
    return self.growingUniqueTag;
}

#pragma mark GrowingAttributes

- (NSString *)growingViewCustomContent {
    return objc_getAssociatedObject(self, @selector(growingViewCustomContent));
}

- (void)setGrowingViewCustomContent:(NSString *)content {
    if ([content isKindOfClass:[NSNumber class]]) {
        content = [(NSNumber *)content stringValue];
    }
    if (![content isKindOfClass:[NSString class]]) {
        content = nil;
    }
    if (content.length > 50) {
        content = [content substringToIndex:50];
    }
    objc_setAssociatedObject(self, @selector(growingViewCustomContent), content,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)growingIMPTracked {
    return [objc_getAssociatedObject(self, @selector(growingIMPTracked)) boolValue];
}

- (void)setGrowingIMPTracked:(BOOL)flag {
    objc_setAssociatedObject(self, @selector(growingIMPTracked),
                             [NSNumber numberWithBool:flag],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)growingIMPTrackEventName {
    return objc_getAssociatedObject(self, @selector(growingIMPTrackEventName));
}

- (void)setGrowingIMPTrackEventName:(NSString *)eventId {
    objc_setAssociatedObject(self, @selector(growingIMPTrackEventName), eventId,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)growingIMPTrackVariable {
    return objc_getAssociatedObject(self, @selector(growingIMPTrackVariable));
}

- (void)setGrowingIMPTrackVariable:(NSDictionary *)variable {
    objc_setAssociatedObject(self, @selector(growingIMPTrackVariable), variable,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setGrowingViewIgnorePolicy:(GrowingIgnorePolicy)growingIgonrePolicy {
    objc_setAssociatedObject(self,
                             @selector(growingViewIgnorePolicy),
                             [NSNumber numberWithUnsignedInteger:growingIgonrePolicy],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingIgnorePolicy)growingViewIgnorePolicy {
    id policyObjc = objc_getAssociatedObject(self, @selector(growingViewIgnorePolicy));
    if (!policyObjc) {
        return GrowingIgnoreNone;
    }
    
    if ([policyObjc isKindOfClass:NSNumber.class]) {
        NSNumber *policyNum = (NSNumber *)policyObjc;
        return policyNum.unsignedIntegerValue;
    }
    
    return GrowingIgnoreNone;
}

GrowingSafeStringPropertyImplementation(growingUniqueTag, setGrowingUniqueTag)

@end

#pragma mark - section

@implementation UITableViewHeaderFooterView (GrowingNode)

- (NSString *)growingNodeSubPath {
    UITableView *tableView = (UITableView *)self.superview;

    while (![tableView isKindOfClass:UITableView.class]) {
        tableView = (UITableView *)tableView.superview;
        if (!tableView) {
            return super.growingNodeSubPath;
        }
    }
    for (NSInteger i = 0; i < tableView.numberOfSections; i++) {
        if (self == [tableView headerViewForSection:i]) {
            return [NSString stringWithFormat:@"%@[%ld]",
                                              NSStringFromClass([self class]),
                                              (long)i];
        }
        if (self == [tableView footerViewForSection:i]) {
            return [NSString stringWithFormat:@"%@[%ld]",
                                              NSStringFromClass([self class]),
                                              (long)i];
        }
    }
    return [super growingNodeSubPath];
}

@end

@implementation UIView (GrowingImpression)

- (void)growingTrackImpression:(NSString *)eventName {
    [self growingTrackImpression:eventName attributes:nil];
}

- (void)growingTrackImpression:(NSString *)eventName
                    attributes:(NSDictionary<NSString *,NSString *> *)attributes {

    if (eventName.length == 0) {
        return;
    }

    if ([eventName isEqualToString:self.growingIMPTrackEventName]) {
        if ((attributes && [attributes isEqualToDictionary:self.growingIMPTrackVariable]) ||
                attributes == self.growingIMPTrackVariable) {
            return;
        }
    }

    [GrowingIMPTrack shareInstance].impTrackActive = YES;

    self.growingIMPTrackEventName = eventName;
    self.growingIMPTrackVariable = attributes;
    self.growingIMPTracked = NO;
    [[GrowingIMPTrack shareInstance] addNode:self inSubView:NO];
}

- (void)growingStopTrackImpression {
    [[GrowingIMPTrack shareInstance] clearNode:self];
}
@end
