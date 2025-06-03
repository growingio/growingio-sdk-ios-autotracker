//
//  UIView+GrowingNode.m
//  GrowingAnalytics
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

#import "GrowingAutotrackerCore/Autotrack/GrowingPropertyDefine.h"
#import "GrowingAutotrackerCore/Autotrack/UITapGestureRecognizer+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingAutotrackConfiguration+Private.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingULApplication.h"

@implementation UIView (GrowingNode)

#pragma mark - xpath

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
    for (int i = 0; i < subResponder.count; i++) {
        UIResponder *res = subResponder[i];
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
    return NSStringFromClass(self.class);
}

- (NSString *)growingNodeSubIndex {
    NSInteger index = [self growingNodeKeyIndex];
    return index < 0 ? @"0" : [NSString stringWithFormat:@"%ld", (long)index];
}

- (NSString *)growingNodeSubSimilarIndex {
    return [self growingNodeSubIndex];
}

- (NSArray<id<GrowingNode>> *)growingNodeChilds {
    return self.subviews;
}

#pragma mark -

- (CGRect)growingNodeFrame {
    UIWindow *mainWindow = [[GrowingULApplication sharedApplication] growingul_keyWindow];
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

- (BOOL)growingViewNodeIsInvisible {
    // 这个应该放在controller代码里 放这里可以提升效率
    // 逻辑冗余
    return (self.hidden || self.alpha < 0.001 || !self.superview || !self.window);
}

// 关系
- (BOOL)growingNodeDonotTrack {
    if ([self isKindOfClass:NSClassFromString(@"TUICandidateCell")]) {
        return YES;
    }
    if ([self isKindOfClass:NSClassFromString(@"_UINavigationItemButtonView")]) {
        return NO;
    }
    return [self growingViewNodeIsInvisible] || [self growingViewDontTrack];
}

- (BOOL)growingViewDontTrack {
    // judge self firstly
    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if ([configuration isKindOfClass:[GrowingAutotrackConfiguration class]]) {
        NSSet *ignoreViewClasses = ((GrowingAutotrackConfiguration *)configuration).ignoreViewClasses;
        if ([ignoreViewClasses containsObject:[self class]]) {
            return YES;
        }
    }

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
    return [self growingViewNodeIsInvisible];
}

- (NSString *)growingViewContent {
    NSMutableArray<UIView *> *unvisted = [[NSMutableArray alloc] init];
    if (self.subviews.count) {
        [unvisted addObjectsFromArray:self.subviews];
    }

    while (unvisted.count) {
        UIView *current = unvisted.firstObject;
        [unvisted removeObject:current];
        if ([current isKindOfClass:[UILabel class]] && [current growingViewContent].length) {
            return [current growingViewContent];
        }
        if ([current isKindOfClass:[UIImageView class]] && [(UIImageView *)current growingViewContent].length) {
            return [(UIImageView *)current growingViewContent];
        }
        if (current.subviews.count) {
            unvisted = [[current.subviews arrayByAddingObjectsFromArray:unvisted] mutableCopy];
        }
    }

    return nil;
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

    return self.userInteractionEnabled && ([self growingViewUserInteraction] ||
                                           [UITapGestureRecognizer growing_hasSingleTapGestureRecognizerInView:self]);
}

#pragma mark - Public Method

- (BOOL)growingViewUserInteraction {
    return NO;
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
    objc_setAssociatedObject(self, @selector(growingViewCustomContent), content, OBJC_ASSOCIATION_COPY_NONATOMIC);
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
