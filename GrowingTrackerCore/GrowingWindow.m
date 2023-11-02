//
//  GrowingWindow.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 16/3/5.
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

#if __has_include(<UIKit/UIKit.h>) && !TARGET_OS_WATCH
#import "GrowingTrackerCore/GrowingWindow.h"

@interface GrowingWindowViewController : UIViewController

@end

@implementation GrowingWindowViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end

@interface GrowingWindowContentView : UIView

@property (nonatomic, retain) UIWindow *showWindow;
@property (nonatomic, retain) NSMutableArray *childWindowView;

@end

@interface GrowingWindow ()

@end

@implementation GrowingWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.rootViewController = [[GrowingWindowViewController alloc] init];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    } else if (view == self.rootViewController.view) {
        return nil;
    } else {
        return view;
    }
}

@end

@implementation GrowingWindowContentView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = [UIScreen mainScreen].bounds;
}

+ (instancetype)sharedInstance {
    static __strong id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GrowingWindowContentView *contentView = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        instance = contentView;
        [contentView _growingWindowTrySetShow];
    });
    return instance;
}

- (void)_growingWindowTrySetShow {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self performSelector:@selector(_growingWindowSetShow) withObject:nil afterDelay:0.1];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _growingWindowTrySetShow];
        });
    }
}

- (void)_growingWindowSetShow {
    if (self.showWindow) {
        return;
    }

    UIWindow *window = [[GrowingWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.showWindow = window;
    window.windowLevel = UIWindowLevelAlert + 100;
    self.frame = window.bounds;
    [window.rootViewController.view addSubview:self];
    window.hidden = NO;
}

- (void)addWindowView:(GrowingWindowView *)view {
    if (!view) {
        return;
    }

    if (!self.childWindowView) {
        self.childWindowView = [[NSMutableArray alloc] init];
    }

    [self.childWindowView addObject:view];

    __block BOOL added = NO;
    [self.childWindowView
        enumerateObjectsUsingBlock:^(__kindof GrowingWindowView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.growingViewLevel > view.growingViewLevel) {
                NSInteger index = [self.subviews indexOfObject:obj];
                if (index != NSNotFound) {
                    [self insertSubview:view atIndex:index];
                    added = YES;
                    *stop = YES;
                }
            }
        }];

    if (!added) {
        [[GrowingWindowContentView sharedInstance] addSubview:view];
    }
}

- (void)removeWindowView:(GrowingWindowView *)view {
    [view removeFromSuperview];
    [self.childWindowView removeObject:view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    } else {
        return view;
    }
}

@end

@implementation GrowingWindowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.hidden = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        [[GrowingWindowContentView sharedInstance] addWindowView:self];
    } else {
        [[GrowingWindowContentView sharedInstance] removeWindowView:self];
    }
}

@end
#endif
