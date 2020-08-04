//
//  UIWindow+GrowingHelper.m
//  GrowingTracker
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


#import "UIWindow+GrowingHelper.h"
#import "GrowingInstance.h"
#import "UIView+GrowingHelper.h"

@implementation UIWindow (GrowingHelper)

- (UIImage*)growingHelper_screenshot:(CGFloat)maxScale
{
    return [[self class] growingHelper_screenshotWithWindows:@[self] andMaxScale:maxScale];
}

+ (UIImage*)growingHelper_screenshotWithWindows:(NSArray<UIWindow *> *)windows andMaxScale:(CGFloat)maxScale
{
    return [self growingHelper_screenshotWithWindows:windows andMaxScale:maxScale block:nil];
}

+ (UIImage*)growingHelper_screenshotWithWindows:(NSArray<UIWindow *> *)windows
                                    andMaxScale:(CGFloat)maxScale
                                          block:(void (^)(CGContextRef))block
{
    CGFloat scale = [UIScreen mainScreen].scale;
    if (maxScale != 0 && maxScale < scale) {
        scale = maxScale;
    }

    CGSize imageSize = CGSizeZero;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (!IOS8_PLUS) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            imageSize = [UIScreen mainScreen].bounds.size;
        } else {
            imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        }
    } else {
        // the orientation is correct so we don't have to adjust it
        imageSize = [UIScreen mainScreen].bounds.size;
    }

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in windows)
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (!IOS8_PLUS) {
            if (orientation == UIInterfaceOrientationLandscapeLeft) {
                CGContextRotateCTM(context, M_PI_2);
                CGContextTranslateCTM(context, 0, -imageSize.width);
            } else if (orientation == UIInterfaceOrientationLandscapeRight) {
                CGContextRotateCTM(context, -M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height, 0);
            } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
                CGContextRotateCTM(context, M_PI);
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    if (block)
    {
        block(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
