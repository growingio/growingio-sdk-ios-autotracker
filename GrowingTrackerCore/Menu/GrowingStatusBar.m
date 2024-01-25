//
//  GrowingStatusBar.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 3/15/16.
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

#if __has_include(<UIKit/UIKit.h>)
#import "GrowingTrackerCore/Menu/GrowingStatusBar.h"
#import "GrowingTrackerCore/Helpers/GrowingHelpers.h"
#import "GrowingULApplication.h"

@interface GrowingStatusBar ()

@property (nonatomic, retain) UIControl *btn;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation GrowingStatusBar

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragViewMoved:)];
    }
    return _panGestureRecognizer;
}

- (void)dragViewMoved:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:self];

        double statusBarFrameHeight = [[GrowingULApplication sharedApplication] growingul_statusBarHeight];
        bool topValid = (self.btn.frame.origin.y + translation.y) > statusBarFrameHeight;
        bool bottomValid =
            (self.btn.frame.origin.y + translation.y) < (self.frame.size.height - self.btn.frame.size.height);
        if (topValid && bottomValid) {
            self.btn.center = CGPointMake(self.btn.center.x, self.btn.center.y + translation.y);
        }

        [panGestureRecognizer setTranslation:CGPointZero inView:self];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIControl *tipBtn = [[UIControl alloc] init];
        tipBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.56 blue:1.0 alpha:1.0];

        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        UILabel *dragTipLabel = [[UILabel alloc] init];
        dragTipLabel.textColor = [UIColor whiteColor];
        dragTipLabel.font = [UIFont systemFontOfSize:12];
        dragTipLabel.textAlignment = NSTextAlignmentRight;
        dragTipLabel.text = @"如有遮挡请拖动此条";

        [tipBtn addSubview:tipLabel];
        [tipBtn addSubview:dragTipLabel];
        [self addSubview:tipBtn];
        tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        dragTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        tipBtn.translatesAutoresizingMaskIntoConstraints = NO;

        if (@available(iOS 11.0, *)) {
            [NSLayoutConstraint
                activateConstraints:@[[tipBtn.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor
                                                                       constant:0]]];
        } else {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:tipBtn
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:20.0]];
        }

        [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:tipBtn
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1.0
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:tipBtn
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                          constant:0]
        ]];

        [tipBtn addConstraints:@[
            [NSLayoutConstraint constraintWithItem:tipLabel
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:tipBtn
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1.0
                                          constant:8],
            [NSLayoutConstraint constraintWithItem:tipLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:tipBtn
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:tipLabel
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:tipBtn
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0]
        ]];

        [tipBtn addConstraints:@[
            [NSLayoutConstraint constraintWithItem:dragTipLabel
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:tipBtn
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                          constant:-10],
            [NSLayoutConstraint constraintWithItem:dragTipLabel
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:tipLabel
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:dragTipLabel
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:tipLabel
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1.0
                                          constant:8]
        ]];
        [dragTipLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                      forAxis:UILayoutConstraintAxisHorizontal];
        [tipLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                  forAxis:UILayoutConstraintAxisHorizontal];
        [dragTipLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [tipLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

        self.btn = tipBtn;
        self.statusLabel = tipLabel;

        [self.btn addGestureRecognizer:self.panGestureRecognizer];
        [self.btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.growingViewLevel = 0;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self == view) {
        return nil;
    }
    return view;
}

- (void)buttonAction:(UIControl *)sender {
    if (self.onButtonClick) {
        self.onButtonClick();
    }
}

@end
#endif
