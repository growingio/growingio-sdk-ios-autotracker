//
//  UIWindow+GrowingHelper.m
//  GrowingAnalytics
//
//  Created by GrowingIO on 2/17/16.
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
#import "GrowingTrackerCore/Helpers/UIKit/UIView+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/UIKit/UIWindow+GrowingHelper.h"

@implementation UIWindow (GrowingHelper)

+ (UIImage *)growingHelper_screenshotWithWindows:(NSArray<UIWindow *> *)windows andMaxScale:(CGFloat)maxScale {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (maxScale != 0 && maxScale < scale) {
        scale = maxScale;
    }

    // SDK support version >= iOS 8.0
    // the orientation is correct so we don't have to adjust it
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    for (UIWindow *window in windows) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context,
                              -window.bounds.size.width * window.layer.anchorPoint.x,
                              -window.bounds.size.height * window.layer.anchorPoint.y);
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
        } else {
            if (context) {
                [window.layer renderInContext:context];
            }
        }
        CGContextRestoreGState(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
#endif
