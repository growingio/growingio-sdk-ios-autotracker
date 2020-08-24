//
//  UIApplication+GrowingAutoTrack.m
//  GrowingAutoTracker
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


#import "UIApplication+GrowingAutoTrack.h"
#import "GrowingClickEvent.h"
#import "GrowingMediator.h"

@implementation UIApplication (GrowingAutoTrack)

- (BOOL)growing_sendAction:(SEL)action
                        to:(id)target
                      from:(id)sender
                  forEvent:(UIEvent *)event {
    
    BOOL result = YES;
    result = [self growing_sendAction:action to:target from:sender forEvent:event];
    
    if (NSClassFromString(@"GrowingWebCircle") != NULL) {
        [[GrowingMediator sharedInstance] performClass:@"GrowingWebCircle" action:@"setNeedUpdateScreen" params:nil];
    }
    
    if ([sender isKindOfClass:UITabBarItem.class] ||
        [sender isKindOfClass:UIBarButtonItem.class] ||
        [sender isKindOfClass:UISegmentedControl.class]) {
        return result;
    }
    
    if ([sender isKindOfClass:UISwitch.class] ||
        [sender isKindOfClass:UIStepper.class] ||
        [sender isKindOfClass:UIPageControl.class]) {

        [GrowingClickEvent sendEventWithNode:sender andEventType:GrowingEventTypeButtonClick];

        return result;
    }

    if ([event isKindOfClass:[UIEvent class]] && event.type == UIEventTypeTouches && [[[event allTouches] anyObject] phase] == UITouchPhaseEnded) {
        
        [GrowingClickEvent sendEventWithNode:sender andEventType:GrowingEventTypeButtonClick];

        return result;
    }
    
    return result;
}

@end
