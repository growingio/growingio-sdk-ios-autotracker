//
//  UIView+GrowingImpressionInternal.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/7/13.
//  Copyright (C) 2023 Beijing Yishu Technology Co., Ltd.
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

#import <objc/runtime.h>
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/Public/GrowingAutotrackConfiguration.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "Modules/ImpressionTrack/GrowingImpressionTrack.h"
#import "Modules/ImpressionTrack/UIView+GrowingImpressionInternal.h"

@implementation UIView (GrowingImpressionInternal)

- (void)growing_didMoveToSuperview {
    [self growing_didMoveToSuperview];

    if (self.superview && self.window) {
        [[GrowingImpressionTrack sharedInstance] addNode:self inSubView:YES];
    }
}

- (BOOL)growingIMPTracked {
    return [objc_getAssociatedObject(self, @selector(growingIMPTracked)) boolValue];
}

- (void)setGrowingIMPTracked:(BOOL)flag {
    objc_setAssociatedObject(self,
                             @selector(growingIMPTracked),
                             [NSNumber numberWithBool:flag],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)growingIMPTrackEventName {
    return objc_getAssociatedObject(self, @selector(growingIMPTrackEventName));
}

- (void)setGrowingIMPTrackEventName:(NSString *)eventId {
    objc_setAssociatedObject(self, @selector(growingIMPTrackEventName), eventId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)growingIMPTrackVariable {
    return objc_getAssociatedObject(self, @selector(growingIMPTrackVariable));
}

- (void)setGrowingIMPTrackVariable:(NSDictionary *)variable {
    objc_setAssociatedObject(self, @selector(growingIMPTrackVariable), variable, OBJC_ASSOCIATION_COPY_NONATOMIC);
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
    double impScale = 0.0;
    GrowingTrackConfiguration *configuration = GrowingConfigurationManager.sharedInstance.trackConfiguration;
    if ([configuration isKindOfClass:[GrowingAutotrackConfiguration class]]) {
        impScale = ((GrowingAutotrackConfiguration *)configuration).impressionScale;
    }

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
            if (!curNode.isProxy && [curNode isKindOfClass:[UIView class]]) {
                if (((UIView *)curNode).hidden == YES || ((UIView *)curNode).alpha < 0.001) {
                    return NO;
                }
            }
            curNode = curNode.nextResponder;
        }
        return YES;
    }

    return NO;
}

- (void)growingTrackImpression:(NSString *)eventName {
    [self growingTrackImpression:eventName attributes:nil];
}

- (void)growingTrackImpression:(NSString *)eventName attributes:(NSDictionary<NSString *, id> *_Nullable)attributes {
    if (eventName.length == 0) {
        return;
    }

    if (self.growingIMPTrackEventName && [eventName isEqualToString:self.growingIMPTrackEventName]) {
        if ((attributes && self.growingIMPTrackVariable &&
             [attributes isEqualToDictionary:self.growingIMPTrackVariable]) ||
            (attributes == nil && self.growingIMPTrackVariable == nil)) {
            return;
        }
    }

    [GrowingImpressionTrack sharedInstance].impTrackActive = YES;

    self.growingIMPTrackEventName = eventName;
    self.growingIMPTrackVariable = attributes;
    self.growingIMPTracked = NO;
    [[GrowingImpressionTrack sharedInstance] addNode:self inSubView:NO];
}

- (void)growingStopTrackImpression {
    [[GrowingImpressionTrack sharedInstance] clearNode:self];
}

@end
