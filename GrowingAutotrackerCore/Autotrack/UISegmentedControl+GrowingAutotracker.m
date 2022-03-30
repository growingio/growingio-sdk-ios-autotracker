//
//  UISegmentedControl+UISegmentedControl_GrowingAutoTrack.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2020/7/23.
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

#import "GrowingAutotrackerCore/Autotrack/UISegmentedControl+GrowingAutotracker.h"
#import "GrowingTrackerCore/Helpers/NSObject+GrowingIvarHelper.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIView+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/GrowingViewClickProvider.h"

@interface GrowingUISegmentedControlObserver : NSObject

+ (instancetype)sharedInstance;
- (void)growingSegmentAction:(UISegmentedControl *)segmentControl;

@end

@implementation UISegmentedControl (GrowingAutotracker)

+ (UILabel*)growing_labelForSegment:(UIView*)segment {
    UILabel *lable = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([segment respondsToSelector:@selector(label)]) {
        lable = [segment performSelector:@selector(label)];
    }
#pragma clang diagnostic pop
#if DEBUG
    else {
        // hook 失败了
        assert(0);
    }
#endif
    return lable;
}

+ (NSString*)growing_titleForSegment:(UIView *)segment {
    return [self growing_labelForSegment:segment].text;
}

- (nullable NSArray *)growing_segmentViews {
    NSArray *array = nil;
    if ([self growingHelper_getIvar:"_segments" outObj:&array]) {
        return array;
    }
    return nil;
}

static void growingUISegmentedControlSetUp(UISegmentedControl *self) {
    NSSet *allTargets = nil;
    @autoreleasepool {
        allTargets = self.allTargets;
    }
    
    if ([allTargets containsObject:[GrowingUISegmentedControlObserver sharedInstance]]) {
        return;
    }
    [self addTarget:[GrowingUISegmentedControlObserver sharedInstance]
             action:@selector(growingSegmentAction:)
   forControlEvents:UIControlEventValueChanged];
}

- (instancetype)growing_initWithCoder:(NSCoder *)coder {
    id result = [self growing_initWithCoder:coder];
    growingUISegmentedControlSetUp(self);

    return result;
}

- (instancetype)growing_initWithFrame:(CGRect)frame {
    id result = [self growing_initWithFrame:frame];
    growingUISegmentedControlSetUp(self);

    return result;
}

- (instancetype)growing_initWithItems:(NSArray *)items {
    id result = [self growing_initWithItems:items];
    growingUISegmentedControlSetUp(self);

    return result;
}

@end

@implementation GrowingUISegmentedControlObserver

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)growingSegmentAction:(UISegmentedControl *)segmentControl {
    NSInteger index = segmentControl.selectedSegmentIndex;
    NSArray *arr    = segmentControl.growing_segmentViews;
    
    if (index >= 0 && index < arr.count) {
        UIView *segment = arr[index];
        [GrowingViewClickProvider viewOnClick:segment];
    }
}

@end
