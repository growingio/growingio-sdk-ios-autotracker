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

#import "GrowingRealAutotracker.h"
#import "GrowingSwizzle.h"
#import "GrowingLogMacros.h"
#import "GrowingCocoaLumberjack.h"
#import "UIViewController+GrowingAutotracker.h"
#import "UIApplication+GrowingAutotracker.h"
#import "UISegmentedControl+GrowingAutotracker.h"
#import "UIView+GrowingAutotracker.h"
#import "NSNotificationCenter+GrowingAutotracker.h"
#import "WKWebView+GrowingAutotracker.h"
#import "UITableView+GrowingAutotracker.h"
#import "UITapGestureRecognizer+GrowingAutotracker.h"
#import "UIAlertController+GrowingAutotracker.h"
#import "GrowingPageManager.h"
#import "GrowingImpressionTrack.h"
#import "GrowingAppDelegateAutotracker.h"

@implementation GrowingRealAutotracker
- (instancetype)initWithConfiguration:(GrowingTrackConfiguration *)configuration launchOptions:(NSDictionary *)launchOptions {
    self = [super initWithConfiguration:configuration launchOptions:launchOptions];
    if (self) {
        [self addAutoTrackSwizzles];
        [GrowingPageManager.sharedInstance start];
        [GrowingImpressionTrack.shareInstance start];
    }

    return self;
}

- (void)addAutoTrackSwizzles {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = NULL;
        // UIViewController
        [UIViewController growing_swizzleMethod:@selector(viewDidAppear:)
                                     withMethod:@selector(growing_viewDidAppear:)
                                          error:&error];

        [UIViewController growing_swizzleMethod:@selector(viewDidDisappear:)
                                     withMethod:@selector(growing_viewDidDisappear:)
                                          error:&error];
        if (error) {
            GIOLogError(@"Failed to swizzle UIViewController. Details: %@", error);
            error = NULL;
        }

        // UIApplication
        NSError *applicatonError = NULL;
        [UIApplication growing_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                                  withMethod:@selector(growing_sendAction:to:from:forEvent:)
                                       error:&applicatonError];
        if (applicatonError) {
            GIOLogError(@"Failed to swizzle UIApplication. Details: %@", applicatonError);
        }
        
        // UISegmentControl
        NSError *segmentControlError = NULL;
        [UISegmentedControl growing_swizzleMethod:@selector(initWithCoder:)
                                       withMethod:@selector(growing_initWithCoder:)
                                            error:&segmentControlError];
        [UISegmentedControl growing_swizzleMethod:@selector(initWithFrame:)
                                       withMethod:@selector(growing_initWithFrame:)
                                            error:&segmentControlError];
        [UISegmentedControl growing_swizzleMethod:@selector(initWithItems:)
                                       withMethod:@selector(growing_initWithItems:)
                                            error:&segmentControlError];
        if (segmentControlError) {
            GIOLogError(@"Failed to swizzle UISegmentControl. Details: %@", segmentControlError);
        }

        // UIView
        NSError *viewError = NULL;
        [UIView growing_swizzleMethod:@selector(didMoveToSuperview)
                           withMethod:@selector(growing_didMoveToSuperview)
                                error:&viewError];
        if (viewError) {
            GIOLogError(@"Failed to swizzle UIView. Details: %@", viewError);
        }

        // NSNotificationCenter
        NSError *notiError = NULL;
        [NSNotificationCenter growing_swizzleMethod:@selector(postNotificationName:object:userInfo:)
                                         withMethod:@selector(growing_postNotificationName:object:userInfo:)
                                              error:&notiError];
        if (notiError) {
            GIOLogError(@"Failed to swizzle NSNotificationCenter. Details: %@", notiError);
        }

        // WKWebView
        NSError *webViewError = NULL;
        [WKWebView growing_swizzleMethod:@selector(initWithFrame:configuration:)
                              withMethod:@selector(growing_initWithFrame:configuration:)
                                   error:&webViewError];
        if (webViewError) {
            GIOLogError(@"Failed to swizzle WKWebView. Details: %@", webViewError);
        }

        // ListView
        NSError *listViewError = NULL;
        [UITableView growing_swizzleMethod:@selector(setDelegate:)
                                withMethod:@selector(growing_setDelegate:)
                                     error:&listViewError];

        [UICollectionView growing_swizzleMethod:@selector(setDelegate:)
                                     withMethod:@selector(growing_setDelegate:)
                                          error:&listViewError];
        if (listViewError) {
            GIOLogError(@"Failed to swizzle ListView. Details: %@", listViewError);
        }

        // UITapGesture
        NSError *gestureError = NULL;
        [UITapGestureRecognizer growing_swizzleMethod:@selector(initWithCoder:)
                                           withMethod:@selector(growing_initWithCoder:)
                                                error:&gestureError];
        [UITapGestureRecognizer growing_swizzleMethod:@selector(initWithTarget:action:)
                                           withMethod:@selector(growing_initWithTarget:action:)
                                                error:&gestureError];
        if (gestureError) {
            GIOLogError(@"Failed to swizzle UITapGesture. Details: %@", listViewError);
        }

        // UIAlertController
        SEL oldDismissActionSEL = NSSelectorFromString([NSString stringWithFormat:@"_%@:%@:",
                                                                                  @"dismissAnimated",
                                                                                  @"triggeringAction"]);

        NSString *dismissActionStr = [NSString stringWithFormat:@"_%@:%@:%@:%@:",
                                                                @"dismissAnimated",
                                                                @"triggeringAction",
                                                                @"triggeredByPopoverDimmingView",
                                                                @"dismissCompletion"];
        SEL dismissActionSELFromIOS11 = NSSelectorFromString(dismissActionStr);

        NSError *alertError = NULL;
        [UIAlertController growing_swizzleMethod:oldDismissActionSEL
                                      withMethod:@selector(growing_dismissAnimated:triggeringAction:)
                                           error:&alertError];

        [UIAlertController growing_swizzleMethod:dismissActionSELFromIOS11
                                      withMethod:@selector(growing_dismissAnimated:triggeringAction:triggeredByPopoverDimmingView:dismissCompletion:)
                                           error:&alertError];

        if (alertError) {
            GIOLogError(@"Failed to swizzle UIAlertController. Details: %@", alertError);
        }
        
        [GrowingAppDelegateAutotracker track];
    });
}

@end
