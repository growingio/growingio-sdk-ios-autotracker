//
//  UIApplication+Screenshot.m
//  GrowingAnalytics
//
//  Created by YoloMao on 2023/5/9.
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

#import "Services/Screenshot/GrowingScreenshotProvider.h"
#import "Services/Screenshot/UIApplication+Screenshot.h"

@implementation UIApplication (Screenshot)

- (void)growing_sendEvent:(UIEvent *)event {
    [self growing_sendEvent:event];

    if (event.type == UIEventTypeTouches) {
        // 触摸 滑动都会在这里触发
        [[GrowingScreenshotProvider sharedInstance] dispatchApplicationEventSendEvent:event];
    }
}

@end
