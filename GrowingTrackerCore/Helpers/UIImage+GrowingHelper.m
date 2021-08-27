//
//  UIImage+GrowingHelper.m
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


#import "UIImage+GrowingHelper.h"
#import "NSData+GrowingHelper.h"

@implementation UIImage (GrowingHelper)

- (NSData*)growingHelper_JPEG:(CGFloat)compress {
    return UIImageJPEGRepresentation(self, compress);
}

- (NSData*)growingHelper_PNG {
    return UIImagePNGRepresentation(self);
}

- (NSString*)growingHelper_Base64JPEG:(CGFloat)compress {
    return [[self growingHelper_JPEG:compress] growingHelper_base64String];
}

- (NSString*)growingHelper_Base64PNG {
    return [[self growingHelper_PNG] growingHelper_base64String];
}

- (UIImage*)growingHelper_getSubImage:(CGRect)rect {
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:subImageRef scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(subImageRef);
    
    return image;
}

@end
