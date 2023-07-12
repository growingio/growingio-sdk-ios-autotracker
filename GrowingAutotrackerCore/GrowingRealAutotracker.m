//
//  GrowingRealAutotracker.m
//  GrowingAnalytics
//
//  Created by xiangyang on 2020/11/12.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingAutotrackerCore/GrowingRealAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/NSNotificationCenter+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UIAlertController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UIApplication+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UICollectionView+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UISegmentedControl+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UITableView+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UITapGestureRecognizer+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/Autotrack/UIView+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIAlertController+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UISegmentedControl+GrowingNode.h"
#import "GrowingAutotrackerCore/Impression/GrowingImpressionTrack.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingULSwizzle.h"
#import "GrowingULViewControllerLifecycle.h"

@implementation GrowingRealAutotracker

- (instancetype)initWithConfiguration:(GrowingTrackConfiguration *)configuration
                        launchOptions:(NSDictionary *)launchOptions {
    self = [super initWithConfiguration:configuration launchOptions:launchOptions];
    if (self) {
        [self addAutoTrackSwizzles];
        [GrowingAlertVCActionView addAutoTrackSwizzles];
        [GrowingSegmentButton addAutoTrackSwizzles];
        [GrowingULViewControllerLifecycle setup];
        [GrowingPageManager.sharedInstance start];
        [GrowingImpressionTrack.sharedInstance start];
    }

    return self;
}

- (void)addAutoTrackSwizzles {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // UIApplication
        NSError *applicatonError = NULL;
        [UIApplication growingul_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                                    withMethod:@selector(growing_sendAction:to:from:forEvent:)
                                         error:&applicatonError];
        if (applicatonError) {
            GIOLogError(@"Failed to swizzle UIApplication. Details: %@", applicatonError);
        }

        // UISegmentControl
        NSError *segmentControlError = NULL;
        [UISegmentedControl growingul_swizzleMethod:@selector(initWithCoder:)
                                         withMethod:@selector(growing_initWithCoder:)
                                              error:&segmentControlError];
        [UISegmentedControl growingul_swizzleMethod:@selector(initWithFrame:)
                                         withMethod:@selector(growing_initWithFrame:)
                                              error:&segmentControlError];
        [UISegmentedControl growingul_swizzleMethod:@selector(initWithItems:)
                                         withMethod:@selector(growing_initWithItems:)
                                              error:&segmentControlError];
        if (segmentControlError) {
            GIOLogError(@"Failed to swizzle UISegmentControl. Details: %@", segmentControlError);
        }

        // UIView
        NSError *viewError = NULL;
        [UIView growingul_swizzleMethod:@selector(didMoveToSuperview)
                             withMethod:@selector(growing_didMoveToSuperview)
                                  error:&viewError];
        if (viewError) {
            GIOLogError(@"Failed to swizzle UIView. Details: %@", viewError);
        }

        // NSNotificationCenter
        NSError *notiError = NULL;
        [NSNotificationCenter growingul_swizzleMethod:@selector(postNotificationName:object:userInfo:)
                                           withMethod:@selector(growing_postNotificationName:object:userInfo:)
                                                error:&notiError];
        if (notiError) {
            GIOLogError(@"Failed to swizzle NSNotificationCenter. Details: %@", notiError);
        }

        // ListView
        NSError *listViewError = NULL;
        [UITableView growingul_swizzleMethod:@selector(setDelegate:)
                                  withMethod:@selector(growing_setDelegate:)
                                       error:&listViewError];

        [UICollectionView growingul_swizzleMethod:@selector(setDelegate:)
                                       withMethod:@selector(growing_setDelegate:)
                                            error:&listViewError];
        if (listViewError) {
            GIOLogError(@"Failed to swizzle ListView. Details: %@", listViewError);
        }

        // UITapGesture
        NSError *gestureError = NULL;
        [UITapGestureRecognizer growingul_swizzleMethod:@selector(initWithCoder:)
                                             withMethod:@selector(growing_initWithCoder:)
                                                  error:&gestureError];
        [UITapGestureRecognizer growingul_swizzleMethod:@selector(initWithTarget:action:)
                                             withMethod:@selector(growing_initWithTarget:action:)
                                                  error:&gestureError];
        if (gestureError) {
            GIOLogError(@"Failed to swizzle UITapGesture. Details: %@", listViewError);
        }

        // UIAlertController
        SEL oldDismissActionSEL =
            NSSelectorFromString([NSString stringWithFormat:@"_%@:%@:", @"dismissAnimated", @"triggeringAction"]);

        NSString *dismissActionStr = [NSString stringWithFormat:@"_%@:%@:%@:%@:",
                                                                @"dismissAnimated",
                                                                @"triggeringAction",
                                                                @"triggeredByPopoverDimmingView",
                                                                @"dismissCompletion"];
        SEL dismissActionSELFromIOS11 = NSSelectorFromString(dismissActionStr);

        NSError *alertError = NULL;
        [UIAlertController growingul_swizzleMethod:oldDismissActionSEL
                                        withMethod:@selector(growing_dismissAnimated:triggeringAction:)
                                             error:&alertError];

        [UIAlertController
            growingul_swizzleMethod:dismissActionSELFromIOS11
                         withMethod:@selector(growing_dismissAnimated:
                                                     triggeringAction:triggeredByPopoverDimmingView:dismissCompletion:)
                              error:&alertError];

        if (alertError) {
            GIOLogError(@"Failed to swizzle UIAlertController. Details: %@", alertError);
        }
    });
}

@end
