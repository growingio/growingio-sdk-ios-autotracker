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
#import "GrowingAutotrackerCore/Autotrack/UIViewController+GrowingAutotracker.h"
#import "GrowingAutotrackerCore/GrowingAutotrackConfiguration+Private.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UIAlertController+GrowingNode.h"
#import "GrowingAutotrackerCore/GrowingNode/Category/UISegmentedControl+GrowingNode.h"
#import "GrowingAutotrackerCore/Page/GrowingPageManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Utils/GrowingArgumentChecker.h"
#import "GrowingULSwizzle.h"
#import "GrowingULViewControllerLifecycle.h"

@interface GrowingRealAutotracker (Private)

@property (nonatomic, strong) GrowingAutotrackConfiguration *configuration;

@end

@implementation GrowingRealAutotracker

- (instancetype)initWithConfiguration:(GrowingTrackConfiguration *)configuration
                        launchOptions:(NSDictionary *)launchOptions {
    self = [super initWithConfiguration:configuration launchOptions:launchOptions];
    if (self) {
        if (self.configuration.autotrackEnabled) {
            [self addAutoTrackSwizzles];
            [GrowingULViewControllerLifecycle setup];
            [GrowingPageManager.sharedInstance start];
        }
    }

    return self;
}

- (void)ignoreViewClass:(Class)clazz {
    [self.configuration ignoreViewClass:clazz];
}

- (void)ignoreViewClasses:(NSArray<Class> *)classes {
    [self.configuration ignoreViewClasses:classes];
}

- (void)autotrackPage:(UIViewController *)controller alias:(NSString *)alias {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       if ([GrowingArgumentChecker isIllegalEventName:alias]) {
                           return;
                       }
                       [GrowingPageManager.sharedInstance autotrackPage:controller alias:alias attributes:nil];
                   }];
}

- (void)autotrackPage:(UIViewController *)controller
                alias:(NSString *)alias
           attributes:(NSDictionary<NSString *, NSString *> *)attributes {
    [GrowingDispatchManager trackApiSel:_cmd
                   dispatchInMainThread:^{
                       if ([GrowingArgumentChecker isIllegalEventName:alias] ||
                           [GrowingArgumentChecker isIllegalAttributes:attributes]) {
                           return;
                       }
                       [GrowingPageManager.sharedInstance autotrackPage:controller alias:alias attributes:attributes];
                   }];
}

- (void)addAutoTrackSwizzles {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // UIApplication
        NSError *applicationError = NULL;
        [UIApplication growingul_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                                    withMethod:@selector(growing_sendAction:to:from:forEvent:)
                                         error:&applicationError];
        if (applicationError) {
            GIOLogError(@"Failed to swizzle UIApplication. Details: %@", applicationError);
        }

        // UISegmentControl
        [GrowingSegmentSwizzleHelper addAutoTrackSwizzles];
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

        // UITapGestureRecognizer
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
        [GrowingAlertSwizzleHelper addAutoTrackSwizzles];
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
