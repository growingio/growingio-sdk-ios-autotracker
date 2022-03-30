//
//  UIView+GrowingHelper.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 15/9/4.
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

#import "GrowingTrackerCore/Helpers/UIView+GrowingHelper.h"

@implementation UIView (GrowingHelper)

- (UIImage*)growingHelper_screenshot:(CGFloat)maxScale {
    UIView *view = self;

    CGFloat scale = [UIScreen mainScreen].scale;
    if (maxScale != 0 && maxScale < scale) {
        scale = maxScale;
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [view.layer renderInContext:context];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIViewController*)growingHelper_viewController {
    UIResponder *curNode = self.nextResponder;
    while (curNode) {
        if ([curNode isKindOfClass:[UIViewController class]]) {
            return (id)curNode;
        }
        curNode = [curNode nextResponder];
    }
    return nil;
}

@end
