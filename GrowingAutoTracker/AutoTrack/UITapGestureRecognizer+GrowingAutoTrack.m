//
//  UITapGestureRecognizer+GrowingAutoTrack.m
//  GrowingAutoTracker
//
//  Created by GrowingIO on 2020/7/27.
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


#import "UITapGestureRecognizer+GrowingAutoTrack.h"
#import "GrowingClickEvent.h"
#import "GrowingSwizzle.h"
#import "UIView+GrowingNode.h"

@interface GrowingUIGestureRecognizerObserver : NSObject

@end

@implementation GrowingUIGestureRecognizerObserver

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)growingHandleGesture:(UIGestureRecognizer *)gesture {
    SEL sel = [self getSelectorByGesture:gesture];
    if (sel) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [((NSObject*)self) performSelector:sel withObject:gesture];
#pragma clang diagnostic pop
    }
}

- (SEL)getSelectorByGesture:(UIGestureRecognizer *)gesture {
    if (gesture.class == [UITapGestureRecognizer class]) {
        NSInteger tapCount = ((UITapGestureRecognizer*)gesture).numberOfTapsRequired;
        if (tapCount == 1) {
            return @selector(growingClickEvent:);
        }
    }
    return nil;
}

- (void)growingClickEvent:(UIGestureRecognizer *)gesture {
    [GrowingClickEvent sendEventWithNode:gesture.view
                          andEventType:GrowingEventTypeTapGest];
}

- (void)oneFingerTap:(id)gesture {
    // TODO: avoid crash for GrowingUIGestureRecognizerObserver unrecongnized
}

- (void)_tapAction:(id)action {
    // TODO: avoid crash for GrowingUIGestureRecognizerObserver unrecongnized
}

@end

@implementation UITapGestureRecognizer (GrowingAutoTrack)

- (instancetype)growing_initWithTarget:(id)target action:(SEL)action {
    
    UITapGestureRecognizer *gesture = [self growing_initWithTarget:[GrowingUIGestureRecognizerObserver shareInstance]
                                                            action:action];
    [gesture addTarget:target action:action];
    return gesture;
}

- (instancetype)growing_initWithCoder:(NSCoder *)coder {
    UITapGestureRecognizer *gesture = [self growing_initWithCoder:coder];
    [gesture addTarget:[GrowingUIGestureRecognizerObserver shareInstance]
                action:@selector(growingHandleGesture:)];
    return gesture;
}

+ (BOOL)growingGestureRecognizerCanHandleView:(UIView *)view {
    for (UIGestureRecognizer *gest in view.gestureRecognizers) {
        if ([[GrowingUIGestureRecognizerObserver shareInstance] getSelectorByGesture:gest]) {
            return YES;
        }
    }
    return NO;
}

@end
